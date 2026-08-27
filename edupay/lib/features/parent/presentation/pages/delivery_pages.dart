import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/parent_models.dart';
import '../../domain/school_catalogue.dart';
import '../parent_scope.dart';
import 'page_scaffold.dart';

const _kDefaultLatLng = LatLng(
  12.2529,
  -2.3620,
); // Koudougou, fallback tant qu'aucune position n'a été envoyée.

const _months = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

String _formatDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

String _money(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final fromEnd = raw.length - i;
    buffer.write(raw[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(' ');
  }
  return buffer.toString();
}

class DeliveryPage extends StatelessWidget {
  const DeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    if (!state.deliveryLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => state.loadDelivery());
    }
    final status = state.deliveryOrder.status;
    final savingsDone = state.progress >= 100;

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Suivi de commande',
          subtitle: 'Votre kit scolaire avance et reste visible.',
        ),
        _StepTile(
          done: true,
          title: 'Inscription validée',
          detail: _formatDate(state.deliveryOrder.registrationDate),
          onTap: () => context.push('/app/delivery/registration'),
        ),
        _StepTile(
          done: savingsDone,
          current: !savingsDone,
          title: 'Épargne en cours',
          detail: 'Objectif atteint à ${state.progress}%',
          onTap: () => context.push('/app/delivery/savings'),
        ),
        _StepTile(
          done: status.index >= DeliveryStatus.shipped.index,
          current: status == DeliveryStatus.preparation,
          title: 'Commande fournisseur',
          detail: '${_money(state.totalGoal)} FCFA · ${status.title}',
          onTap: () => context.push('/app/delivery/order'),
        ),
        _StepTile(
          done: status == DeliveryStatus.receiptConfirmed,
          current: status == DeliveryStatus.delivered,
          title: status == DeliveryStatus.receiptConfirmed
              ? 'Réception confirmée'
              : 'Confirmation de réception',
          detail: status == DeliveryStatus.receiptConfirmed
              ? 'Merci !'
              : 'Vérifier et signer la réception',
          // Toujours accessible : un clic ouvre la page où l'on coche les
          // fournitures livrées puis on signe à la main pour confirmer la
          // réception.
          onTap: () => context.push('/app/delivery/confirm-receipt'),
        ),
        const SizedBox(height: 8),
        ActionButton(
          label: 'Signaler un problème',
          icon: Icons.report_problem_outlined,
          secondary: true,
          onPressed: () => context.push('/app/delivery/report-issue'),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.done,
    required this.title,
    required this.detail,
    this.current = false,
    this.onTap,
  });

  final bool done;
  final bool current;
  final String title;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = done
        ? palette.accentGreen
        : current
        ? palette.accentYellow
        : palette.onSurface(.38);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        color: Colors.transparent,
        borderColor: palette.hairline,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              foregroundColor: Colors.white,
              child: Icon(
                done
                    ? Icons.check
                    : (current ? Icons.hourglass_top : Icons.circle_outlined),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: current
                          ? palette.accentYellow
                          : palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      style: TextStyle(color: palette.onSurface(.55)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only recap of the registration — no edit action here on purpose.
class RegistrationDetailPage extends StatelessWidget {
  const RegistrationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final profile = state.profile;

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Inscription validée',
          subtitle: 'Consultation uniquement.',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PARENT',
                style: TextStyle(
                  color: palette.accentGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              _InfoLine(label: 'Nom', value: state.displayName),
              _InfoLine(
                label: 'Téléphone',
                value: profile?.phone ?? state.phoneController.text,
              ),
              _InfoLine(
                label: 'Ville',
                value: profile?.city ?? state.cityController.text,
              ),
              _InfoLine(
                label: 'Quartier',
                value: profile?.district ?? state.districtController.text,
              ),
              Divider(height: 24, color: palette.hairline),
              _InfoLine(
                label: "Date d'inscription",
                value: _formatDate(state.deliveryOrder.registrationDate),
              ),
              _InfoLine(
                label: 'Formule choisie',
                value:
                    '${state.plan.title} · ${_money(state.installmentAmount)} FCFA/${state.plan.period}',
              ),
              _InfoLine(
                label: 'Montant total prévu',
                value: '${_money(state.totalGoal)} FCFA',
              ),
              Divider(height: 24, color: palette.hairline),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Statut',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: palette.accentGreen.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Validée',
                      style: TextStyle(
                        color: palette.accentGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const SectionLabel('Enfants inscrits'),
        for (final child in state.children)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: palette.accentGreen,
                    foregroundColor: Colors.white,
                    child: Text(child.firstName.substring(0, 1).toUpperCase()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.firstName,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${child.level} · ${child.kitSelection?.title ?? 'Kit à choisir'}',
                          style: TextStyle(color: palette.onSurface(.55)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_money(child.resolvedKit?.price ?? 0)} F',
                    style: TextStyle(
                      color: palette.accentGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: context.palette.onSurface(.6)),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

/// Commande fournisseur : articles agrégés, statut, et position de livraison
/// envoyée PAR LE PARENT (pas par le livreur) pour que l'agent sache où livrer.
class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final order = state.deliveryOrder;

    final aggregated =
        <String, ({String category, int quantity, int subtotal})>{};
    for (final child in state.children) {
      for (final item
          in child.resolvedKit?.lineItems ?? const <CatalogueArticle>[]) {
        final existing = aggregated[item.label];
        aggregated[item.label] = (
          category: item.category,
          quantity: (existing?.quantity ?? 0) + item.quantity,
          subtotal: (existing?.subtotal ?? 0) + item.subtotal,
        );
      }
    }

    final center = order.location != null
        ? LatLng(order.location!.lat, order.location!.lng)
        : _kDefaultLatLng;

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Commande fournisseur',
          subtitle: 'Articles, statut et livraison.',
        ),
        const SizedBox(height: 8),
        const SectionLabel('Articles commandés'),
        for (final entry in aggregated.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${entry.value.category} · ${entry.value.quantity} unité(s)',
                          style: TextStyle(
                            color: palette.onSurface(.55),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_money(entry.value.subtotal)} F',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        AppCard(
          color: palette.accentGreen.withValues(alpha: .12),
          borderColor: palette.accentGreen,
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Montant total',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${_money(state.totalGoal)} FCFA',
                style: TextStyle(
                  color: palette.accentGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Commande passée le ${_formatDate(order.orderDate)}',
            style: TextStyle(color: palette.onSurface(.55)),
          ),
        ),
        const SectionLabel('Position de livraison'),
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 180,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: order.location != null ? 14 : 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.edupay.parent',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: palette.danger,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (order.location != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Position envoyée : ${order.location!.address} à ${_formatTime(order.location!.sentAt)}',
              style: TextStyle(
                color: palette.accentGreen,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "Envoyez votre position pour que l'agent sache où livrer votre commande.",
              style: TextStyle(color: palette.onSurface(.55), fontSize: 12),
            ),
          ),
        ActionButton(
          label: 'Envoyer ma localisation',
          icon: Icons.my_location,
          onPressed: () => state.sendDeliveryLocation(),
        ),
        const SizedBox(height: 10),
        ActionButton(
          label: 'Voir la livraison à domicile',
          icon: Icons.home_work_outlined,
          secondary: true,
          onPressed: () => context.push('/app/delivery/home'),
        ),
      ],
    );
  }
}

/// Suivi pratique de la livraison à domicile : adresse, créneau et actions
/// utiles le jour du passage du livreur.
class HomeDeliveryPage extends StatelessWidget {
  const HomeDeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final order = state.deliveryOrder;
    final location = order.location;
    final isDelivered = order.status.index >= DeliveryStatus.delivered.index;
    final isOnTheWay = order.status == DeliveryStatus.outForDelivery;

    return ParentPageScaffold(
      children: [
        AppCard(
          color: isOnTheWay
              ? palette.accentYellow.withValues(alpha: .14)
              : palette.accentGreen.withValues(alpha: .10),
          borderColor: isOnTheWay ? palette.accentYellow : palette.accentGreen,
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: isOnTheWay
                    ? palette.accentYellow
                    : palette.accentGreen,
                foregroundColor: Colors.white,
                child: Icon(
                  isDelivered ? Icons.home_work : Icons.local_shipping,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDelivered
                          ? 'Colis livré à domicile'
                          : isOnTheWay
                          ? 'Le livreur arrive bientôt'
                          : 'Livraison à domicile',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDelivered
                          ? 'Vérifiez votre colis avant de confirmer la réception.'
                          : 'Créneau prévu : 08:00 - 18:00',
                      style: TextStyle(
                        color: palette.onSurface(.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionLabel('Progression de la livraison'),
        AppCard(
          child: Column(
            children: [
              _DeliveryMilestone(
                icon: Icons.inventory_2_outlined,
                title: 'Colis préparé par le fournisseur',
                done: order.status.index >= DeliveryStatus.shipped.index,
                palette: palette,
              ),
              _DeliveryMilestone(
                icon: Icons.local_shipping_outlined,
                title: 'Colis confié au livreur',
                done: order.status.index >= DeliveryStatus.outForDelivery.index,
                palette: palette,
              ),
              _DeliveryMilestone(
                icon: Icons.home_outlined,
                title: 'Livraison à votre domicile',
                done: isDelivered,
                palette: palette,
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionLabel('Adresse de livraison'),
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: palette.danger),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  location?.address ??
                      '${state.districtController.text}, ${state.cityController.text}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ActionButton(
          label: location == null
              ? 'Partager mon adresse'
              : 'Mettre à jour mon adresse',
          icon: Icons.my_location,
          onPressed: () => state.sendDeliveryLocation(),
        ),
        const SizedBox(height: 18),
        AppCard(
          color: palette.onSurface(.03),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: palette.accentYellow),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Gardez votre téléphone accessible et prévoyez une personne pour réceptionner le kit. '
                  'Après livraison, vérifiez les articles puis confirmez la réception dans l’application.',
                  style: TextStyle(
                    color: palette.onSurface(.65),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ActionButton(
          label: isDelivered
              ? 'Confirmer la réception'
              : 'Préparer la réception',
          icon: Icons.fact_check_outlined,
          secondary: true,
          onPressed: () => context.push('/app/delivery/confirm-receipt'),
        ),
      ],
    );
  }
}

class _DeliveryMilestone extends StatelessWidget {
  const _DeliveryMilestone({
    required this.icon,
    required this.title,
    required this.done,
    required this.palette,
    this.last = false,
  });

  final IconData icon;
  final String title;
  final bool done;
  final AppPalette palette;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = done ? palette.accentGreen : palette.onSurface(.35);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Icon(done ? Icons.check_circle : icon, color: color, size: 22),
              if (!last)
                Container(
                  width: 2,
                  height: 28,
                  color: color.withValues(alpha: .35),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 18),
          child: Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class ConfirmReceiptPage extends StatefulWidget {
  const ConfirmReceiptPage({super.key});

  @override
  State<ConfirmReceiptPage> createState() => _ConfirmReceiptPageState();
}

class _ConfirmReceiptPageState extends State<ConfirmReceiptPage> {
  /// Réception confirmée (envoyée).
  bool _confirmed = false;
  final Set<String> _checkedItems = <String>{};

  Widget _supplyCheck(
    AppPalette palette, {
    required String itemKey,
    required CatalogueArticle item,
    required bool confirmed,
  }) {
    final checked = _checkedItems.contains(itemKey);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: confirmed
            ? null
            : () => setState(() {
                if (checked) {
                  _checkedItems.remove(itemKey);
                } else {
                  _checkedItems.add(itemKey);
                }
              }),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(
              checked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: checked ? palette.accentGreen : palette.onSurface(.4),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('${item.quantity} x ${item.label}')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    // Réception déjà validée (statut backend) ou confirmée à l'instant sur
    // cette page : le bouton bascule alors sur « Réception confirmée ».
    final confirmed =
        _confirmed ||
        state.deliveryOrder.status == DeliveryStatus.receiptConfirmed;
    final supplyKeys = <String>[
      for (var childIndex = 0; childIndex < state.children.length; childIndex++)
        for (
          var itemIndex = 0;
          itemIndex <
              (state.children[childIndex].resolvedKit?.lineItems.length ?? 0);
          itemIndex++
        )
          '$childIndex:$itemIndex',
    ];

    // Récapitulatif : nombre total d'articles à travers tous les kits.
    var totalArticles = 0;
    for (final child in state.children) {
      for (final item
          in child.resolvedKit?.lineItems ?? const <CatalogueArticle>[]) {
        totalArticles += item.quantity;
      }
    }

    final canConfirm =
        supplyKeys.isNotEmpty &&
        _checkedItems.length == supplyKeys.length &&
        !confirmed;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            children: [
              const PageTitle(
                'Confirmation de réception',
                subtitle: 'Vérifiez et cochez chaque fourniture reçue.',
              ),

              // 1) Récapitulatif global de la commande.
              AppCard(
                color: palette.accentGreen.withValues(alpha: .08),
                borderColor: palette.accentGreen.withValues(alpha: .4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: palette.accentGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Récapitulatif de la commande',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _RecapRow(
                      label: 'Enfants',
                      value: '${state.children.length}',
                    ),
                    _RecapRow(
                      label: 'Articles au total',
                      value: '$totalArticles',
                    ),
                    _RecapRow(
                      label: 'Montant total',
                      value: '${_money(state.totalGoal)} FCFA',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2) Détail des articles par enfant (checklist).
              const SectionLabel('Détail par enfant'),
              for (
                var childIndex = 0;
                childIndex < state.children.length;
                childIndex++
              )
                if (state.children[childIndex].kitSelection != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ARTICLES DU ${state.children[childIndex].kitSelection!.title.toUpperCase()} - ${state.children[childIndex].level}',
                            style: TextStyle(
                              color: palette.accentGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (
                            var itemIndex = 0;
                            itemIndex <
                                (state
                                        .children[childIndex]
                                        .resolvedKit
                                        ?.lineItems
                                        .length ??
                                    0);
                            itemIndex++
                          )
                            _supplyCheck(
                              palette,
                              itemKey: '$childIndex:$itemIndex',
                              item: state
                                  .children[childIndex]
                                  .resolvedKit!
                                  .lineItems[itemIndex],
                              confirmed: confirmed,
                            ),
                        ],
                      ),
                    ),
                  ),

              // 3) Confirmation globale après vérification des fournitures.
              const SizedBox(height: 4),
              Text(
                'Cochez chaque fourniture après vérification. Le bouton sera disponible lorsque toute la commande sera contrôlée.',
                style: TextStyle(
                  color: palette.onSurface(.65),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        // Zone fixe hors défilement : validation simple, sans signature.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ActionButton(
                label: confirmed
                    ? 'Réception confirmée'
                    : 'Confirmer la réception',
                icon: confirmed ? Icons.verified : Icons.check_circle,
                onPressed: canConfirm
                    ? () async {
                        final ok = await state.confirmDeliveryReceipt();
                        if (!context.mounted) return;
                        if (ok) {
                          setState(() => _confirmed = true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Échec de l'enregistrement, veuillez réessayer.",
                              ),
                            ),
                          );
                        }
                      }
                    : null,
              ),
              if (confirmed) ...[
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Merci ! Votre réception a bien été enregistrée.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.accentGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/app/delivery/report-issue'),
                  child: Text(
                    'Signaler un problème',
                    style: TextStyle(
                      color: palette.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ligne label/valeur du récapitulatif.
class _RecapRow extends StatelessWidget {
  const _RecapRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: context.palette.onSurface(.6),
              fontSize: 13,
            ),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class ReceiptConfirmedPage extends StatelessWidget {
  const ReceiptConfirmedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ColoredBox(
      color: palette.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.check_circle, color: palette.accentGreen, size: 82),
              const SizedBox(height: 16),
              const Text(
                'Réception confirmée !',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Merci d’avoir vérifié votre commande.',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.onSurface(.65)),
              ),
              const Spacer(),
              ActionButton(
                label: "Retour à l'accueil",
                icon: Icons.home,
                onPressed: () => context.go('/app/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  DeliveryIssueType _type = DeliveryIssueType.notReceived;
  final _descriptionController = TextEditingController();
  Uint8List? _photoBytes;
  String? _photoName;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _photoBytes = bytes;
      _photoName = picked.name;
    });
  }

  bool get _canSubmit =>
      _type != DeliveryIssueType.other ||
      _descriptionController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Signaler un problème',
          subtitle: 'Décrivez ce qui ne va pas avec votre commande.',
        ),
        for (final type in DeliveryIssueType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              onTap: () => setState(() => _type = type),
              borderColor: _type == type ? palette.accentGreen : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      type.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Icon(
                    _type == type
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _type == type
                        ? palette.accentGreen
                        : palette.onSurface(.38),
                  ),
                ],
              ),
            ),
          ),
        if (_type == DeliveryIssueType.other) ...[
          const SizedBox(height: 4),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Décrivez la situation',
              hintText: 'Expliquez ce qui se passe...',
            ),
          ),
        ],
        const SizedBox(height: 14),
        const SectionLabel('Photo (optionnel)'),
        if (_photoBytes != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                _photoBytes!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ActionButton(
          label: _photoBytes == null ? 'Ajouter une photo' : 'Changer la photo',
          icon: Icons.photo_camera_outlined,
          secondary: true,
          onPressed: _pickPhoto,
        ),
        const SizedBox(height: 18),
        ActionButton(
          label: 'Envoyer le signalement',
          icon: Icons.send,
          onPressed: _canSubmit
              ? () {
                  state.submitIssueReport(
                    DeliveryIssueReport(
                      type: _type,
                      description: _descriptionController.text.trim(),
                      photoPath: _photoName,
                      createdAt: DateTime.now(),
                    ),
                  );
                  context.go('/app/delivery/report-issue/success');
                }
              : null,
        ),
      ],
    );
  }
}

class ReportIssueSuccessPage extends StatelessWidget {
  const ReportIssueSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ColoredBox(
      color: palette.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                Icons.mark_email_read_outlined,
                color: palette.accentGreen,
                size: 76,
              ),
              const SizedBox(height: 16),
              const Text(
                'Signalement envoyé',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Notre équipe va traiter votre demande rapidement.',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.onSurface(.65)),
              ),
              const Spacer(),
              ActionButton(
                label: "Retour à l'accueil",
                icon: Icons.home,
                onPressed: () => context.go('/app/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
