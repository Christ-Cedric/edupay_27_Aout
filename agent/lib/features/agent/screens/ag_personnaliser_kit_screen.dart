import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/data/catalog_data.dart';
import '../../../core/services/api_client.dart';

class AgPersonnaliserKitScreen extends StatefulWidget {
  final String selectedClass;
  
  const AgPersonnaliserKitScreen({super.key, required this.selectedClass});

  @override
  State<AgPersonnaliserKitScreen> createState() => _AgPersonnaliserKitScreenState();
}

class _AgPersonnaliserKitScreenState extends State<AgPersonnaliserKitScreen> {
  final Map<String, int> _quantities = {};
  bool _isLoading = true;
  List<CatalogCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      final response = await ApiClient.get('/catalog/articles');
      final data = response['data'] as List<dynamic>;
      if (data.isEmpty) {
        _categories = CatalogData.categories;
      } else {
        final Map<String, List<CatalogItem>> grouped = {};
        for (var item in data) {
          final cat = item['category'] as String? ?? 'Divers';
          final catalogItem = CatalogItem(
            id: item['id'] as String,
            name: item['label'] as String,
            unitPrice: item['unit_price'] as int,
            unit: item['unit'] as String? ?? 'Unité',
          );
          grouped.putIfAbsent(cat, () => []).add(catalogItem);
        }
        _categories = grouped.entries.map((e) => CatalogCategory(name: e.key, items: e.value)).toList();
      }
    } catch (e) {
      _categories = CatalogData.categories;
    }
    _initializeDefaultQuantities();
    if (mounted) setState(() => _isLoading = false);
  }

  void _initializeDefaultQuantities() {
    for (final category in _categories) {
      for (final item in category.items) {
        final qty = item.getQtyForClass(widget.selectedClass);
        if (qty > 0) {
          _quantities[item.id] = qty;
        } else {
          _quantities[item.id] = 0;
        }
      }
    }
  }

  int get _totalPrice {
    int total = 0;
    for (final category in _categories) {
      for (final item in category.items) {
        total += (_quantities[item.id] ?? 0) * item.unitPrice;
      }
    }
    return total;
  }
  
  void _validateSelection() {
    final List<Map<String, dynamic>> selectedItems = [];
    
    for (final category in _categories) {
      for (final item in category.items) {
        final qty = _quantities[item.id] ?? 0;
        if (qty > 0) {
          selectedItems.add({
            'name': item.name,
            'qty': qty,
            'price': item.unitPrice,
            'supply_id': item.id,
          });
        }
      }
    }
    
    Navigator.pop(context, selectedItems);
  }

  void _updateQty(String itemId, int delta) {
    setState(() {
      final current = _quantities[itemId] ?? 0;
      final newValue = current + delta;
      if (newValue >= 0) {
        _quantities[itemId] = newValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: AppColors.white70, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personnaliser le kit',
                        style: GoogleFonts.montserrat(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Classe: ${widget.selectedClass}',
                        style: GoogleFonts.montserrat(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des catégories
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 12),
                      child: Text(
                        category.name.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...category.items.map((item) => _buildItemCard(item)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // Footer fixe
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          border: const Border(top: BorderSide(color: AppColors.divider)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Estimé',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                      fontSize: 14,
                      color: AppColors.white70,
                    ),
                  ),
                  Text(
                    '$_totalPrice FCFA',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              EduButton.green(
                'Valider la sélection',
                onPressed: _validateSelection,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(CatalogItem item) {
    final qty = _quantities[item.id] ?? 0;
    final isSelected = qty > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0x0F00C853) : AppColors.white05,
        border: Border.all(
          color: isSelected ? AppColors.green.withValues(alpha: 0.3) : AppColors.borderDefault,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Info article
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w700,
                    color: isSelected ? AppColors.white : AppColors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.unitPrice} F / ${item.unit}',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                    fontSize: 11,
                    color: AppColors.white50,
                  ),
                ),
              ],
            ),
          ),
          
          // Sélecteur quantité
          Row(
            children: [
              _buildQtyButton(
                icon: Icons.remove,
                onTap: () => _updateQty(item.id, -1),
                isEnabled: qty > 0,
              ),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text(
                  qty.toString(),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.white : AppColors.white50,
                  ),
                ),
              ),
              _buildQtyButton(
                icon: Icons.add,
                onTap: () => _updateQty(item.id, 1),
                isEnabled: true,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap, required bool isEnabled}) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.white10 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isEnabled ? AppColors.white35 : AppColors.borderDefault,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? AppColors.white : AppColors.white35,
        ),
      ),
    );
  }
}
