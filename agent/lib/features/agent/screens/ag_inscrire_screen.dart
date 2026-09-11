// =============================================================================
// FEATURES/AGENT/SCREENS/AG_INSCRIRE_SCREEN.DART
// Inscription client individuel OU en famille
// =============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/api_client.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/models/client_model.dart';
import 'ag_qr_code_client_screen.dart';



class AgInscrireScreen extends StatefulWidget {
  const AgInscrireScreen({super.key});

  @override
  State<AgInscrireScreen> createState() => _AgInscrireScreenState();
}

class _AgInscrireScreenState extends State<AgInscrireScreen>
    with SingleTickerProviderStateMixin {
  // Formulaire parent
  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _quarCtrl = TextEditingController();

  String _selectedPlan = 'weekly'; // daily, weekly, monthly
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _villeCtrl.dispose();
    _quarCtrl.dispose();
    super.dispose();
  }



  Future<void> _submitForm() async {
    final prenom = _prenomCtrl.text.trim();
    final nom = _nomCtrl.text.trim();
    final tel = _telCtrl.text.trim();
    final ville = _villeCtrl.text.trim();
    final quartier = _quarCtrl.text.trim();

    if (prenom.isEmpty || nom.isEmpty || tel.isEmpty || ville.isEmpty) {
      showEduToast(context, 'Veuillez remplir les informations du parent', isError: true);
      return;
    }



    setState(() => _isSubmitting = true);

    try {
      final phoneClean = tel.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');

      // Construction du body selon le mode
      final Map<String, dynamic> body = {
        'full_name': '$prenom $nom'.trim(),
        'phone': phoneClean,
        'city': ville,
        if (quartier.isNotEmpty) 'district': quartier,
        'plan': _selectedPlan,
      };

      // Mode famille: parent seul, enfants ajoutés après
      body['children'] = [];

      final response = await ApiClient.post('/agent/me/families', body);

      if (!mounted) return;

      final clientData = response['data'] as Map<String, dynamic>;
      final newClient = ClientModel.fromJson(clientData);

      // Refresh dashboard & liste clients en arrière-plan
      context.read<AgentProvider>().loadClients();
      context.read<AgentProvider>().loadDashboard();

      // Naviguer vers l'écran QR Code
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AgQrCodeClientScreen(client: newClient),
        ),
      );
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : e.toString();
        showEduToast(context, 'Erreur: $msg', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
              border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.white70, size: 22),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Nouvelle inscription',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 22),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  // Titre section parent
                  Text(
                    'INFORMATIONS DU PARENT / TUTEUR',
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildLabel('PRÉNOM'),
                  _buildInput(_prenomCtrl, 'Marie'),
                  _buildLabel('NOM'),
                  _buildInput(_nomCtrl, 'Ouedraogo'),
                  _buildLabel('TÉLÉPHONE'),
                  _buildInput(_telCtrl, '+226 70 45 67 89',
                      keyboardType: TextInputType.phone),
                  _buildLabel('VILLE'),
                  _buildInput(_villeCtrl, 'Koudougou'),
                  _buildLabel('QUARTIER (Optionnel)'),
                  _buildInput(_quarCtrl, 'Secteur 15'),

                  _buildLabel('RYTHME DE COTISATION'),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white07,
                      border: Border.all(color: AppColors.borderDefault),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPlan,
                        isExpanded: true,
                        dropdownColor: AppColors.cardBg,
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.white),
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Quotidien (Tous les jours)')),
                          DropdownMenuItem(value: 'weekly', child: Text('Hebdomadaire (Chaque semaine)')),
                          DropdownMenuItem(value: 'monthly', child: Text('Mensuel (Chaque mois)')),
                        ],
                        onChanged: (v) => setState(() => _selectedPlan = v!),
                      ),
                    ),
                  ),



                  const SizedBox(height: 8),

                  // Info contextuelle
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.green.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.green, size: 15),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mode famille : vous ajouterez les enfants depuis la fiche client après l\'inscription.',
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
                                fontSize: 10, color: AppColors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_isSubmitting)
                    const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.green),
                    )
                  else
                    EduButton.green(
                      'Inscrire cette famille',
                      onPressed: _submitForm,
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 2),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.green,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint,
      {TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.white35),
          filled: true,
          fillColor: AppColors.white07,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: AppColors.borderDefault),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: AppColors.green),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
