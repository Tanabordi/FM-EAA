import '../../../../shared/widgets/app_back_button.dart';
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
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
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
                  AppBackButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/fridges/${widget.fridgeId}');
                      }
                    },
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
            // Floating Pill Search Bar with Shadow matching uploaded image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEFE8), // Figma exact search bar background #EAEFE8
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x45000000), // Prominent deep drop shadow matching image
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
                            padding: const EdgeInsets.only(right: 12.0),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
                              },
                              child: Center(
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDFE4DC), // Circular grey badge matching image
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 15,
                                    color: Color(0xFF414942),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 52),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
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
            // iOS Bottom Home Indicator Bar
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A201C),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
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
