enum SupportTicketStatus { open, awaitingCustomer, resolved }

class SupportTicket {
  final String id;
  final String category;
  final String subject;
  final String message;
  final DateTime createdAt;
  final SupportTicketStatus status;

  const SupportTicket({
    required this.id,
    required this.category,
    required this.subject,
    required this.message,
    required this.createdAt,
    this.status = SupportTicketStatus.open,
  });
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
