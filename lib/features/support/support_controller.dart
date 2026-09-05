import 'package:flutter/foundation.dart';

import '../../core/network/api_environment.dart';
import '../../core/network/api_models.dart';
import '../../core/network/commerce_api_gateway.dart';
import '../../core/network/session_controller.dart';
import '../../models/support_ticket.dart';

class SupportController extends ChangeNotifier {
  SupportController._();

  static final SupportController instance = SupportController._();

  final List<SupportTicket> _tickets = <SupportTicket>[
    SupportTicket(
      id: 'SUP-1042',
      category: 'Delivery',
      subject: 'Delivery timing question',
      message: 'Can I update the preferred delivery time for my active order?',
      createdAt: DateTime(2026, 8, 30, 10, 15),
      status: SupportTicketStatus.awaitingCustomer,
      messages: <SupportTicketMessage>[
        SupportTicketMessage(
          senderType: 'customer',
          message: 'Can I update the preferred delivery time for my active order?',
          sentAt: DateTime(2026, 8, 30, 10, 15),
        ),
      ],
    ),
  ];

  bool _refreshing = false;
  String? _lastError;
  DateTime? _lastRemoteRefreshAt;

  List<SupportTicket> get tickets => List.unmodifiable(_tickets);
  int get openCount =>
      _tickets.where((ticket) => ticket.status != SupportTicketStatus.resolved).length;
  bool get isRefreshing => _refreshing;
  String? get lastError => _lastError;
  DateTime? get lastRemoteRefreshAt => _lastRemoteRefreshAt;

  SupportTicket createTicket({
    required String category,
    required String subject,
    required String message,
    String? orderId,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();
    final ticket = SupportTicket(
      id: 'SUP-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
      category: category,
      subject: subject.trim(),
      message: message.trim(),
      orderId: orderId,
      createdAt: now,
      messages: <SupportTicketMessage>[
        SupportTicketMessage(
          senderType: 'customer',
          message: message.trim(),
          sentAt: now,
        ),
      ],
    );
    _tickets.insert(0, ticket);
    notifyListeners();
    return ticket;
  }

  Future<SupportTicket> submitTicket({
    required String category,
    required String subject,
    required String message,
    String? orderId,
    CommerceApiGateway? gateway,
  }) async {
    if (!_canUseRemote) {
      return createTicket(
        category: category,
        subject: subject,
        message: message,
        orderId: orderId,
      );
    }

    try {
      final response = await (gateway ?? HttpCommerceApiGateway()).createSupportTicket(
        category: category,
        subject: subject.trim(),
        message: message.trim(),
        orderNumber: orderId,
      );
      final data = _map(response['data']);
      if (data == null) {
        throw const ApiException(
          kind: ApiFailureKind.invalidResponse,
          message: 'Support response was incomplete.',
        );
      }
      final ticket = _ticketFromRemote(data);
      _upsert(ticket);
      _lastError = null;
      _lastRemoteRefreshAt = DateTime.now();
      notifyListeners();
      return ticket;
    } on ApiException catch (error) {
      _lastError = error.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshFromServer({CommerceApiGateway? gateway}) async {
    if (!_canUseRemote || _refreshing) {
      return;
    }
    _refreshing = true;
    _lastError = null;
    notifyListeners();
    try {
      final response = await (gateway ?? HttpCommerceApiGateway()).fetchSupportTickets();
      final data = response['data'];
      if (data is List) {
        final remote = <SupportTicket>[];
        for (final raw in data) {
          final map = _map(raw);
          if (map != null) {
            remote.add(_ticketFromRemote(map));
          }
        }
        _tickets
          ..clear()
          ..addAll(remote);
      }
      _lastRemoteRefreshAt = DateTime.now();
    } on ApiException catch (error) {
      _lastError = error.message;
    } catch (_) {
      _lastError = 'Support requests could not be refreshed.';
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  Future<SupportTicket> replyToTicket(
    SupportTicket ticket,
    String message, {
    CommerceApiGateway? gateway,
  }) async {
    final clean = message.trim();
    if (clean.isEmpty) {
      return ticket;
    }

    if (_canUseRemote && ticket.serverId != null) {
      try {
        final response = await (gateway ?? HttpCommerceApiGateway()).replySupportTicket(
          ticketId: ticket.serverId!,
          message: clean,
        );
        final data = _map(response['data']);
        if (data == null) {
          throw const ApiException(
            kind: ApiFailureKind.invalidResponse,
            message: 'Support reply could not be loaded.',
          );
        }
        final updated = _ticketFromRemote(data);
        _upsert(updated);
        _lastError = null;
        notifyListeners();
        return updated;
      } on ApiException catch (error) {
        _lastError = error.message;
        notifyListeners();
        rethrow;
      }
    }

    final now = DateTime.now();
    final updated = ticket.copyWith(
      status: SupportTicketStatus.open,
      lastReplyAt: now,
      messages: <SupportTicketMessage>[
        ...ticket.messages,
        SupportTicketMessage(senderType: 'customer', message: clean, sentAt: now),
      ],
    );
    _upsert(updated);
    notifyListeners();
    return updated;
  }

  void restoreForSession(List<SupportTicket> tickets) {
    _tickets
      ..clear()
      ..addAll(tickets);
    notifyListeners();
  }

  bool get _canUseRemote => ApiEnvironment.isRemoteConfigured &&
      SessionController.instance.isAuthenticated &&
      SessionController.instance.hasUsableRemoteToken;

  void _upsert(SupportTicket ticket) {
    final index = _tickets.indexWhere((item) =>
        (ticket.serverId != null && item.serverId == ticket.serverId) || item.id == ticket.id);
    if (index >= 0) {
      _tickets[index] = ticket;
    } else {
      _tickets.insert(0, ticket);
    }
  }

  SupportTicket _ticketFromRemote(Map<String, dynamic> json) {
    final messages = <SupportTicketMessage>[];
    final rawMessages = json['messages'];
    if (rawMessages is List) {
      for (final raw in rawMessages) {
        final map = _map(raw);
        if (map == null) {
          continue;
        }
        final body = map['message'] as String?;
        final sentAt = DateTime.tryParse(map['sent_at'] as String? ?? '');
        if (body == null || sentAt == null) {
          continue;
        }
        messages.add(
          SupportTicketMessage(
            serverId: (map['id'] as num?)?.toInt(),
            senderType: map['sender_type'] as String? ?? 'customer',
            message: body,
            sentAt: sentAt.toLocal(),
          ),
        );
      }
    }
    final createdAt = DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ??
        DateTime.now();
    final lastReplyAt = DateTime.tryParse(json['last_reply_at'] as String? ?? '')?.toLocal();
    final firstMessage = messages.isNotEmpty ? messages.first.message : '';
    return SupportTicket(
      id: json['ticket_number'] as String? ?? 'SUP-${json['id']}',
      serverId: (json['id'] as num?)?.toInt(),
      category: json['category'] as String? ?? 'General',
      subject: json['subject'] as String? ?? 'Support request',
      message: firstMessage,
      orderId: json['order_number'] as String?,
      createdAt: createdAt,
      lastReplyAt: lastReplyAt,
      status: _statusFromServer(json['status'] as String?),
      priority: json['priority'] as String? ?? 'normal',
      messages: messages,
    );
  }

  SupportTicketStatus _statusFromServer(String? status) {
    switch (status) {
      case 'waiting_customer':
        return SupportTicketStatus.awaitingCustomer;
      case 'resolved':
      case 'closed':
        return SupportTicketStatus.resolved;
      default:
        return SupportTicketStatus.open;
    }
  }

  Map<String, dynamic>? _map(Object? value) {
    if (value is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(value);
  }

  @visibleForTesting
  void resetForTesting() {
    _tickets
      ..clear()
      ..add(
        SupportTicket(
          id: 'SUP-1042',
          category: 'Delivery',
          subject: 'Delivery timing question',
          message: 'Can I update the preferred delivery time for my active order?',
          createdAt: DateTime(2026, 8, 30, 10, 15),
          status: SupportTicketStatus.awaitingCustomer,
          messages: <SupportTicketMessage>[
            SupportTicketMessage(
              senderType: 'customer',
              message: 'Can I update the preferred delivery time for my active order?',
              sentAt: DateTime(2026, 8, 30, 10, 15),
            ),
          ],
        ),
      );
    _refreshing = false;
    _lastError = null;
    _lastRemoteRefreshAt = null;
    notifyListeners();
  }
}
