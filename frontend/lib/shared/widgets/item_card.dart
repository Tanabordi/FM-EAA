import 'package:flutter/material.dart';
import '../../core/theme/freshness_colors.dart';
import 'status_badge.dart';

/// ItemCard displaying an ingredient inside a fridge zone matching Figma node 11:178 & 275:17
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5.5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEFE8), // Figma exact card background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Row(
              children: [
                // Food Image Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 68,
                    height: 68,
                    color: const Color(0xFFDDE4DC),
                    child: _buildFoodImage(),
                  ),
                ),
                const SizedBox(width: 14),
                // Food Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.5,
                          color: Color(0xFF1A201C),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        quantityText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF5C665F),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          StatusBadge(status: status),
                          const SizedBox(width: 8),
                          Text(
                            statusText,
                            style: const TextStyle(
                              color: Color(0xFF5C665F),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildFoodImage() {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.asset(
        imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final lower = name.toLowerCase();
    IconData iconData = Icons.restaurant_rounded;
    Color iconColor = const Color(0xFF2E6A44);
    Color bgColor = const Color(0xFFDDE4DC);

    if (lower.contains('spinach') || lower.contains('cabbage') || lower.contains('veggie')) {
      iconData = Icons.eco_rounded;
      bgColor = const Color(0xFFD5E4D4);
      iconColor = const Color(0xFF2E7D32);
    } else if (lower.contains('strawberr') || lower.contains('apple') || lower.contains('berry')) {
      iconData = Icons.favorite_rounded;
      bgColor = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFE53935);
    } else if (lower.contains('avocado')) {
      iconData = Icons.spa_rounded;
      bgColor = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF388E3C);
    } else if (lower.contains('milk') || lower.contains('drink') || lower.contains('juice') || lower.contains('beverage')) {
      iconData = Icons.local_drink_rounded;
      bgColor = const Color(0xFFE3F2FD);
      iconColor = const Color(0xFF1E88E5);
    } else if (lower.contains('pork') || lower.contains('beef') || lower.contains('chicken') || lower.contains('steak')) {
      iconData = Icons.lunch_dining_rounded;
      bgColor = const Color(0xFFFBE9E7);
      iconColor = const Color(0xFFD84315);
    }

    return Container(
      color: bgColor,
      alignment: Alignment.center,
      child: Icon(iconData, color: iconColor, size: 30),
    );
  }
}
