enum SupportTicketStatus { open, awaitingCustomer, resolved }

class SupportTicketMessage {
  final int? serverId;
  final String senderType;
  final String message;
  final DateTime sentAt;

  const SupportTicketMessage({
    this.serverId,
    required this.senderType,
    required this.message,
    required this.sentAt,
  });

  bool get isAdmin => senderType == 'admin';
}

class SupportTicket {
  final String id;
  final int? serverId;
  final String category;
  final String subject;
  final String message;
  final DateTime createdAt;
  final DateTime? lastReplyAt;
  final SupportTicketStatus status;
  final String priority;
  final String? orderId;
  final List<SupportTicketMessage> messages;

  const SupportTicket({
    required this.id,
    this.serverId,
    required this.category,
    required this.subject,
    required this.message,
    required this.createdAt,
    this.lastReplyAt,
    this.status = SupportTicketStatus.open,
    this.priority = 'normal',
    this.orderId,
    this.messages = const <SupportTicketMessage>[],
  });

  SupportTicket copyWith({
    int? serverId,
    SupportTicketStatus? status,
    String? priority,
    String? orderId,
    DateTime? lastReplyAt,
    List<SupportTicketMessage>? messages,
  }) {
    return SupportTicket(
      id: id,
      serverId: serverId ?? this.serverId,
      category: category,
      subject: subject,
      message: message,
      createdAt: createdAt,
      lastReplyAt: lastReplyAt ?? this.lastReplyAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      orderId: orderId ?? this.orderId,
      messages: messages ?? this.messages,
    );
  }
}

extension SupportTicketStatusUi on SupportTicketStatus {
  String get label {
    switch (this) {
      case SupportTicketStatus.open:
        return 'Open';
      case SupportTicketStatus.awaitingCustomer:
        return 'Needs reply';
      case SupportTicketStatus.resolved:
        return 'Resolved';
    }
  }
}
