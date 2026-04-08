import 'package:flutter/material.dart';

class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 180, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: const BorderRadius.vertical(top: Radius.circular(12)))),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 180, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                const SizedBox(height: 8),
                Container(height: 14, width: 260, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                const SizedBox(height: 8),
                Container(height: 14, width: 140, color: Theme.of(context).colorScheme.surfaceContainerHighest),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
