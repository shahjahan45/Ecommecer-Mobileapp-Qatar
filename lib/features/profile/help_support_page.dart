import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/storefront/storefront_controller.dart';
import '../../models/support_ticket.dart';
import '../support/support_controller.dart';
import '../support/support_request_page.dart';
import '../support/support_ticket_details_page.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final controller = SupportController.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.refreshFromServer());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & support'),
        actions: [
          IconButton(
            tooltip: 'Refresh support requests',
            onPressed: controller.isRefreshing ? null : () => controller.refreshFromServer(),
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;
                return RefreshIndicator(
                  onRefresh: () => controller.refreshFromServer(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                syncing: controller.isRefreshing,
                                onNewRequest: _newRequest,
                              ),
                              if (controller.lastError != null) ...[
                                const SizedBox(height: 10),
                                _SyncNotice(message: controller.lastError!),
                              ],
                              const SizedBox(height: 18),
                              Text(
                                'Support channels',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 9),
                              _SupportChannels(),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Your requests',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ),
                                  if (controller.lastRemoteRefreshAt != null)
                                    Text(
                                      'Synced with DCX Core',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 9),
                              if (controller.tickets.isEmpty)
                                const _EmptyTickets()
                              else
                                ...controller.tickets.map(
                                  (ticket) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _TicketCard(
                                      ticket: ticket,
                                      onTap: () => _openTicket(ticket),
                                    ),
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
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _newRequest() async {
    final result = await Navigator.of(context).push<SupportTicket>(
      AppPageRoute(page: const SupportRequestPage()),
    );
    if (result != null) {
      await controller.refreshFromServer();
    }
  }

  Future<void> _openTicket(SupportTicket ticket) async {
    await Navigator.of(context).push(
      AppPageRoute(page: SupportTicketDetailsPage(ticket: ticket)),
    );
    await controller.refreshFromServer();
  }
}

class _SupportHero extends StatelessWidget {
  final int openCount;
  final bool syncing;
  final VoidCallback onNewRequest;

  const _SupportHero({
    required this.openCount,
    required this.syncing,
    required this.onNewRequest,
  });

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
                child: syncing
                    ? Padding(
                        padding: const EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      )
                    : Icon(
                        Icons.support_agent_rounded,
                        color: scheme.onPrimary,
                        size: 25,
                      ),
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
                          : '$openCount active ${openCount == 1 ? 'request' : 'requests'} with DCX Customer Care.',
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

class _SyncNotice extends StatelessWidget {
  final String message;
  const _SyncNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: scheme.error, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '$message Your local support history remains available.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10.5),
            ),
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
    final storefront = StorefrontController.instance;
    return AnimatedBuilder(
      animation: storefront,
      builder: (context, _) {
        final email = storefront.settingString(
          'general',
          'support_email',
          'support@datacubex.com',
        );
        final phone = storefront.settingString(
          'general',
          'support_phone',
          '+974 0000 0000',
        );
        final hours = storefront.settingString(
          'general',
          'support_hours',
          'Daily • 8:00 AM–10:00 PM',
        );
        final channels = <_SupportChannelData>[
          _SupportChannelData(
            Icons.mail_outline_rounded,
            'Email support',
            email,
            Uri(scheme: 'mailto', path: email),
          ),
          _SupportChannelData(
            Icons.call_outlined,
            'Call support',
            phone,
            Uri(scheme: 'tel', path: phone.replaceAll(' ', '')),
          ),
          _SupportChannelData(
            Icons.schedule_rounded,
            'Support hours',
            hours,
            null,
          ),
        ];
        return _SupportChannelGrid(channels: channels);
      },
    );
  }
}

class _SupportChannelData {
  final IconData icon;
  final String title;
  final String caption;
  final Uri? uri;

  const _SupportChannelData(this.icon, this.title, this.caption, this.uri);
}

class _SupportChannelGrid extends StatelessWidget {
  final List<_SupportChannelData> channels;
  const _SupportChannelGrid({required this.channels});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 540;
        final width = compact ? constraints.maxWidth : (constraints.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: channels.map((channel) {
            final card = Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(channel.icon, color: scheme.primary, size: 21),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          channel.title,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          channel.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (channel.uri != null) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.open_in_new_rounded, size: 15, color: scheme.primary),
                  ],
                ],
              ),
            );
            return SizedBox(
              width: width,
              child: channel.uri == null
                  ? card
                  : InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      onTap: () => launchUrl(channel.uri!, mode: LaunchMode.externalApplication),
                      child: card,
                    ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final preview = ticket.messages.isNotEmpty
        ? ticket.messages.last.message
        : ticket.message;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
                      style: TextStyle(
                        color: scheme.onSecondaryContainer,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '${ticket.id} • ${ticket.category}${ticket.orderId == null ? '' : ' • ${ticket.orderId}'}',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTickets extends StatelessWidget {
  const _EmptyTickets();

  @override
  Widget build(BuildContext context) {
    return Text(
      'No support requests yet.',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList();

  @override
  Widget build(BuildContext context) {
    final storefront = StorefrontController.instance;
    return AnimatedBuilder(
      animation: storefront,
      builder: (context, _) {
        final liveFaqs = storefront.content('faqs');
        if (liveFaqs != null && liveFaqs.trim().isNotEmpty) {
          return _PublishedFaqContent(content: liveFaqs);
        }
        return const _FallbackFaqContent();
      },
    );
  }
}

class _PublishedFaqContent extends StatelessWidget {
  final String content;
  const _PublishedFaqContent({required this.content});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('support-faq-surface'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        content,
        style: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 11.5,
          height: 1.55,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FallbackFaqContent extends StatelessWidget {
  const _FallbackFaqContent();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const faqs = <(String, String)>[
      ('Where can I track my order?', 'Open My orders, select the order, and use the integrated tracking timeline.'),
      ('How do I ask about an order?', 'Open the order and tap Order support. The order number is attached automatically.'),
      ('How do support replies work?', 'Admin replies appear inside the ticket conversation after you refresh the support center.'),
      ('How do I change a delivery address?', 'Use Delivery addresses in Account to add, edit, remove, or choose a default address.'),
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
                title: Text(
                  faq.$1,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      faq.$2,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                        height: 1.5,
                      ),
                    ),
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

