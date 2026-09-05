import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/constants/app_constants.dart';
import 'core/persistence/customer_session_persistence.dart';
import 'core/scroll/app_scroll_behavior.dart';
import 'core/storefront/storefront_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/splash/splash_page.dart';

class EcommerceApp extends StatefulWidget {
  const EcommerceApp({super.key});

  @override
  State<EcommerceApp> createState() => _EcommerceAppState();
}

class _EcommerceAppState extends State<EcommerceApp> with WidgetsBindingObserver {
  final ThemeController _themeController = ThemeController.instance;
  final CustomerSessionPersistence _sessionPersistence =
      CustomerSessionPersistence.instance;
  final StorefrontController _storefront = StorefrontController.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await _themeController.load();
    await _storefront.start();
    await _sessionPersistence.load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _storefront.refresh();
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _sessionPersistence.save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          scrollBehavior: const AppScrollBehavior(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeController.themeMode,
          themeAnimationDuration: const Duration(milliseconds: 420),
          themeAnimationCurve: Curves.easeOutCubic,
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();
            final dark = Theme.of(context).brightness == Brightness.dark;
            final overlay = SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
              systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
              statusBarBrightness: dark ? Brightness.dark : Brightness.light,
            );

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlay,
              child: MediaQuery.withClampedTextScaling(
                minScaleFactor: 0.90,
                maxScaleFactor: 1.20,
                child: AnimatedBuilder(
                  animation: _storefront,
                  child: child,
                  builder: (context, appChild) {
                    final minimumVersion = _storefront.settingString(
                      'mobile',
                      'minimum_app_version',
                      AppConstants.appVersion,
                    );
                    final updateRequired = _versionIsNewer(
                      minimumVersion,
                      AppConstants.appVersion,
                    );
                    if (updateRequired) {
                      return _StorefrontControlScreen(
                        icon: Icons.system_update_alt_rounded,
                        title: 'Update required',
                        message: _storefront.settingString(
                          'mobile',
                          'update_message',
                          'A newer version of DCX Online Store is required to continue.',
                        ),
                        actionLabel: 'Update app',
                        onAction: () => _openUpdateUrl(_storefront),
                      );
                    }

                    if (_storefront.settingBool('mobile', 'maintenance_mode', false)) {
                      return _StorefrontControlScreen(
                        icon: Icons.engineering_rounded,
                        title: 'Store maintenance',
                        message: _storefront.settingString(
                          'mobile',
                          'maintenance_message',
                          'We are making a few improvements. Please try again shortly.',
                        ),
                        actionLabel: _storefront.isRefreshing ? 'Checking…' : 'Check again',
                        onAction: _storefront.isRefreshing
                            ? null
                            : () => _storefront.refresh(force: true),
                      );
                    }
                    return appChild ?? const SizedBox.shrink();
                  },
                ),
              ),
            );
          },
          home: const SplashPage(),
        );
      },
    );
  }
}

bool _versionIsNewer(String requiredVersion, String currentVersion) {
  List<int> parts(String value) => value
      .split(RegExp(r'[^0-9]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => int.tryParse(part) ?? 0)
      .toList(growable: false);

  final required = parts(requiredVersion);
  final current = parts(currentVersion);
  final length = required.length > current.length ? required.length : current.length;
  for (var index = 0; index < length; index++) {
    final left = index < required.length ? required[index] : 0;
    final right = index < current.length ? current[index] : 0;
    if (left == right) continue;
    return left > right;
  }
  return false;
}

Future<void> _openUpdateUrl(StorefrontController storefront) async {
  final raw = storefront.settingString('mobile', 'update_url', '');
  final uri = Uri.tryParse(raw.trim());
  if (uri != null && uri.hasScheme) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _StorefrontControlScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;

  const _StorefrontControlScreen({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: scheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: .08),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 34, color: scheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onAction,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(actionLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

