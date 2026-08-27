// =============================================================================
// FEATURES/AGENT/SCREENS/AG_LOGIN_SCREEN.DART — Connexion réelle via API
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/auth_provider.dart';

class AgLoginScreen extends StatefulWidget {
  const AgLoginScreen({super.key});

  @override
  State<AgLoginScreen> createState() => _AgLoginScreenState();
}

class _AgLoginScreenState extends State<AgLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _obscurePin = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final phone = _phoneCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    if (phone.isEmpty || pin.isEmpty) {
      showEduToast(context, 'Veuillez remplir tous les champs', isError: true);
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithPin(phone: phone, pin: pin);

    if (!mounted) return;
    if (!success) {
      showEduToast(context, auth.errorMessage ?? 'Échec de connexion', isError: true);
    }
    // Si succès, l'AuthGate dans main.dart redirigera automatiquement
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: EduPayLogo(fontSize: 28)),
                  const SizedBox(height: 80),
                  Text(
                    'Connexion Agent',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entrez votre numéro et votre code secret',
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      color: AppColors.white50,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  EduCard(
                    child: Column(
                      children: [
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.openSans(color: AppColors.white),
                          decoration: const InputDecoration(
                            hintText: 'Numéro de téléphone (ex: 22674362056)',
                            hintStyle: TextStyle(color: AppColors.white50),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.white10)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.gold)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _pinCtrl,
                          obscureText: _obscurePin,
                          keyboardType: TextInputType.text,
                          style: GoogleFonts.openSans(color: AppColors.white),
                          decoration: InputDecoration(
                            hintText: 'Code secret / PIN',
                            hintStyle: const TextStyle(color: AppColors.white50),
                            counterStyle: const TextStyle(color: AppColors.white35),
                            suffixIcon: IconButton(
                              tooltip: _obscurePin
                                  ? 'Afficher le mot de passe'
                                  : 'Masquer le mot de passe',
                              icon: Icon(
                                _obscurePin
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.white50,
                              ),
                              onPressed: () {
                                setState(() => _obscurePin = !_obscurePin);
                              },
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.white10),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.gold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.green),
                    )
                  else
                    EduButton.green(
                      'Se connecter',
                      onPressed: _handleLogin,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
