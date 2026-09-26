// lib/widgets/location_info_card.dart
// Floating card on the MapScreen showing the current lat/lng and GPS accuracy.
// Phase 4 will add distance walked and elapsed time to this card.
// This widget is purely presentational — data comes from LocationProvider via the screen.

import 'package:flutter/material.dart';

class LocationInfoCard extends StatelessWidget {
  const LocationInfoCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  final double latitude;
  final double longitude;
  // accuracy is nullable because the first fix may not have it yet.
  final double? accuracy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      // Card theme is set globally in app_theme.dart: elevation 0, radius 12.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coordinate row — uses the 'data' text style (tabular figures keep
            // numbers from shifting as GPS values change).
            _CoordRow(label: 'LAT', value: latitude.toStringAsFixed(5)),
            const SizedBox(height: 4),
            _CoordRow(label: 'LNG', value: longitude.toStringAsFixed(5)),

            // Accuracy line — only shown when the value is available.
            if (accuracy != null) ...[
              const SizedBox(height: 4),
              Text(
                'Accuracy ±${accuracy!.toStringAsFixed(0)} m',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Private helper for a labelled coordinate row.
class _CoordRow extends StatelessWidget {
  const _CoordRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // titleSmall is wired to AppTextStyles.data in app_theme.dart,
        // which has FontFeature.tabularFigures() — numbers are fixed-width.
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}
