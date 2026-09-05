import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/network/api_environment.dart';
import '../../core/network/session_controller.dart';
import '../../core/persistence/customer_session_persistence.dart';
import '../../core/sync/cloud_sync_controller.dart';
import 'address/address_book_controller.dart';

class DataSyncPage extends StatelessWidget {
  final CloudSyncController? controller;
  final SessionController? sessionController;
  final CustomerSessionPersistence? persistence;
  final AddressBookController? addressBook;

  const DataSyncPage({
    super.key,
    this.controller,
    this.sessionController,
    this.persistence,
    this.addressBook,
  });

  @override
  Widget build(BuildContext context) {
    final syncController = controller ?? CloudSyncController.instance;
    final session = sessionController ?? SessionController.instance;
    final localPersistence = persistence ?? CustomerSessionPersistence.instance;
    final addresses = addressBook ?? AddressBookController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Data & sync')),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            syncController,
            session,
            localPersistence,
            addresses,
          ]),
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;
                final bottom = MediaQuery.paddingOf(context).bottom + 28;
                return SingleChildScrollView(
                  key: const PageStorageKey<String>('data-sync-scroll'),
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, bottom),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SyncHero(controller: syncController),
                          const SizedBox(height: 12),
                          _SyncStatusCard(controller: syncController),
                          const SizedBox(height: 12),
                          _SessionSecurityCard(session: session),
                          const SizedBox(height: 12),
                          _LocalDataCard(
                            persistence: localPersistence,
                            addressCount: addresses.addresses.length,
                          ),
                          const SizedBox(height: 12),
                          const _ApiContractCard(),
                          const SizedBox(height: 14),
                          _ActionBar(controller: syncController),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SyncHero extends StatelessWidget {
  final CloudSyncController controller;

  const _SyncHero({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final local = controller.isLocalOnly;
    return Container(
      key: const Key('data-sync-hero'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.secondaryContainer.withValues(alpha: .72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: .85),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(
              local ? Icons.offline_bolt_rounded : Icons.cloud_done_rounded,
              color: scheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  local ? 'Offline-first by default' : 'Cloud sync ready',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  local
                      ? 'Your shopping activity stays available on this device. Connect a production API when your backend is ready.'
                      : 'This build is configured for authenticated API communication and customer-state synchronization.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStatusCard extends StatelessWidget {
  final CloudSyncController controller;

  const _SyncStatusCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = switch (controller.state) {
      CloudSyncState.checking => 'Checking connection',
      CloudSyncState.syncing => 'Sync in progress',
      CloudSyncState.success => 'Synced',
      CloudSyncState.ready => 'Remote API ready',
      CloudSyncState.error => 'Attention needed',
      CloudSyncState.localOnly => 'Local-only mode',
      CloudSyncState.idle => controller.isLocalOnly ? 'Local-only mode' : 'Ready to check',
    };

    return _SurfaceCard(
      title: 'Sync status',
      icon: Icons.sync_rounded,
      child: Column(
        children: [
          _InfoRow(label: 'Mode', value: controller.isLocalOnly ? 'Local demo' : 'Remote API'),
          _InfoRow(
            label: 'API host',
            value: controller.isLocalOnly ? 'Not configured' : ApiEnvironment.displayHost,
          ),
          _InfoRow(label: 'Status', value: status),
          _InfoRow(
            label: 'Local changes',
            value: controller.hasPendingLocalChanges ? 'Waiting to sync' : 'Up to date',
          ),
          _InfoRow(
            label: 'Last remote sync',
            value: _formatDate(controller.lastRemoteSyncAt),
            showDivider: false,
          ),
          if (controller.message != null || controller.lastError != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: controller.lastError == null
                    ? scheme.primaryContainer.withValues(alpha: .55)
                    : scheme.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                controller.lastError ?? controller.message!,
                style: TextStyle(
                  color: controller.lastError == null
                      ? scheme.onPrimaryContainer
                      : scheme.onErrorContainer,
                  fontSize: 11.5,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionSecurityCard extends StatelessWidget {
  final SessionController session;

  const _SessionSecurityCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final current = session.session;
    return _SurfaceCard(
      title: 'Session security',
      icon: Icons.security_rounded,
      child: Column(
        children: [
          _InfoRow(
            label: 'Customer session',
            value: current.isAuthenticated
                ? current.demo
                    ? 'Demo session'
                    : 'Authenticated'
                : 'Guest / local',
          ),
          _InfoRow(label: 'Account', value: current.email ?? 'Not signed in'),
          const _InfoRow(
            label: 'Access tokens',
            value: 'Memory only',
            showDivider: false,
          ),
          const SizedBox(height: 10),
          Text(
            'Authentication secrets are never written to SharedPreferences. Persistent remote login should use an OS-backed secure vault when the production backend is connected.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _LocalDataCard extends StatelessWidget {
  final CustomerSessionPersistence persistence;
  final int addressCount;

  const _LocalDataCard({required this.persistence, required this.addressCount});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      title: 'Protected local continuity',
      icon: Icons.phonelink_lock_rounded,
      child: Column(
        children: [
          _InfoRow(label: 'Saved addresses', value: '$addressCount'),
          _InfoRow(
            label: 'Local snapshot',
            value: persistence.isHealthy ? 'Healthy' : 'Available',
          ),
          _InfoRow(
            label: 'Last device save',
            value: _formatDate(persistence.lastSavedAt),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _ApiContractCard extends StatelessWidget {
  const _ApiContractCard();

  @override
  Widget build(BuildContext context) {
    return const _SurfaceCard(
      title: 'Backend contract',
      icon: Icons.hub_outlined,
      child: Column(
        children: [
          _EndpointRow(method: 'POST', path: '/api/v1/auth/login'),
          _EndpointRow(method: 'GET', path: '/api/v1/health'),
          _EndpointRow(method: 'POST', path: '/api/v1/mobile/session/sync'),
          _EndpointRow(method: 'GET', path: '/api/v1/orders'),
          _EndpointRow(method: 'GET/POST', path: '/api/v1/support'),
          _EndpointRow(method: 'GET', path: '/api/v1/catalog', showDivider: false),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final CloudSyncController controller;

  const _ActionBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final check = OutlinedButton.icon(
          key: const Key('sync-check-connection'),
          onPressed: controller.isBusy ? null : controller.checkConnection,
          icon: const Icon(Icons.wifi_find_rounded, size: 18),
          label: const Text('Check connection'),
        );
        final sync = FilledButton.icon(
          key: const Key('sync-now-action'),
          onPressed: controller.isBusy ? null : controller.syncNow,
          icon: controller.isBusy
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync_rounded, size: 18),
          label: Text(controller.isLocalOnly ? 'Save locally' : 'Sync now'),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 48, child: sync),
              const SizedBox(height: 10),
              SizedBox(height: 48, child: check),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: SizedBox(height: 50, child: check)),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 50, child: sync)),
          ],
        );
      },
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SurfaceCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary, size: 20),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: scheme.outlineVariant),
      ],
    );
  }
}

class _EndpointRow extends StatelessWidget {
  final String method;
  final String path;
  final bool showDivider;

  const _EndpointRow({
    required this.method,
    required this.path,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                alignment: Alignment.center,
                child: Text(
                  method,
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: scheme.outlineVariant),
      ],
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return 'Not yet';
  final local = value.toLocal();
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month}/${local.year} ${local.hour}:$minute';
}
