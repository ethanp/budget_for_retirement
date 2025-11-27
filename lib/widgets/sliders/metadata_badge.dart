import 'package:budget_for_retirement/util/config_metadata.dart';
import 'package:flutter/material.dart';

/// A compact pill badge showing metadata (date and source) for a config value.
/// Displays the date at a glance; tap to reveal source in a dialog.
class MetadataBadge extends StatelessWidget {
  const MetadataBadge({required this.metadata});

  final ConfigMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final hasSource = metadata.source != null && metadata.source!.isNotEmpty;

    return GestureDetector(
      onTap: hasSource ? () => showSourceDialog(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blueGrey[200]!, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSource ? Icons.info_outline : Icons.calendar_today,
              size: 10,
              color: Colors.blueGrey[600],
            ),
            const SizedBox(width: 3),
            Text(
              metadata.date ?? '?',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[700],
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: Colors.blueGrey[700]),
            const SizedBox(width: 8),
            const Text('Source', style: TextStyle(fontSize: 16)),
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
                  color: Colors.blueGrey[800],
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (metadata.source != null)
              SelectableText(
                metadata.source!,
                style: TextStyle(fontSize: 12, color: Colors.blueGrey[600]),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

