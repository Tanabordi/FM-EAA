import 'package:flutter/material.dart';

/// 2-Column Grid Card for My Fridges Page
class FridgeCard extends StatelessWidget {
  final String name;
  final String description;
  final String itemsCountText;
  final bool isPersonal;
  final int memberCount;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;

  const FridgeCard({
    super.key,
    required this.name,
    required this.description,
    required this.itemsCountText,
    this.isPersonal = true,
    this.memberCount = 1,
    this.onTap,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🧊', style: TextStyle(fontSize: 28)),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: onMoreOptions,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    itemsCountText,
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPersonal ? 'Personal' : '$memberCount members',
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

