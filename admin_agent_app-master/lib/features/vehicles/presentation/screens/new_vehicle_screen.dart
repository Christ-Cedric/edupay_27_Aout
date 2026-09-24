import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/app_button.dart';
import '../../../../core/theme/widgets/app_header.dart';
import '../../../../core/theme/widgets/app_text_field.dart';
import '../../../../core/theme/widgets/app_toast.dart';
import '../providers/vehicles_providers.dart';

class NewVehicleScreen extends ConsumerStatefulWidget {
  const NewVehicleScreen({super.key});

  @override
  ConsumerState<NewVehicleScreen> createState() => _NewVehicleScreenState();
}

class _NewVehicleScreenState extends ConsumerState<NewVehicleScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final List<String> _images = [];
  bool _isAvailable = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _addImage() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _images.add(url);
        _imageUrlController.clear();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    if (name.isEmpty || price == null || price < 0) {
      showAppToast(
        context,
        'Veuillez remplir le nom et le prix valide.',
        type: AppToastType.error,
      );
      return;
    }

    await ref.read(vehicleCreateControllerProvider.notifier).create(
          name: name,
          description: description.isNotEmpty ? description : null,
          price: price,
          images: _images,
          isAvailable: _isAvailable,
        );

    if (!mounted) return;

    if (ref.read(vehicleCreateControllerProvider).hasError) {
      showAppToast(context, 'Erreur lors de la création', type: AppToastType.error);
      return;
    }

    showAppToast(context, 'Moyen de déplacement créé avec succès');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(vehicleCreateControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: 'Ajouter un Engin',
        onBack: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ListView(
          children: [
            const Text('Nouveau moyen de déplacement', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Renseignez les détails de l\'engin pour le rendre disponible dans l\'espace client.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Nom de l\'engin *',
              controller: _nameController,
              hintText: 'ex: Moto Yamaha YBR 125, Tricycle KAVAKI',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Prix (FCFA) *',
              controller: _priceController,
              keyboardType: TextInputType.number,
              hintText: 'ex: 650000',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 3,
              hintText: 'Spécifications techniques, autonomie, garanties...',
              enabled: !submitting,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Text('Disponible immédiatement :', style: AppTextStyles.bodyStrong),
                const Spacer(),
                Switch(
                  value: _isAvailable,
                  activeColor: AppColors.gold,
                  onChanged: submitting
                      ? null
                      : (val) => setState(() => _isAvailable = val),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Images de l\'engin', style: AppTextStyles.bodyStrong),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: '',
                    controller: _imageUrlController,
                    hintText: 'Coller l\'URL de l\'image (https://...)',
                    enabled: !submitting,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: submitting ? null : _addImage,
                  icon: const Icon(Icons.add_photo_alternate, color: AppColors.gold),
                  tooltip: 'Ajouter l\'image',
                ),
              ],
            ),
            if (_images.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < _images.length; i++)
                    Chip(
                      backgroundColor: AppColors.surfaceBorder,
                      avatar: CircleAvatar(
                        backgroundImage: NetworkImage(_images[i]),
                      ),
                      label: Text('Image ${i + 1}', style: const TextStyle(color: Colors.white)),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                      onDeleted: () => _removeImage(i),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Enregistrer l\'engin',
              loading: submitting,
              onPressed: submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
