import 'package:flutter/material.dart';
import '../../core/theme/freshness_colors.dart';
import 'status_badge.dart';

/// ItemCard displaying an ingredient inside a fridge zone.
class ItemCard extends StatelessWidget {
  final String name;
  final String quantityText;
  final FreshnessStatus status;
  final String statusText;
  final String? imagePath;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.name,
    required this.quantityText,
    required this.status,
    required this.statusText,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imagePath != null && imagePath!.isNotEmpty
                    ? Image.asset(
                        imagePath!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.fastfood, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF181D17),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quantityText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: status, customLabel: statusText),
            ],
          ),
        ),
      ),
    );
  }
}
