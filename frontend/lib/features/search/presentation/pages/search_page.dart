import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/item_card.dart';
import '../../providers/search_provider.dart';

/// Screen #10: Search page with clear button, "Results for ...", and results list
class SearchPage extends ConsumerStatefulWidget {
  final String fridgeId;

  const SearchPage({super.key, required this.fridgeId});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

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
      backgroundColor: const Color(0xFFFAFCF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF0F172A)),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/fridges/${widget.fridgeId}');
              }
            },
          ),
        ),
        title: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Search for items...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14.5),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (val) {
              ref.read(searchQueryProvider.notifier).state = val;
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (query.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Text(
                    'Results for "$query"',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
              if (results.isEmpty && query.isNotEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60.0),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                        SizedBox(height: 12),
                        Text(
                          'No items found',
                          style: TextStyle(
                            color: Color(0xFF64748B),
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
              else
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 4),
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
