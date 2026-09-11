import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../shared/widgets/edupay_logo.dart';
import '../../../../shared/widgets/password_text_field.dart';
import '../../../../app/network/api_exception.dart';
import '../parent_app_state.dart';
import '../parent_scope.dart';

String _getAuthErrorMessage(Object? error, String fallback) {
  if (error == null) return fallback;
  if (error is ArgumentError) {
    return error.message?.toString() ?? fallback;
  }
  if (error is ApiException) {
    return error.message;
  }
  return error.toString();
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 36,
                  ),
                  decoration: BoxDecoration(
                    color: palette.elevated,
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: palette.shadow(.18),
                        blurRadius: 30,
                        offset: const Offset(0, 20),
                      ),
                    ],
                    border: Border.all(color: palette.hairline),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      const EduPayLogo(size: 42),
                      const SizedBox(height: 30),
                      Container(
                        width: 94,
                        height: 94,
                        decoration: BoxDecoration(
                          color: palette.accentGreen.withValues(alpha: .12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school,
                          color: palette.accentGreen,
                          size: 46,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'La rentree facilitee, le futur assure',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.onSurface(.76),
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (state.authStatus == AuthStatus.restoring)
                // Session persistée en cours de vérification : on évite de
                // flasher les boutons de connexion à un utilisateur déjà connecté.
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: CircularProgressIndicator(color: palette.accentGreen),
                )
              else ...[
                ActionButton(
                  label: 'Creer mon compte',
                  icon: Icons.person_add_alt_1,
                  onPressed: () {
                    state.startAuth(AuthFlow.signUp);
                    context.push('/auth/phone');
                  },
                ),
                const SizedBox(height: 10),
                ActionButton(
                  label: 'J ai deja un compte',
                  icon: Icons.login,
                  secondary: true,
                  onPressed: () {
                    state.startAuth(AuthFlow.signIn);
                    context.push('/auth/login');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Écran d'attente affiché tant que le compte est `pendingValidation` —
/// l'admin doit valider la famille avant tout accès à la home (contrat §2).
class AccountPendingPage extends StatefulWidget {
  const AccountPendingPage({super.key});

  @override
  State<AccountPendingPage> createState() => _AccountPendingPageState();
}

class _AccountPendingPageState extends State<AccountPendingPage> {
  bool _checking = false;

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  color: palette.accentGreen.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top,
                  color: palette.accentGreen,
                  size: 46,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Compte en attente de validation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Votre inscription a bien été reçue. Un administrateur EduPay doit '
                'valider votre compte avant que vous puissiez accéder à l’application.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.onSurface(.62),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              ActionButton(
                label: _checking ? 'Vérification...' : 'Vérifier à nouveau',
                icon: Icons.refresh,
                onPressed: _checking
                    ? null
                    : () async {
                        setState(() => _checking = true);
                        await state.checkPendingApproval();
                        if (mounted) setState(() => _checking = false);
                      },
              ),
              const SizedBox(height: 10),
              ActionButton(
                label: 'Se déconnecter',
                icon: Icons.logout,
                secondary: true,
                onPressed: () => state.signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhonePage extends StatelessWidget {
  const PhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: _AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    const Center(child: EduPayLogo(size: 28)),
                    const SizedBox(height: 22),
                    Text(
                      state.authFlow == AuthFlow.forgotPassword
                          ? 'Mot de passe oublié'
                          : state.authFlow == AuthFlow.signIn
                          ? 'Bon retour'
                          : 'Creer votre compte',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.authFlow == AuthFlow.forgotPassword
                          ? 'Entrez votre numero de telephone pour reinitialiser votre mot de passe.'
                          : 'Entrez votre numero de telephone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.onSurface(.62),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: state.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _authInputDecoration(
                        palette,
                        label: 'Numero de telephone',
                        hint: '',
                      ),
                    ),
                    const SizedBox(height: 18),
                    ActionButton(
                      label: 'Recevoir le code',
                      icon: Icons.sms_outlined,
                      onPressed: state.loading
                          ? null
                          : () async {
                              final ok =
                                  state.authFlow == AuthFlow.forgotPassword
                                  ? await state.requestForgotOtp()
                                  : await state.requestOtp();
                              if (!context.mounted) return;
                              if (ok) {
                                context.push('/auth/otp');
                              } else {
                                final message = _getAuthErrorMessage(
                                  state.lastError,
                                  'Impossible d’envoyer le code.',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              }
                            },
                    ),

                    const SizedBox(height: 18),
                    Text(
                      'Nous envoyons uniquement un code OTP par SMS.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.onSurface(.48),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reconnexion d'un compte existant : numéro + mot de passe, sans OTP.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: _AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    const Center(child: EduPayLogo(size: 28)),
                    const SizedBox(height: 22),
                    Text(
                      'Bon retour',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connectez-vous avec votre numero et votre mot de passe.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.onSurface(.62),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: state.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _authInputDecoration(
                        palette,
                        label: 'Numero de telephone',
                        hint: '',
                      ),
                    ),
                    const SizedBox(height: 14),
                    PasswordTextField(
                      controller: state.loginPasswordController,
                      decoration: _authInputDecoration(
                        palette,
                        label: 'Mot de passe',
                        hint: '••••••',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: state.loading
                            ? null
                            : () {
                                state.startAuth(AuthFlow.forgotPassword);
                                context.push('/auth/phone');
                              },
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: palette.accentGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ActionButton(
                      label: 'Se connecter',
                      icon: Icons.login,
                      onPressed: state.loading
                          ? null
                          : () async {
                              final success = await state.signIn();
                              if (!success && context.mounted) {
                                final message = _getAuthErrorMessage(
                                  state.lastError,
                                  'Renseignez votre numero et votre mot de passe.',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              }
                            },
                    ),

                    const SizedBox(height: 18),
                    Text(
                      'Pas encore de compte ? Revenez a l ecran precedent.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.onSurface(.48),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: _AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    const Center(child: EduPayLogo(size: 28)),
                    const SizedBox(height: 22),
                    Text(
                      'Verification OTP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Entrez le code de 6 chiffres envoye au ${state.phoneController.text}.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.onSurface(.62),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        ParentAppState.otpLength,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: _OtpDot(filled: index < state.otpValue.length),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 216,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 12,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 44,
                            ),
                        itemBuilder: (context, index) {
                          final isDelete = index == 11;
                          final label = switch (index) {
                            0 => '1',
                            1 => '2',
                            2 => '3',
                            3 => '4',
                            4 => '5',
                            5 => '6',
                            6 => '7',
                            7 => '8',
                            8 => '9',
                            9 => '',
                            10 => '0',
                            _ => '',
                          };

                          if (index == 9) {
                            return const SizedBox.shrink();
                          }

                          return _KeyPadButton(
                            label: label,
                            isDelete: isDelete,
                            onTap: () async {
                              if (isDelete) {
                                state.removeOtpDigit();
                                return;
                              }
                              state.appendOtpDigit(label);
                              if (state.otpValue.length ==
                                  ParentAppState.otpLength) {
                                final ok = await state.completeOtp();
                                if (!context.mounted) return;
                                if (ok) {
                                  if (state.authFlow ==
                                      AuthFlow.forgotPassword) {
                                    context.push('/auth/forgot/reset');
                                  }
                                } else {
                                  final message = _getAuthErrorMessage(
                                    state.lastError,
                                    'Code invalide ou expiré.',
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    InkWell(
                      onTap: state.loading
                          ? null
                          : () async {
                              final ok =
                                  state.authFlow == AuthFlow.forgotPassword
                                  ? await state.requestForgotOtp()
                                  : await state.requestOtp();
                              if (!context.mounted) return;
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Un nouveau code OTP a été envoyé.',
                                    ),
                                  ),
                                );
                              } else {
                                final message = _getAuthErrorMessage(
                                  state.lastError,
                                  'Impossible de renvoyer le code.',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              }
                            },
                      child: Text(
                        'Renvoyer un nouveau code OTP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.accentGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Probleme ? Contactez le support',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.onSurface(.48),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: palette.shadow(.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
        border: Border.all(color: palette.hairline),
      ),
      child: child,
    );
  }
}

InputDecoration _authInputDecoration(
  AppPalette palette, {
  required String label,
  required String hint,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: palette.surfaceSoft,
    labelStyle: TextStyle(color: palette.accentGreen),
    hintStyle: TextStyle(color: palette.onSurface(.35)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: palette.onSurface(.16)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(const Radius.circular(14)),
      borderSide: BorderSide(color: palette.accentGreen, width: 1.5),
    ),
  );
}

class _OtpDot extends StatelessWidget {
  const _OtpDot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? palette.accentGreen : Colors.transparent,
        border: Border.all(
          color: filled ? palette.accentGreen : palette.onSurface(.35),
          width: 2,
        ),
      ),
    );
  }
}

class _KeyPadButton extends StatelessWidget {
  const _KeyPadButton({
    required this.label,
    required this.isDelete,
    required this.onTap,
  });

  final String label;
  final bool isDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surfaceSoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: isDelete
              ? Icon(
                  Icons.backspace_outlined,
                  color: palette.accentGreen,
                  size: 19,
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final bool _success = false;

  @override
  void initState() {
    super.initState();
    // Clear password fields when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ParentScope.of(context);
      state.passwordController.clear();
      state.confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ParentScope.of(context);
    final palette = context.palette;

    if (_success) {
      return Scaffold(
        backgroundColor: palette.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const Spacer(),
                Icon(
                  Icons.check_circle_outline,
                  color: palette.accentGreen,
                  size: 76,
                ),
                const SizedBox(height: 16),
                Text(
                  'Mot de passe modifié !',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Votre mot de passe a été modifié avec succès.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.onSurface(.62),
                    fontSize: 13,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Spacer(),
                ActionButton(
                  label: 'Retour à l’accueil',
                  icon: Icons.home_outlined,
                  onPressed: () {
                    context.go('/welcome');
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: _AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    const Center(child: EduPayLogo(size: 28)),
                    const SizedBox(height: 22),
                    Text(
                      'Nouveau mot de passe',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Définissez votre nouveau mot de passe.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.onSurface(.62),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    PasswordTextField(
                      controller: state.passwordController,
                      decoration: _authInputDecoration(
                        palette,
                        label: 'Nouveau mot de passe',
                        hint: '••••••••',
                      ),
                    ),
                    const SizedBox(height: 14),
                    PasswordTextField(
                      controller: state.confirmPasswordController,
                      decoration: _authInputDecoration(
                        palette,
                        label: 'Confirmer le nouveau mot de passe',
                        hint: '••••••••',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ActionButton(
                      label: 'Enregistrer',
                      icon: Icons.save_outlined,
                      onPressed: state.loading
                          ? null
                          : () async {
                              final ok = await state.resetPassword();
                              if (!mounted) return;
                              if (ok) {
                                context.go('/app/home');
                              } else {
                                final message = _getAuthErrorMessage(
                                  state.lastError,
                                  'Erreur lors de la réinitialisation.',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
