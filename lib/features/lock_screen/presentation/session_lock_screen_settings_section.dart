import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/lock_screen/application/lock_screen_providers.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/domain/app_settings.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';

/// Settings block for F20 session lock-screen / notification preference.
class SessionLockScreenSettingsSection extends ConsumerStatefulWidget {
  const SessionLockScreenSettingsSection({super.key, required this.settings});

  final AppSettings settings;

  @override
  ConsumerState<SessionLockScreenSettingsSection> createState() =>
      _SessionLockScreenSettingsSectionState();
}

class _SessionLockScreenSettingsSectionState
    extends ConsumerState<SessionLockScreenSettingsSection> {
  bool? _permissionGranted;
  bool _loadingPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshPermission());
  }

  Future<void> _refreshPermission() async {
    final driver = ref.read(sessionSurfaceDriverProvider);
    try {
      final granted = await driver.isPermissionGranted();
      if (!mounted) return;
      setState(() {
        _permissionGranted = granted;
        _loadingPermission = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _permissionGranted = false;
        _loadingPermission = false;
      });
    }
  }

  Future<void> _openSettings() async {
    await ref.read(sessionSurfaceDriverProvider).openSystemSettings();
    await _refreshPermission();
    await ref.read(sessionLockScreenControllerProvider).refreshPermission();
  }

  Future<void> _retryPermission() async {
    final driver = ref.read(sessionSurfaceDriverProvider);
    final granted = await driver.requestPermission();
    if (!mounted) return;
    setState(() => _permissionGranted = granted);
    await ref
        .read(sessionLockScreenControllerProvider)
        .setPermissionGranted(granted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final settings = widget.settings;
    final showPermissionHint =
        !_loadingPermission && _permissionGranted == false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          UiStrings.sessionLockScreenSectionTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        SwitchListTile(
          key: const Key('session_lock_screen_enabled_switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text(UiStrings.sessionLockScreenEnabledLabel),
          subtitle: Text(UiStrings.sessionLockScreenEnabledHint, style: muted),
          value: settings.sessionLockScreenEnabled,
          onChanged: (value) {
            ref
                .read(settingsControllerProvider.notifier)
                .setSessionLockScreenEnabled(value);
          },
        ),
        if (showPermissionHint) ...[
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            key: const Key('session_lock_screen_permission_hint'),
            UiStrings.sessionLockScreenPermissionDenied,
            style: muted,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: [
              AppSecondaryButton(
                key: const Key('session_lock_screen_retry_permission'),
                compact: true,
                onPressed: _retryPermission,
                label: UiStrings.sessionLockScreenRetryPermission,
              ),
              AppSecondaryButton(
                key: const Key('session_lock_screen_open_settings'),
                compact: true,
                onPressed: _openSettings,
                label: UiStrings.sessionLockScreenOpenSystemSettings,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
