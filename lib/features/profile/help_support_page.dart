import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../models/support_ticket.dart';
import '../support/support_controller.dart';
import '../support/support_request_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SupportController.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Help & support')),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;
                return ListView(
                  key: const PageStorageKey<String>('help-support-scroll'),
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    10,
                    horizontal,
                    MediaQuery.paddingOf(context).bottom + 28,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SupportHero(
                              openCount: controller.openCount,
                              onNewRequest: () => Navigator.of(context).push(
                                AppPageRoute(page: const SupportRequestPage()),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Support channels',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 9),
                            const _SupportChannels(),
                            const SizedBox(height: 20),
                            Text(
                              'Your requests',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 9),
                            if (controller.tickets.isEmpty)
                              const _EmptyTickets()
                            else
                              ...controller.tickets.map(
                                (ticket) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _TicketCard(ticket: ticket),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Text(
                              'Frequently asked questions',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const _FaqList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SupportHero extends StatelessWidget {
  final int openCount;
  final VoidCallback onNewRequest;

  const _SupportHero({required this.openCount, required this.onNewRequest});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(alpha: .76),
            scheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: scheme.primary,
                child: Icon(Icons.support_agent_rounded, color: scheme.onPrimary, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We are here to help',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      openCount == 0
                          ? 'No open requests. Start a support request whenever you need help.'
                          : '$openCount active ${openCount == 1 ? 'request' : 'requests'} currently in your support center.',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('new-support-request'),
            onPressed: onNewRequest,
            icon: const Icon(Icons.add_comment_rounded),
            label: const Text('New support request'),
          ),
        ],
      ),
    );
  }
}

class _SupportChannels extends StatelessWidget {
  const _SupportChannels();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final channels = const [
      (Icons.chat_bubble_outline_rounded, 'Live chat', 'Typically within minutes'),
      (Icons.mail_outline_rounded, 'Email support', 'Best for detailed questions'),
      (Icons.schedule_rounded, 'Support hours', 'Daily • 8:00 AM–10:00 PM'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 540;
        final width = compact ? constraints.maxWidth : (constraints.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: channels
              .map(
                (channel) => SizedBox(
                  width: width,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(channel.$1, color: scheme.primary, size: 21),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(channel.$2, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(channel.$3, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
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
                child: Text(ticket.subject, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  ticket.status.label,
                  style: TextStyle(color: scheme.onSecondaryContainer, fontSize: 9.5, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${ticket.id} • ${ticket.category}',
            style: TextStyle(color: scheme.primary, fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(ticket.message, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11.5, height: 1.45)),
        ],
      ),
    );
  }
}

class _EmptyTickets extends StatelessWidget {
  const _EmptyTickets();

  @override
  Widget build(BuildContext context) {
    return Text('No support requests yet.', style: Theme.of(context).textTheme.bodyMedium);
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const faqs = <(String, String)>[
      ('Where can I track my order?', 'Open My orders, select the order, and use the integrated tracking timeline.'),
      ('How do I change a delivery address?', 'Use Delivery addresses in Account to add, edit, remove, or choose a default address.'),
      ('How do promotions work?', 'Apply an eligible promo in Cart or Checkout. Savings appear separately in the order summary.'),
      ('Where are my saved products?', 'Wishlist keeps products saved from Home, Product listings, and Product details.'),
    ];
    return Material(
      key: const Key('support-faq-surface'),
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(faqs.length, (index) {
          final faq = faqs[index];
          return Column(
            children: [
              ExpansionTile(
                key: ValueKey<String>('support-faq-$index'),
                tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                title: Text(faq.$1, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(faq.$2, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11.5, height: 1.5)),
                  ),
                ],
              ),
              if (index != faqs.length - 1) const Divider(height: 1),
            ],
          );
        }),
      ),
    );
  }
}
