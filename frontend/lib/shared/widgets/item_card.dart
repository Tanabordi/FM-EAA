import 'package:flutter/material.dart';
import '../../core/theme/freshness_colors.dart';
import 'status_badge.dart';

/// ItemCard displaying an ingredient inside a fridge zone matching Screen #16 mockup.
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
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: const Color(0xFFEAEFE8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 72,
                  height: 72,
                  color: Colors.white,
                  child: imagePath != null && imagePath!.isNotEmpty
                      ? Image.asset(
                          imagePath!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.fastfood, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.fastfood, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF181D17),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      quantityText,
                      style: const TextStyle(
                        color: Color(0xFF414941),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(status: status),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Color(0xFF414941),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
