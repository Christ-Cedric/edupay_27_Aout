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
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/models/transport_vehicle.dart';
import '../providers/vehicles_providers.dart';

class EditVehicleScreen extends ConsumerStatefulWidget {
  final String vehicleId;

  const EditVehicleScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends ConsumerState<EditVehicleScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  List<String> _images = [];
  bool _isAvailable = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _imageUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _initFields(TransportVehicle vehicle) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = vehicle.name;
    _descriptionController.text = vehicle.description ?? '';
    _priceController.text = vehicle.price.toInt().toString();
    _images = List.from(vehicle.images);
    _isAvailable = vehicle.isAvailable;
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

  Future<void> _submit(TransportVehicle current) async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    if (name.isEmpty || price == null || price < 0) {
      showAppToast(
        context,
        'Veuillez remplir le nom et un prix valide',
        type: AppToastType.error,
      );
      return;
    }

    final updated = current.copyWith(
      name: name,
      description: description.isNotEmpty ? description : null,
      price: price,
      images: _images,
      isAvailable: _isAvailable,
    );

    await ref.read(vehicleEditControllerProvider.notifier).save(updated);

    if (!mounted) return;

    if (ref.read(vehicleEditControllerProvider).hasError) {
      showAppToast(context, 'Erreur lors de la mise à jour', type: AppToastType.error);
      return;
    }

    showAppToast(context, 'Engin mis à jour avec succès');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(vehicleDetailProvider(widget.vehicleId));
    final submitting = ref.watch(vehicleEditControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppHeader(
        title: 'Modifier l\'engin',
        onBack: () => context.pop(),
      ),
      body: vehicleAsync.when(
        data: (vehicle) {
          _initFields(vehicle);

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ListView(
              children: [
                const Text('Editer le moyen de déplacement', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Nom de l\'engin *',
                  controller: _nameController,
                  enabled: !submitting,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Prix (FCFA) *',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  enabled: !submitting,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  maxLines: 3,
                  enabled: !submitting,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Text('Disponible :', style: AppTextStyles.bodyStrong),
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
                        hintText: 'Coller l\'URL de l\'image',
                        enabled: !submitting,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: submitting ? null : _addImage,
                      icon: const Icon(Icons.add_photo_alternate, color: AppColors.gold),
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
                  label: 'Enregistrer les modifications',
                  loading: submitting,
                  onPressed: submitting ? null : () => _submit(vehicle),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingScreen(),
        error: (err, stack) =>
            ErrorScreen(onRetry: () => ref.invalidate(vehicleDetailProvider(widget.vehicleId))),
      ),
    );
  }
}
