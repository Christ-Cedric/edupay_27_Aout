import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_dropdown_field.dart';
import '../../../../core/theme/widgets/tap_target.dart';
import '../../../supplies/domain/models/supply.dart';
import '../../domain/models/kit.dart';

/// Une ligne de fourniture en cours d'édition (création ou modification de
/// kit) — un contrôleur par champ éditable individuellement (catégorie,
/// article, quantité, unité, prix unitaire), reflétant `KitItem`.
class KitItemFormEntry {
  KitItemFormEntry({KitItem? item})
    : category = TextEditingController(text: item?.category ?? ''),
      label = TextEditingController(text: item?.label ?? ''),
      quantity = TextEditingController(
        text: (item?.quantity ?? 1).toString(),
      ),
      unit = TextEditingController(text: item?.unit ?? 'unité'),
      unitPrice = TextEditingController(
        text: (item?.unitPrice ?? 0).toStringAsFixed(0),
      );

  /// Pré-remplie depuis une fourniture du catalogue réutilisable — reste
  /// éditable ensuite comme une ligne saisie à la main.
  KitItemFormEntry.fromSupply(Supply supply)
    : category = TextEditingController(text: supply.category),
      label = TextEditingController(text: supply.label),
      quantity = TextEditingController(text: '1'),
      unit = TextEditingController(text: supply.unit),
      unitPrice = TextEditingController(text: supply.unitPrice.toStringAsFixed(0));

  final TextEditingController category;
  final TextEditingController label;
  final TextEditingController quantity;
  final TextEditingController unit;
  final TextEditingController unitPrice;

  void dispose() {
    category.dispose();
    label.dispose();
    quantity.dispose();
    unit.dispose();
    unitPrice.dispose();
  }

  /// `null` si la ligne est incomplète ou invalide.
  KitItem? toKitItem() {
    final categoryText = category.text.trim();
    final labelText = label.text.trim();
    final unitText = unit.text.trim();
    final quantityValue = int.tryParse(quantity.text.trim());
    final unitPriceValue = double.tryParse(unitPrice.text.trim());
    if (categoryText.isEmpty ||
        labelText.isEmpty ||
        unitText.isEmpty ||
        quantityValue == null ||
        quantityValue <= 0 ||
        unitPriceValue == null ||
        unitPriceValue < 0) {
      return null;
    }
    return KitItem(
      category: categoryText,
      label: labelText,
      quantity: quantityValue,
      unit: unitText,
      unitPrice: unitPriceValue,
    );
  }
}

/// Éditeur de fournitures d'un kit — une carte par ligne (catégorie, article,
/// quantité, unité, prix unitaire), total en direct calculé à partir des
/// lignes valides (`computeItemsTotal`), jamais saisi à la main (le prix du
/// kit est toujours dérivé de son détail, cf. `Kit.price`).
class KitItemEditorList extends StatelessWidget {
  const KitItemEditorList({
    super.key,
    required this.entries,
    required this.enabled,
    required this.supplies,
    required this.onAddEntry,
    required this.onRemove,
    required this.onChanged,
  });

  final List<KitItemFormEntry> entries;
  final bool enabled;
  final List<Supply> supplies;
  final ValueChanged<KitItemFormEntry> onAddEntry;
  final ValueChanged<int> onRemove;
  final VoidCallback onChanged;

  Future<void> _addArticle(BuildContext context) async {
    final entry = await _pickSupplyDialog(context, supplies);
    if (entry != null) onAddEntry(entry);
  }

  @override
  Widget build(BuildContext context) {
    final total = computeItemsTotal(
      entries.map((e) => e.toKitItem()).whereType<KitItem>().toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _KitItemRow(
              entry: entries[i],
              enabled: enabled,
              removable: entries.length > 1,
              onRemove: () => onRemove(i),
              onChanged: onChanged,
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TapTarget(
            onTap: enabled ? () => _addArticle(context) : null,
            child: Text(
              '+ Ajouter un article',
              style: AppTextStyles.tag.copyWith(color: AppColors.green),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total (calculé)', style: AppTextStyles.bodyStrong),
            Text(
              '${total.toStringAsFixed(0)} FCFA',
              style: AppTextStyles.bodyStrong.copyWith(color: AppColors.gold),
            ),
          ],
        ),
      ],
    );
  }
}

/// Choisir une fourniture du catalogue (pré-remplit la ligne) ou une
/// fourniture personnalisée (ligne vide, saisie libre comme avant).
Future<KitItemFormEntry?> _pickSupplyDialog(
  BuildContext context,
  List<Supply> supplies,
) {
  Supply? selected;
  return showDialog<KitItemFormEntry>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Ajouter un article', style: AppTextStyles.bodyStrong),
        content: AppDropdownField<Supply?>(
          label: 'Fourniture',
          value: selected,
          items: [
            const DropdownMenuItem(
              child: Text('Fourniture personnalisée'),
            ),
            ...supplies.map(
              (supply) => DropdownMenuItem(
                value: supply,
                child: Text(
                  '${supply.category} — ${supply.label}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: (value) => setState(() => selected = value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              selected == null
                  ? KitItemFormEntry()
                  : KitItemFormEntry.fromSupply(selected!),
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    ),
  );
}

class _KitItemRow extends StatelessWidget {
  const _KitItemRow({
    required this.entry,
    required this.enabled,
    required this.removable,
    required this.onRemove,
    required this.onChanged,
  });

  final KitItemFormEntry entry;
  final bool enabled;
  final bool removable;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _field(
                  entry.category,
                  'Catégorie',
                  TextInputType.text,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                flex: 3,
                child: _field(entry.label, 'Article', TextInputType.text),
              ),
              if (removable)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.danger,
                    size: 18,
                  ),
                  onPressed: enabled ? onRemove : null,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _field(
                  entry.quantity,
                  'Qté',
                  TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _field(entry.unit, 'Unité', TextInputType.text),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                flex: 2,
                child: _field(
                  entry.unitPrice,
                  'Prix unitaire',
                  TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    TextInputType keyboardType,
  ) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: AppTextStyles.caption,
      ),
      onChanged: (_) => onChanged(),
    );
  }
}
