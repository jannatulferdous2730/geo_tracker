// lib/widgets/permission_prompt.dart
// Maps each LocationIssue value to the correct message and action button.
// Copy and action text come from design.md section 11.
// This widget is purely presentational — it receives callbacks from the screen.
// No provider access here: the screen owns the logic, this widget owns the look.

import 'package:flutter/material.dart';
import '../services/location_service.dart';

class PermissionPrompt extends StatelessWidget {
  const PermissionPrompt({
    super.key,
    required this.issue,
    required this.onPrimaryAction,
    // onSecondaryAction is only shown for permissionDeniedForever (two buttons).
    this.onSecondaryAction,
  });

  final LocationIssue issue;

  // Called when the user taps the primary button (Allow / Open Settings / Retry).
  final VoidCallback onPrimaryAction;

  // Called when the user taps "Allow location" after being sent to App Settings.
  // Only used for permissionDeniedForever.
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _configFor(issue);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon — large, uses the theme's error or primary color.
          Icon(
            config.icon,
            size: 64,
            color: config.useErrorColor
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),

          // Headline — uses titleLarge (AppTextStyles.title).
          Text(
            config.headline,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Body text — uses bodyMedium (AppTextStyles.body).
          Text(
            config.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Primary action button — minimum 48 dp touch target (design.md section 5).
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPrimaryAction,
              child: Text(config.primaryLabel),
            ),
          ),

          // Secondary button — only for permissionDeniedForever.
          if (onSecondaryAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSecondaryAction,
                child: const Text('Allow location'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Returns the display config for each issue type.
  // All copy is taken directly from design.md section 11 tables.
  static _PromptConfig _configFor(LocationIssue issue) {
    switch (issue) {
      case LocationIssue.serviceDisabled:
        return const _PromptConfig(
          icon: Icons.location_off_outlined,
          useErrorColor: false,
          headline: 'Location is turned off',
          body:
              'Enable location in your device settings so GeoTracker can find you.',
          primaryLabel: 'Open location settings',
        );

      case LocationIssue.permissionDenied:
        return const _PromptConfig(
          icon: Icons.gps_off_outlined,
          useErrorColor: false,
          headline: 'Location permission needed',
          body:
              'GeoTracker needs location access to show where you are and track your route.',
          primaryLabel: 'Allow location',
        );

      case LocationIssue.permissionDeniedForever:
        return const _PromptConfig(
          icon: Icons.lock_outlined,
          useErrorColor: true,
          headline: 'Permission permanently denied',
          body:
              'Location access is blocked. Open app settings, tap Permissions → Location, and choose "Allow while using app".',
          primaryLabel: 'Open app settings',
        );

      case LocationIssue.timeout:
        return const _PromptConfig(
          icon: Icons.signal_wifi_statusbar_connected_no_internet_4_outlined,
          useErrorColor: false,
          headline: 'Could not get a fix',
          body:
              'Move to an open area or check that GPS is enabled, then try again.',
          primaryLabel: 'Retry',
        );
    }
  }
}

// Internal data class — not exported.
class _PromptConfig {
  const _PromptConfig({
    required this.icon,
    required this.useErrorColor,
    required this.headline,
    required this.body,
    required this.primaryLabel,
  });

  final IconData icon;
  final bool useErrorColor; // true = error red, false = primary teal
  final String headline;
  final String body;
  final String primaryLabel;
}
