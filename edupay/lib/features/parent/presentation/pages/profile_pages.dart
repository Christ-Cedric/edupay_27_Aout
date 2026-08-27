import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/edupay_logo.dart';
import '../../../../shared/widgets/qr_code_widget.dart';
import '../../../../shared/widgets/password_text_field.dart';
import '../../domain/auth_session.dart';
import '../../domain/parent_models.dart';
import '../parent_app_state.dart';
import '../parent_scope.dart';
import 'page_scaffold.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return ParentPageScaffold(
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (state.qrPayload.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => _QrCodeModal(
                        qrPayload: state.qrPayload,
                        displayName: state.displayName,
                        phone:
                            state.profile?.phone ?? state.phoneController.text,
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    if (state.qrPayload.isNotEmpty)
                      EduPayQrWidget(data: state.qrPayload, size: 160)
                    else
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: palette.accentGreen,
                        foregroundColor: Colors.white,
                        child: Text(
                          state.displayName.isEmpty
                              ? '?'
                              : state.displayName.substring(0, 1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      'Mon QR Code',
                      style: TextStyle(
                        color: palette.accentGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                state.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                state.profile?.phone ?? state.phoneController.text,
                style: TextStyle(color: palette.onSurface(.55)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _MenuRow(
          icon: Icons.description_outlined,
          label: 'Contrat',
          value: 'Prêt',
          onTap: () => context.push('/app/contract'),
        ),
        _MenuRow(
          icon: Icons.savings_outlined,
          label: "Mon plan d'épargne",
          value: state.plan.title,
          onTap: () => context.push('/app/plan/edit'),
        ),
        _MenuRow(
          icon: Icons.replay_outlined,
          label: 'Mes remboursements',
          onTap: () => context.push('/app/refund'),
        ),
        _MenuRow(
          icon: Icons.settings_outlined,
          label: 'Paramètres',
          onTap: () => context.push('/app/settings'),
        ),
        _MenuRow(
          icon: Icons.help_outline,
          label: "Centre d'aide",
          onTap: () => context.push('/app/contact'),
        ),
        _MenuRow(
          icon: Icons.info_outline,
          label: 'À propos EduP@y',
          onTap: () => context.push('/app/about'),
        ),
        const SizedBox(height: 16),
        ActionButton(
          label: 'Déconnexion',
          icon: Icons.logout,
          secondary: true,
          onPressed: () {
            state.signOut();
            context.go('/welcome');
          },
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  /// Ligne d'action sensible (déconnexion...) : icône et libellé en rouge.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final labelColor = danger ? palette.danger : palette.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        color: Colors.transparent,
        borderColor: palette.hairline,
        child: Row(
          children: [
            Icon(
              icon,
              color: danger ? palette.danger : palette.onSurface(.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: TextStyle(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Édition du profil parent depuis l'app principale (hors onboarding).
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final labelStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: context.palette.accentGreen,
    );

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Modifier mon profil',
          subtitle: 'Ces informations figurent sur votre contrat.',
        ),

        const SizedBox(height: 16),
        Text('Ville', style: labelStyle),
        DropdownButtonFormField<String>(
          initialValue: state.cityController.text.isEmpty
              ? null
              : state.cityController.text,
          items: ['Ouagadougou', 'Koudougou', 'Bobo-Dioulasso']
              .map(
                (ville) => DropdownMenuItem(value: ville, child: Text(ville)),
              )
              .toList(),
          onChanged: (value) => state.cityController.text = value!,
        ),
        const SizedBox(height: 16),
        Text('Quartier', style: labelStyle),
        TextField(controller: state.districtController),
        const SizedBox(height: 28),
        ActionButton(
          label: 'Enregistrer',
          icon: Icons.check,
          onPressed: () async {
            await state.saveProfile();
            if (context.mounted) context.pop();
          },
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);

    return ParentPageScaffold(
      children: [
        const PageTitle('Paramètres'),

        // 👤 1. Informations personnelles
        _SettingsSection(
          emoji: '👤',
          title: 'Informations personnelles',
          children: [
            _InfoTile(
              icon: Icons.person_outline,
              label: 'Nom complet',
              value: state.displayName,
            ),
            _InfoTile(
              icon: Icons.phone_outlined,
              label: 'Numéro de téléphone',
              value: state.profile?.phone ?? state.phoneController.text,
            ),
            const SizedBox(height: 6),
            ActionButton(
              label: 'Modifier mes informations',
              icon: Icons.edit_outlined,
              secondary: true,
              onPressed: () => context.push('/app/profile/edit'),
            ),
          ],
        ),

        // 🔐 2. Sécurité du compte
        _SettingsSection(
          emoji: '🔐',
          title: 'Sécurité du compte',
          children: [
            _MenuRow(
              icon: Icons.lock_outline,
              label: 'Modifier mon mot de passe',
              onTap: () => context.push('/app/settings/password'),
            ),
            _SwitchRow(
              icon: Icons.fingerprint,
              label: "Activer l'empreinte digitale",
              subtitle: 'Bientôt disponible.',
              value: false,
              onChanged: null,
            ),
            _MenuRow(
              icon: Icons.devices_outlined,
              label: 'Gérer les appareils connectés',
              onTap: () => context.push('/app/settings/devices'),
            ),
            _MenuRow(
              icon: Icons.logout,
              label: 'Déconnexion de tous les appareils',
              danger: true,
              onTap: () => _confirmSignOutAll(context, state),
            ),
          ],
        ),

        // 🔔 3. Notifications
        _SettingsSection(
          emoji: '🔔',
          title: 'Notifications',
          children: [
            _NotificationSwitch(
              kind: AppNotification.savingReminder,
              label: "Rappel d'épargne",
            ),
            _NotificationSwitch(
              kind: AppNotification.paymentConfirmed,
              label: 'Paiement confirmé',
            ),
            _NotificationSwitch(
              kind: AppNotification.paymentOverdue,
              label: 'Retard de paiement',
            ),
            _NotificationSwitch(
              kind: AppNotification.delivery,
              label: 'Livraison',
            ),
            _NotificationSwitch(
              kind: AppNotification.newKits,
              label: 'Nouveaux kits disponibles',
            ),
            _NotificationSwitch(
              kind: AppNotification.promotions,
              label: 'Offres et promotions',
            ),
          ],
        ),

        // 🌍 4. Langue et préférences
        _SettingsSection(
          emoji: '🌍',
          title: 'Langue et préférences',
          children: [
            _MenuRow(
              icon: Icons.language_outlined,
              label: "Langue de l'application",
              value: _languageLabel(state.language),
              onTap: () => _pickLanguage(context, state),
            ),
            _MenuRow(
              icon: Icons.palette_outlined,
              label: "Mode d'affichage",
              value: _themeLabel(state.themeMode),
              onTap: () => context.push('/app/theme'),
            ),
          ],
        ),

        // 📱 5. Connexions et appareils
        _SettingsSection(
          emoji: '📱',
          title: 'Connexions et appareils',
          children: [
            _InfoTile(
              icon: Icons.smartphone_outlined,
              label: 'Téléphone actuel',
              value: state.profile?.phone ?? state.phoneController.text,
            ),
            _MenuRow(
              icon: Icons.verified_user_outlined,
              label: 'Appareils autorisés',
              onTap: () => context.push('/app/settings/devices'),
            ),
          ],
        ),

        // 📄 6. Documents et confidentialité
        _SettingsSection(
          emoji: '📄',
          title: 'Documents et confidentialité',
          children: [
            _MenuRow(
              icon: Icons.description_outlined,
              label: "Conditions d'utilisation",
              onTap: () => context.push('/app/legal/terms'),
            ),
            _MenuRow(
              icon: Icons.privacy_tip_outlined,
              label: 'Politique de confidentialité',
              onTap: () => context.push('/app/legal/privacy'),
            ),
            _MenuRow(
              icon: Icons.shield_outlined,
              label: 'Gestion des données personnelles',
              onTap: () => context.push('/app/legal/data'),
            ),
            _MenuRow(
              icon: Icons.download_outlined,
              label: 'Télécharger mes données',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité bientôt disponible.'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _confirmSignOutAll(
    BuildContext context,
    ParentAppState state,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion de tous les appareils'),
        content: const Text(
          'Vous serez déconnecté de cet appareil et de tous les autres appareils connectés. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(
              'Déconnecter',
              style: TextStyle(color: context.palette.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await state.signOutAllDevices();
    if (context.mounted) context.go('/welcome');
  }

  Future<void> _pickLanguage(BuildContext context, ParentAppState state) async {
    final choice = await showModalBottomSheet<AppLanguage>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final lang in AppLanguage.values)
              ListTile(
                leading: Icon(
                  state.language == lang
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: context.palette.accentGreen,
                ),
                title: Text(_languageLabel(lang)),
                onTap: () => context.pop(lang),
              ),
          ],
        ),
      ),
    );
    if (choice != null) state.setLanguage(choice);
  }
}

String _languageLabel(AppLanguage lang) => switch (lang) {
  AppLanguage.french => 'Français',
  AppLanguage.english => 'Anglais',
};

String _themeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.light => 'Clair',
  ThemeMode.dark => 'Sombre',
  ThemeMode.system => 'Automatique',
};

/// En-tête de section (emoji + titre) suivi d'une carte regroupant ses lignes.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.emoji,
    required this.title,
    required this.children,
  });

  final String emoji;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10, top: 8),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: palette.accentGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Ligne d'information en lecture seule (icône + label + valeur).
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        color: Colors.transparent,
        borderColor: palette.hairline,
        child: Row(
          children: [
            Icon(icon, color: palette.onSurface(.7), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: palette.onSurface(.7)),
              ),
            ),
            Flexible(
              child: Text(
                value.isEmpty ? '—' : value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne avec bascule ON/OFF.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        color: Colors.transparent,
        borderColor: palette.hairline,
        child: Row(
          children: [
            Icon(icon, color: palette.onSurface(.7), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: palette.onSurface(.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              activeThumbColor: palette.accentGreen,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bascule reliée à une préférence de notification du view-model.
///
/// Désactivée volontairement : rien côté serveur ne filtre encore les
/// envois selon cette préférence (elle ne vivait qu'en mémoire locale, sans
/// effet réel) — mieux vaut l'annoncer honnêtement que laisser croire à un
/// contrôle qui n'existe pas encore.
class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({required this.kind, required this.label});

  final AppNotification kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    return _SwitchRow(
      icon: Icons.circle_notifications_outlined,
      label: label,
      subtitle: 'Bientôt disponible.',
      value: state.isNotificationEnabled(kind),
      onChanged: null,
    );
  }
}

/// 🔐 Modification du mot de passe. Validation locale (longueur, concordance)
/// puis appel réel à `POST /auth/password/change` (voir
/// `ParentAppState.changePassword`).
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validation locale avant l'appel réseau.
    if (_current.text.isEmpty) {
      setState(() => _error = 'Entrez votre mot de passe actuel.');
      return;
    }
    if (_next.text.length < 8) {
      setState(
        () => _error =
            'Le nouveau mot de passe doit contenir au moins 8 caractères.',
      );
      return;
    }
    if (_next.text != _confirm.text) {
      setState(() => _error = 'Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    final error = await ParentScope.of(
      context,
    ).changePassword(current: _current.text, next: _next.text);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _error = error;
        _submitting = false;
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mot de passe mis à jour.'),
        backgroundColor: context.palette.accentGreen,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final labelStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: palette.accentGreen,
    );

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Modifier mon mot de passe',
          subtitle: 'Choisissez un mot de passe d’au moins 8 caractères.',
        ),
        Text('Mot de passe actuel', style: labelStyle),
        PasswordTextField(controller: _current, enabled: !_submitting),
        const SizedBox(height: 16),
        Text('Nouveau mot de passe', style: labelStyle),
        PasswordTextField(controller: _next, enabled: !_submitting),
        const SizedBox(height: 16),
        Text('Confirmer le nouveau mot de passe', style: labelStyle),
        PasswordTextField(controller: _confirm, enabled: !_submitting),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(
              color: palette.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 28),
        ActionButton(
          label: _submitting ? 'Enregistrement…' : 'Enregistrer',
          icon: Icons.check,
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }
}

/// 📱 Appareils connectés (`GET /auth/sessions`, données réelles) ; l'appareil
/// courant ne peut pas être retiré ici (on passe par la déconnexion).
class ConnectedDevicesPage extends StatefulWidget {
  const ConnectedDevicesPage({super.key});

  @override
  State<ConnectedDevicesPage> createState() => _ConnectedDevicesPageState();
}

class _ConnectedDevicesPageState extends State<ConnectedDevicesPage> {
  late Future<List<ActiveSession>> _future;
  String? _revokingId;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `ParentScope.of` s'appuie sur `dependOnInheritedWidgetOfExactType`, donc
    // pas dans initState : on charge une seule fois ici.
    if (!_loaded) {
      _loaded = true;
      _future = ParentScope.of(context).loadSessions();
    }
  }

  void _reload() {
    setState(() => _future = ParentScope.of(context).loadSessions());
  }

  Future<void> _revoke(ActiveSession session) async {
    setState(() => _revokingId = session.id);
    try {
      await ParentScope.of(context).revokeSession(session.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de la déconnexion de cet appareil.'),
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() => _revokingId = null);
    _reload();
  }

  Future<void> _signOutAll() async {
    final state = ParentScope.of(context);
    await state.signOutAllDevices();
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ParentPageScaffold(
      children: [
        const PageTitle(
          'Appareils autorisés',
          subtitle: 'Les appareils connectés à votre compte EduP@y.',
        ),
        FutureBuilder<List<ActiveSession>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Column(
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 40,
                    color: palette.onSurface(.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Impossible de charger vos appareils.',
                    style: TextStyle(color: palette.onSurface(.6)),
                  ),
                  const SizedBox(height: 12),
                  ActionButton(
                    label: 'Réessayer',
                    icon: Icons.refresh,
                    secondary: true,
                    onPressed: _reload,
                  ),
                ],
              );
            }
            final sessions = snapshot.data ?? const <ActiveSession>[];
            if (sessions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Aucun appareil actif.',
                    style: TextStyle(color: palette.onSurface(.6)),
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final session in sessions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      borderColor: session.isCurrent
                          ? palette.accentGreen
                          : null,
                      child: Row(
                        children: [
                          Icon(Icons.smartphone, color: palette.onSurface(.7)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.device ?? 'Appareil inconnu',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _deviceSubtitle(session),
                                  style: TextStyle(
                                    color: palette.onSurface(.55),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (session.isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: palette.accentGreen.withValues(
                                  alpha: .16,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Cet appareil',
                                style: TextStyle(
                                  color: palette.accentGreen,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            )
                          else if (_revokingId == session.id)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            IconButton(
                              tooltip: 'Déconnecter',
                              icon: Icon(Icons.logout, color: palette.danger),
                              onPressed: () => _revoke(session),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        ActionButton(
          label: 'Déconnexion de tous les appareils',
          icon: Icons.logout,
          danger: true,
          onPressed: _signOutAll,
        ),
      ],
    );
  }

  String _deviceSubtitle(ActiveSession session) {
    final parts = <String>[
      if (session.isCurrent) 'Session courante',
      if (session.lastUsedAt != null)
        'Vu ${_relativeDate(session.lastUsedAt!)}',
      if (session.ip != null && session.ip!.isNotEmpty) session.ip!,
    ];
    return parts.isEmpty ? 'Session active' : parts.join(' · ');
  }
}

/// Date relative simple (« aujourd'hui », « il y a 3 j »...).
String _relativeDate(DateTime date) {
  final days = DateTime.now().difference(date).inDays;
  if (days <= 0) return "aujourd'hui";
  if (days == 1) return 'hier';
  return 'il y a $days j';
}

/// 📄 Page générique pour les documents légaux (CGU, confidentialité, données).
class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({required this.doc, super.key});

  final String doc;

  ({String title, String body}) get _content => switch (doc) {
    'privacy' => (
      title: 'Politique de confidentialité',
      body:
          "EduP@y collecte uniquement les informations nécessaires à la gestion de votre épargne scolaire : "
          "identité, numéro de téléphone, enfants inscrits et historique de cotisations. Vos données ne sont "
          "jamais revendues. Elles sont conservées de façon sécurisée et vous pouvez demander leur suppression "
          "à tout moment depuis « Gestion des données personnelles ».",
    ),
    'data' => (
      title: 'Gestion des données personnelles',
      body:
          "Vous gardez le contrôle de vos données. Vous pouvez consulter, corriger ou télécharger l'ensemble "
          "des informations liées à votre compte, ainsi que demander leur effacement définitif. La suppression "
          "du compte entraîne l'arrêt des cotisations et le remboursement du solde disponible selon nos conditions.",
    ),
    _ => (
      title: "Conditions d'utilisation",
      body:
          "En utilisant EduP@y, vous acceptez de fournir des informations exactes et d'utiliser le service pour "
          "l'épargne des kits scolaires de vos enfants. Les cotisations sont dédiées à l'achat des fournitures "
          "auprès de nos fournisseurs partenaires. EduP@y s'engage à livrer les kits avant la date limite "
          "convenue et à rembourser tout montant non utilisé.",
    ),
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final content = _content;
    return ParentPageScaffold(
      children: [
        PageTitle(content.title),
        AppCard(
          child: Text(
            content.body,
            style: TextStyle(color: palette.onSurface(.72), height: 1.5),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Dernière mise à jour : juillet 2026',
          style: TextStyle(color: palette.onSurface(.5), fontSize: 12),
        ),
      ],
    );
  }
}

/// Stub prêt à recevoir de vraies préférences (langue, rappels...) côté backend.
class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParentPageScaffold(
      children: [
        PageTitle(
          'Préférences',
          subtitle: 'Personnalisez votre expérience EduP@y.',
        ),
        _ComingSoonCard(
          icon: Icons.tune_outlined,
          message:
              'Les préférences (langue, rappels de cotisation...) arrivent bientôt.',
        ),
      ],
    );
  }
}

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParentPageScaffold(
      children: [
        PageTitle(
          'Moyens de paiement',
          subtitle: 'Choisissez votre méthode de cotisation par défaut.',
        ),
        _PaymentMethodTile(
          method: PaymentMethod.orangeMoney,
          title: 'Orange Money',
          badge: 'OM',
          color: Color(0xFFFF6600),
        ),
        _PaymentMethodTile(
          method: PaymentMethod.moovMoney,
          title: 'Moov Money',
          badge: 'MM',
          color: Color(0xFF0066CC),
        ),
        SizedBox(height: 8),
        Text(
          'Le paiement en espèces se fait uniquement lors du passage d’un '
          'agent — il ne peut pas être choisi comme méthode par défaut ici.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.title,
    required this.badge,
    required this.color,
  });

  final PaymentMethod method;
  final String title;
  final String badge;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;
    final selected = state.paymentMethod == method;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => state.selectPaymentMethod(method),
        borderColor: selected ? palette.accentYellow : null,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              foregroundColor: Colors.white,
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? palette.accentYellow : palette.onSurface(.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sélecteur d'apparence : Clair / Sombre / Système (basculé en direct).
class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);

    return ParentPageScaffold(
      children: [
        const PageTitle('Thème', subtitle: "L'apparence de l'application."),
        _ThemeOption(
          icon: Icons.light_mode_outlined,
          label: 'Clair',
          description: 'Fond clair, contraste élevé pour la journée.',
          selected: state.themeMode == ThemeMode.light,
          onTap: () => state.setThemeMode(ThemeMode.light),
        ),
        _ThemeOption(
          icon: Icons.dark_mode_outlined,
          label: 'Sombre',
          description: 'Fond sombre, reposant pour les yeux.',
          selected: state.themeMode == ThemeMode.dark,
          onTap: () => state.setThemeMode(ThemeMode.dark),
        ),
        _ThemeOption(
          icon: Icons.brightness_auto_outlined,
          label: 'Système',
          description: "Suit le réglage d'apparence du téléphone.",
          selected: state.themeMode == ThemeMode.system,
          onTap: () => state.setThemeMode(ThemeMode.system),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        borderColor: selected ? palette.accentGreen : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? palette.accentGreen : palette.onSurface(.7),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: palette.onSurface(.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? palette.accentGreen : palette.onSurface(.3),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ParentPageScaffold(
      children: [
        const SizedBox(height: 12),
        const Center(child: EduPayLogo(size: 30)),
        const SizedBox(height: 20),
        AppCard(
          child: Text(
            "EduP@y simplifie et sécurise l'épargne scolaire des parents : plans de cotisation flexibles, kits "
            "scolaires personnalisables et suivi individuel de chaque enfant, jusqu'à la livraison des fournitures.",
            style: TextStyle(color: palette.onSurface(.72), height: 1.45),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              const _InfoRowSimple(label: 'Version', value: '1.0.0'),
              Divider(height: 18, color: palette.hairline),
              const _InfoRowSimple(
                label: 'Siège',
                value: 'Ouagadougou, Burkina Faso',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRowSimple extends StatelessWidget {
  const _InfoRowSimple({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(color: context.palette.onSurface(.55)),
        ),
      ),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
    ],
  );
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Icon(icon, size: 48, color: palette.onSurface(.4)),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.onSurface(.6),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal plein écran Wave-style pour afficher le QR Code en grand.
class _QrCodeModal extends StatelessWidget {
  const _QrCodeModal({
    required this.qrPayload,
    required this.displayName,
    required this.phone,
  });

  final String qrPayload;
  final String displayName;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final screenWidth = MediaQuery.of(context).size.width;
    final qrSize = (screenWidth * 0.7).clamp(220.0, 340.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        color: palette.accentGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mon QR Code',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: palette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: palette.onSurface(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pr\u00e9sentez ce QR Code \u00e0 l\u2019agent pour \u00eatre identifi\u00e9.',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.onSurface(0.55), fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Grand QR Code
              EduPayQrWidget(data: qrPayload, size: qrSize, padding: 16),
              const SizedBox(height: 24),

              // Informations client
              Text(
                displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: palette.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, size: 14, color: palette.accentGreen),
                    const SizedBox(width: 6),
                    Text(
                      phone,
                      style: TextStyle(
                        color: palette.accentGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => _A4PrintPreviewDialog(
                            qrPayload: qrPayload,
                            displayName: displayName,
                            phone: phone,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: const Text('Imprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.accentGreen,
                        side: BorderSide(color: palette.accentGreen),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Fermer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aper\u00e7u d'impression A4 propre du QR Code.
class _A4PrintPreviewDialog extends StatelessWidget {
  const _A4PrintPreviewDialog({
    required this.qrPayload,
    required this.displayName,
    required this.phone,
  });

  final String qrPayload;
  final String displayName;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Dialog.fullscreen(
      backgroundColor: const Color(0xFFF5F5F5),
      child: SafeArea(
        child: Column(
          children: [
            // Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: palette.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour'),
                  ),
                  Text(
                    'Aper\u00e7u d\u2019impression',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: palette.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fonctionnalit\u00e9 d\u2019impression bient\u00f4t disponible.',
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.print, color: palette.accentGreen),
                    label: Text(
                      'Imprimer',
                      style: TextStyle(color: palette.accentGreen),
                    ),
                  ),
                ],
              ),
            ),

            // A4 Sheet Preview
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    width: 595, // A4 width in points (approx)
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 64,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // En-t\u00eate officiel
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: palette.accentGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'E',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'EduP@y',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '\u00c9pargne Scolaire Intelligente',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 36),
                        const Divider(height: 1),
                        const SizedBox(height: 36),

                        // Titre
                        const Text(
                          'QR Code d\u2019Identification Client',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // QR Code Grand Format
                        EduPayQrWidget(data: qrPayload, size: 280, padding: 20),
                        const SizedBox(height: 32),

                        // Informations Client
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              _PrintInfoRow(
                                label: 'Nom complet',
                                value: displayName,
                              ),
                              const SizedBox(height: 10),
                              _PrintInfoRow(
                                label: 'T\u00e9l\u00e9phone',
                                value: phone,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Guide d'utilisation
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: palette.accentGreen.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: palette.accentGreen.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: palette.accentGreen,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Guide pour les agents',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: palette.accentGreen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '1. Ouvrez l\u2019application Agent EduPay\n'
                                '2. Scannez ce QR Code avec le scanner int\u00e9gr\u00e9\n'
                                '3. Le compte du client sera identifi\u00e9 automatiquement\n'
                                '4. Enregistrez le paiement',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF475569),
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _PrintInfoRow extends StatelessWidget {
  const _PrintInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
