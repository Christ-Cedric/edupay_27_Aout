// =============================================================================
// FEATURES/AGENT/SCREENS/AG_LOGIN_SCREEN.DART — Connexion réelle via API
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/providers/auth_provider.dart';
import 'ag_dashboard_screen.dart';

// Custom yellow/gold color for the new design
const Color kGold = Color(0xFFFFBF00);
const Color kNavy = Color(0xFF0D1B3E);
const Color kNavyLight = Color(0xFF162448);

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
    final rawPhone = _phoneCtrl.text.trim();
    final phone = rawPhone.startsWith('+') ? rawPhone : '+226$rawPhone';
    final pin = _pinCtrl.text.trim();

    if (rawPhone.isEmpty || pin.isEmpty) {
      showEduToast(context, 'Veuillez remplir tous les champs', isError: true);
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithPin(phone: phone, pin: pin);

    if (!mounted) return;
    if (!success) {
      showEduToast(context, auth.errorMessage ?? 'Échec de connexion', isError: true);
    } else {
      // Force la navigation car l'AuthGate (racine) a pu être écrasé par le Navigator.push du logout
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AgDashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kGold,
      body: Stack(
        children: [
          // ─── Top navy wave ───────────────────────────────────────────
          ClipPath(
            clipper: _TopWaveClipper(),
            child: Container(
              height: size.height * 0.32,
              color: kNavy,
            ),
          ),

          // ─── Bottom navy wave ────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _BottomWaveClipper(),
              child: Container(
                height: size.height * 0.25,
                color: kNavy,
              ),
            ),
          ),

          // ─── Decorative dots top-right ───────────────────────────────
          Positioned(
            top: 60,
            right: 24,
            child: _DotsGrid(color: kGold.withValues(alpha: 0.4)),
          ),

          // ─── Decorative dots bottom-left ─────────────────────────────
          Positioned(
            bottom: 40,
            left: 20,
            child: _DotsGrid(color: kGold.withValues(alpha: 0.3)),
          ),

          // ─── Circle accents ──────────────────────────────────────────
          Positioned(
            top: 120,
            right: 60,
            child: Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kNavy, width: 2),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 40,
            child: Container(
              width: 14, height: 14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kNavy,
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: 30,
            child: Container(
              width: 18, height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kNavy,
              ),
            ),
          ),

          // ─── Main content ─────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height: size.height - MediaQuery.of(context).padding.top,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Logo
                    Image.asset(
                      'assets/images/app_logo.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.school, size: 100, color: kNavy,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // "— EDUP@Y —" title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 24, height: 2, color: kNavy),
                        const SizedBox(width: 10),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.montserrat(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              shadows: const [
                                Shadow(color: kNavy, blurRadius: 8, offset: Offset(2, 3)),
                              ],
                            ),
                            children: const [
                              TextSpan(text: 'EDU', style: TextStyle(color: Colors.white)),
                              TextSpan(text: 'P', style: TextStyle(color: Color(0xFF4CAF50))),
                              TextSpan(text: '@', style: TextStyle(color: kGold)),
                              TextSpan(text: 'Y', style: TextStyle(color: Color(0xFF4CAF50))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(width: 24, height: 2, color: kNavy),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ─── Login Card ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kNavyLight,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: kNavy.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // ── Numéro field ────────────────────────────
                            _LoginField(
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: kGold,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.smartphone_rounded,
                                        color: kNavy, size: 22),
                                  ),
                                  // Divider
                                  Container(
                                    width: 1,
                                    height: 32,
                                    color: Colors.white.withValues(alpha: 0.15),
                                    margin: const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                  // Flag + code
                                  const Text('🇧🇫', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 4),
                                  Text('+226',
                                    style: GoogleFonts.montserrat(
                                      color: kGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Input
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Numéro',
                                        hintStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                                          color: Colors.white38,
                                          fontSize: 15,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── Code secret field ───────────────────────
                            _LoginField(
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: kGold,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.lock_rounded,
                                        color: kNavy, size: 22),
                                  ),
                                  // Divider
                                  Container(
                                    width: 1,
                                    height: 32,
                                    color: Colors.white.withValues(alpha: 0.15),
                                    margin: const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _pinCtrl,
                                      obscureText: _obscurePin,
                                      keyboardType: TextInputType.text,
                                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Code secret',
                                        hintStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                                          color: Colors.white38,
                                          fontSize: 15,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePin
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.white38,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              setState(() => _obscurePin = !_obscurePin),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── Login button ────────────────────────────
                            if (isLoading)
                              const CircularProgressIndicator(color: kGold)
                            else
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kGold,
                                    foregroundColor: kNavy,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 4,
                                    shadowColor: kGold.withValues(alpha: 0.4),
                                  ),
                                  child: Text(
                                    'Se connecter',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: kNavy,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ──────────────────────────────────────────────────────────────────────────────

class _LoginField extends StatelessWidget {
  final Widget child;
  const _LoginField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
}

class _DotsGrid extends StatelessWidget {
  final Color color;
  const _DotsGrid({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (row) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: List.generate(3, (col) => Container(
            width: 5, height: 5,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          )),
        ),
      )),
    );
  }
}

class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.55, size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.72,
      size.width, size.height * 0.6,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.1,
      size.width * 0.5, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.45,
      size.width, size.height * 0.2,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
