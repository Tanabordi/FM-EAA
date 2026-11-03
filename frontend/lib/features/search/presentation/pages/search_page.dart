import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/item_card.dart';
import '../../providers/search_provider.dart';

// TODO(screen #10 Search): ช่องค้นหา (มีปุ่มล้าง ✕), "Results for "<คำค้น>"", การ์ดผลลัพธ์ (เช่น "Avocados (Veggies)", จำนวน, ป้ายสถานะ, จำนวนวันที่เหลือ). เฟรมซ้ำเป็นแค่ state (ค้นจากแท็บ Fridge / Freezer, ไม่พบ ฯลฯ)
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for items...',
            border: InputBorder.none,
            filled: false,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            ref.read(searchQueryProvider.notifier).state = val;
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (query.isNotEmpty) ...[
                Text(
                  'Results for "$query"',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (results.isEmpty && query.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48.0),
                    child: Text(
                      'No items found',
                      style: TextStyle(color: theme.colorScheme.outline, fontSize: 16),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return ItemCard(
                        name: '${item.name} (${item.category})',
                        quantityText: '${item.quantity.toInt()} ${item.unit}',
                        status: item.status,
                        statusText: item.statusText,
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
