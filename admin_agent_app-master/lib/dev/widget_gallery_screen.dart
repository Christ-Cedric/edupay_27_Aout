import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/widgets/widgets.dart';
import '../core/widgets/widgets.dart';

/// Galerie de composants du design-system, à usage de développement
/// uniquement — sert à valider visuellement la fidélité au prototype et à
/// la charte graphique avant de construire les écrans réels. Ne fait pas
/// partie du parcours applicatif final.
class WidgetGalleryScreen extends StatefulWidget {
  const WidgetGalleryScreen({super.key});

  @override
  State<WidgetGalleryScreen> createState() => _WidgetGalleryScreenState();
}

class _WidgetGalleryScreenState extends State<WidgetGalleryScreen> {
  bool _selectedA = true;
  bool _selectedB = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Galerie de composants (dev)'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const AppLogo(fontSize: 30),
          const SizedBox(height: AppSpacing.lg),
          const Text('Titres', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          const Text('Titre H1', style: AppTextStyles.h1),
          const Text('Titre H2', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Boutons (min. 48×48 px)',
            style: AppTextStyles.sectionLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(label: 'Action principale', onPressed: () {}),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Action secondaire',
            variant: AppButtonVariant.green,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Contour',
            variant: AppButtonVariant.outline,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Danger',
            variant: AppButtonVariant.danger,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Cartes', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          const AppCard(child: Text('Carte neutre', style: AppTextStyles.body)),
          const SizedBox(height: AppSpacing.sm),
          const AppCard(
            variant: AppCardVariant.success,
            child: Text('Carte succès', style: AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.sm),
          const AppCard(
            variant: AppCardVariant.solidGreen,
            child: Text('Carte verte pleine', style: AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('KPI', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          const KpiGrid(
            tiles: [
              KpiTile(value: '47', label: 'Familles actives'),
              KpiTile(
                value: '1,2M F',
                label: 'Total collecté',
                valueColor: AppColors.green,
              ),
              KpiTile(value: '89%', label: 'Taux cotisation'),
              KpiTile(
                value: '5',
                label: 'Impayés',
                valueColor: AppColors.danger,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Tags', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          const Wrap(
            spacing: AppSpacing.sm,
            children: [
              AppTag(label: 'Actif', variant: AppTagVariant.green),
              AppTag(label: 'En attente', variant: AppTagVariant.gold),
              AppTag(label: 'Impayé', variant: AppTagVariant.danger),
              AppTag(label: 'Info', variant: AppTagVariant.info),
              AppTag(label: 'Neutre'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Ligne clé-valeur', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          const AppCard(
            child: Column(
              children: [
                KeyValueRow(label: 'Plan', value: 'Hebdomadaire'),
                KeyValueRow(
                  label: 'Cotisé',
                  value: '24 700 FCFA',
                  valueColor: AppColors.gold,
                ),
                KeyValueRow(
                  label: 'Progression',
                  value: '62%',
                  valueColor: AppColors.green,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Progression', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          const AppProgressBar(progress: .62),
          const SizedBox(height: AppSpacing.xl),
          const Text('Avatar à initiales', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          const Row(
            children: [
              InitialsAvatar(name: 'Aminata Kabore'),
              SizedBox(width: AppSpacing.sm),
              InitialsAvatar(
                name: 'Konate Ali',
                backgroundColor: AppColors.gold,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Notice d’alerte', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          const AlertNotice(
            title: '5 familles - impayés +14 jours',
            subtitle: 'Action requise - relancer les agents',
            variant: AlertNoticeVariant.danger,
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Champ de saisie', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          const AppTextField(
            label: 'Nom et prénom',
            hintText: 'Ouedraogo Marie',
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Cartes sélectionnables',
            style: AppTextStyles.sectionLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          SelectableCard(
            title: 'Volontaire (commission uniquement)',
            selected: _selectedA,
            onTap: () => setState(() {
              _selectedA = true;
              _selectedB = false;
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          SelectableCard(
            title: 'Rémunéré (indemnité fixe)',
            selected: _selectedB,
            onTap: () => setState(() {
              _selectedA = false;
              _selectedB = true;
            }),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Toast', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Succès',
                  variant: AppButtonVariant.green,
                  onPressed: () =>
                      showAppToast(context, 'Kit changé avec succès !'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Erreur',
                  variant: AppButtonVariant.danger,
                  onPressed: () => showAppToast(
                    context,
                    'Échec du paiement',
                    type: AppToastType.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('État vide', style: AppTextStyles.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          const AppCard(
            child: EmptyState(
              icon: Icons.groups_outlined,
              title: 'Aucun enfant ajouté',
              subtitle: 'Ajoutez au moins un enfant pour continuer',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Écrans transversaux plein écran',
            style: AppTextStyles.sectionLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: 'Chargement',
                expanded: false,
                onPressed: () =>
                    _pushFullScreen(context, const LoadingScreen()),
              ),
              AppButton(
                label: 'Erreur',
                expanded: false,
                variant: AppButtonVariant.danger,
                onPressed: () => _pushFullScreen(
                  context,
                  ErrorScreen(onRetry: () => Navigator.of(context).pop()),
                ),
              ),
              AppButton(
                label: 'Session expirée',
                expanded: false,
                variant: AppButtonVariant.outline,
                onPressed: () => _pushFullScreen(
                  context,
                  SessionExpiredScreen(
                    onReconnect: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              AppButton(
                label: 'Maintenance',
                expanded: false,
                variant: AppButtonVariant.outline,
                onPressed: () => _pushFullScreen(
                  context,
                  MaintenanceScreen(
                    onContactSupport: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              AppButton(
                label: 'Mise à jour',
                expanded: false,
                variant: AppButtonVariant.outline,
                onPressed: () => _pushFullScreen(
                  context,
                  UpdateRequiredScreen(
                    onUpdate: () => Navigator.of(context).pop(),
                    onLater: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        items: const [
          AppBottomNavItem(icon: Icons.dashboard, label: 'Dashboard'),
          AppBottomNavItem(icon: Icons.groups, label: 'Familles'),
          AppBottomNavItem(icon: Icons.payments, label: 'Finances'),
          AppBottomNavItem(icon: Icons.settings, label: 'Params'),
        ],
        currentIndex: 0,
        onTap: (_) {},
      ),
    );
  }

  void _pushFullScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}
