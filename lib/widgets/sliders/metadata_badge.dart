import 'package:budget_for_retirement/theme/app_colors.dart';
import 'package:budget_for_retirement/util/config_metadata.dart';
import 'package:flutter/material.dart';

/// A compact pill badge showing metadata (date and source) for a config value.
/// Displays the date at a glance; tap to reveal source in a dialog.
class MetadataBadge extends StatelessWidget {
  const MetadataBadge({required this.metadata});

  final ConfigMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasSource = metadata.source != null && metadata.source!.isNotEmpty;

    return GestureDetector(
      onTap: hasSource ? () => showSourceDialog(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: colors.backgroundDepth3,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.borderDepth1, width: 0.5),
        ),
        child: Text(
          metadata.date ?? '?',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: colors.textColor3,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }

  void showSourceDialog(BuildContext context) {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.backgroundDepth2,
        title: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: colors.accentPrimary),
            const SizedBox(width: 8),
            Text('Source',
                style: TextStyle(fontSize: 16, color: colors.textColor1)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (metadata.date != null) ...[
              Text(
                'Updated: ${metadata.date}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textColor1,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (metadata.source != null)
              SelectableText(
                metadata.source!,
                style: TextStyle(fontSize: 12, color: colors.textColor2),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close', style: TextStyle(color: colors.accentPrimary)),
          ),
        ],
      ),
    );
  }
}
