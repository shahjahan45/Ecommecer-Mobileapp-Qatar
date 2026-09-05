import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/network/api_models.dart';
import '../../models/support_ticket.dart';
import 'support_controller.dart';

class SupportTicketDetailsPage extends StatefulWidget {
  final SupportTicket ticket;

  const SupportTicketDetailsPage({super.key, required this.ticket});

  @override
  State<SupportTicketDetailsPage> createState() => _SupportTicketDetailsPageState();
}

class _SupportTicketDetailsPageState extends State<SupportTicketDetailsPage> {
  final _reply = TextEditingController();
  late SupportTicket _ticket;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final messages = _ticket.messages.isEmpty
        ? <SupportTicketMessage>[
            SupportTicketMessage(
              senderType: 'customer',
              message: _ticket.message,
              sentAt: _ticket.createdAt,
            ),
          ]
        : _ticket.messages;

    return Scaffold(
      appBar: AppBar(title: Text(_ticket.id)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _ticket.subject,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            _StatusPill(status: _ticket.status),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '${_ticket.category}${_ticket.orderId == null ? '' : ' • ${_ticket.orderId}'}',
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Priority: ${_ticket.priority.toUpperCase()}',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Conversation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 10),
                  ...messages.map(
                    (message) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MessageBubble(message: message),
                    ),
                  ),
                ],
              ),
            ),
            if (_ticket.status != SupportTicketStatus.resolved)
              Container(
                padding: EdgeInsets.fromLTRB(
                  12,
                  10,
                  12,
                  MediaQuery.paddingOf(context).bottom + 10,
                ),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(top: BorderSide(color: scheme.outlineVariant)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('support-reply-field'),
                        controller: _reply,
                        enabled: !_sending,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Reply to DCX Support…',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      key: const Key('support-reply-send'),
                      onPressed: _sending ? null : _sendReply,
                      icon: _sending
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendReply() async {
    final message = _reply.text.trim();
    if (message.isEmpty) {
      return;
    }
    setState(() => _sending = true);
    try {
      final updated =
          await SupportController.instance.replyToTicket(_ticket, message);
      if (!mounted) {
        return;
      }
      setState(() {
        _ticket = updated;
        _reply.clear();
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }
}

class _StatusPill extends StatelessWidget {
  final SupportTicketStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: scheme.onSecondaryContainer,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final SupportTicketMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final admin = message.isAdmin;
    return Align(
      alignment: admin ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 590),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: admin
                ? scheme.surfaceContainerHighest
                : scheme.primaryContainer.withValues(alpha: .72),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(admin ? 5 : 16),
              topRight: Radius.circular(admin ? 16 : 5),
              bottomLeft: const Radius.circular(16),
              bottomRight: const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                admin ? 'DCX Support' : 'You',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(message.message, style: const TextStyle(fontSize: 12, height: 1.45)),
              const SizedBox(height: 6),
              Text(
                _formatDate(message.sentAt),
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    String two(int input) => input.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} ${two(value.hour)}:${two(value.minute)}';
  }
}
