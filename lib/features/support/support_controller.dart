import 'package:flutter/foundation.dart';

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
    ),
  ];

  List<SupportTicket> get tickets => List.unmodifiable(_tickets);
  int get openCount => _tickets.where((ticket) => ticket.status != SupportTicketStatus.resolved).length;

  SupportTicket createTicket({
    required String category,
    required String subject,
    required String message,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();
    final ticket = SupportTicket(
      id: 'SUP-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
      category: category,
      subject: subject.trim(),
      message: message.trim(),
      createdAt: now,
    );
    _tickets.insert(0, ticket);
    notifyListeners();
    return ticket;
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
        ),
      );
    notifyListeners();
  }
}
