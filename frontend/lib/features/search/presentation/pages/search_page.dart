import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/item_card.dart';
import '../../providers/search_provider.dart';

/// Screen #10: Search page matching Figma node 376:543, 383:77 & uploaded screenshot
class SearchPage extends ConsumerStatefulWidget {
  final String fridgeId;

  const SearchPage({super.key, required this.fridgeId});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controller with current search query if present
    _searchController.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider(widget.fridgeId));

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3), // Figma exact background #F6FBF3
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar: Back Button + "Search" Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: const Color(0xFFD9E2D7), width: 1.2),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1B241E)),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          context.pop();
                        } else {
                          context.go('/fridges/${widget.fridgeId}');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A201C),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Floating Pill Search Bar with Shadow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEFE8), // Figma exact search bar background #EAEFE8
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x45000000), // Prominent deep drop shadow matching Image 2
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A201C),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search for items',
                    hintStyle: const TextStyle(
                      color: Color(0xFF4A5A4E),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 18, right: 12),
                      child: Icon(Icons.search, color: Color(0xFF3A4A3E), size: 22),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 52),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD0DDD0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Color(0xFF334155)),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
                              },
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onChanged: (val) {
                    ref.read(searchQueryProvider.notifier).state = val;
                  },
                ),
              ),
            ),
            // "Results for ..." Section Header
            if (query.trim().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                child: Text(
                  'Results for "$query"',
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A201C),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
            // Results list or Empty state
            Expanded(
              child: results.isEmpty && query.trim().isNotEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60.0),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                            SizedBox(height: 12),
                            Text(
                              'No items found',
                              style: TextStyle(
                                color: Color(0xFF5C665F),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Try searching with a different keyword',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24, top: 2),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        final displayQuantity = item.unit.contains('·') || item.unit.contains('pieces')
                            ? '${item.quantity > 0 ? (item.quantity == item.quantity.toInt() ? item.quantity.toInt() : item.quantity) : ''} ${item.unit}'.trim()
                            : '${item.quantity == item.quantity.toInt() ? item.quantity.toInt() : item.quantity} ${item.unit}';

                        return ItemCard(
                          name: '${item.name} (${item.category.capitalize()})',
                          quantityText: displayQuantity,
                          status: item.status,
                          statusText: item.statusText,
                          imagePath: item.imagePath,
                          onTap: () => context.push('/fridges/${widget.fridgeId}/items/${item.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
