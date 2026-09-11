import 'package:flutter/material.dart';
import '../../../core/models/client_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/api_client.dart';

enum PlanFrequency { daily, weekly, monthly }

class AgTransportPlanScreen extends StatefulWidget {
  final TransportOptionModel transport;
  final String familyId;
  final String childId;

  const AgTransportPlanScreen({
    super.key,
    required this.transport,
    required this.familyId,
    required this.childId,
  });

  @override
  _AgTransportPlanScreenState createState() => _AgTransportPlanScreenState();
}

class _AgTransportPlanScreenState extends State<AgTransportPlanScreen> {
  PlanFrequency? _frequency;
  double _capacity = 0;
  final TextEditingController _capacityController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }

  void _onFrequencySelected(PlanFrequency freq) {
    setState(() {
      _frequency = freq;
    });
  }

  void _onCapacityChanged(String value) {
    setState(() {
      _capacity = double.tryParse(value.replaceAll(' ', '')) ?? 0;
    });
  }

  Future<void> _startPlan() async {
    if (_frequency == null || _capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir un plan et une capacité valide')),
      );
      return;
    }

    if (_capacity > widget.transport.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La capacité ne peut excéder le prix total')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiClient.post('/agent/me/families/${widget.familyId}/children/${widget.childId}/transport', {
        'amount': widget.transport.price.toInt(),
        'name': widget.transport.name,
        'frequency': _frequency.toString().split('.').last,
        'capacity': _capacity.toInt(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan généré et sauvegardé avec succès !'), backgroundColor: AppColors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sauvegarde du plan.'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFrequencyLabel(PlanFrequency? freq) {
    switch (freq) {
      case PlanFrequency.daily:
        return 'Journalière';
      case PlanFrequency.weekly:
        return 'Hebdomadaire';
      case PlanFrequency.monthly:
        return 'Mensuelle';
      default:
        return '';
    }
  }

  String _getUnitLabel(PlanFrequency? freq) {
    switch (freq) {
      case PlanFrequency.daily:
        return 'jour';
      case PlanFrequency.weekly:
        return 'semaine';
      case PlanFrequency.monthly:
        return 'mois';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    int numberOfContributions = 0;
    if (_capacity > 0) {
      numberOfContributions = (widget.transport.price / _capacity).ceil();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotisation Transport'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Carte résumé transport
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Row(
                      children: [
                        Text(widget.transport.icon ?? '🚍', style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Transport choisi : ${widget.transport.name}', style: AppTheme.openSans(color: AppColors.white70)),
                              Text('${widget.transport.price.toInt()} FCFA', style: AppTheme.montserrat(fontSize: 18, color: AppColors.gold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Choisissez votre plan de cotisation', style: AppTheme.montserrat(fontSize: 16)),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      _buildFreqChoice(PlanFrequency.daily, 'Journalière'),
                      const SizedBox(width: 8),
                      _buildFreqChoice(PlanFrequency.weekly, 'Hebdo'),
                      const SizedBox(width: 8),
                      _buildFreqChoice(PlanFrequency.monthly, 'Mensuelle'),
                    ],
                  ),

                  if (_frequency != null) ...[
                    const SizedBox(height: 24),
                    Text('Ma capacité de cotisation', style: AppTheme.montserrat(fontSize: 16)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      onChanged: _onCapacityChanged,
                      style: AppTheme.montserrat(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Montant (ex: 10000)',
                        suffixText: 'FCFA / ${_getUnitLabel(_frequency)}',
                        filled: true,
                        fillColor: AppColors.cardBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],

                  if (_frequency != null && _capacity > 0) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white05,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RÉSUMÉ DE MA COTISATION', style: AppTheme.montserrat(color: AppColors.gold, fontSize: 14)),
                          const Divider(color: AppColors.borderDefault, height: 24),
                          _buildSummaryRow('Transport', widget.transport.name),
                          _buildSummaryRow('Prix total', '${widget.transport.price.toInt()} FCFA'),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Plan', _getFrequencyLabel(_frequency)),
                          _buildSummaryRow('Capacité', '${_capacity.toInt()} FCFA / ${_getUnitLabel(_frequency)}'),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Nombre de versements', '$numberOfContributions', highlight: true),
                          _buildSummaryRow('Durée estimée', '$numberOfContributions ${_getUnitLabel(_frequency)}s', highlight: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    EduButton(
                      label: 'Enregistrer et Commencer',
                      onPressed: _startPlan,
                    ),
                  ]
                ],
              ),
            ),
    );
  }

  Widget _buildFreqChoice(PlanFrequency freq, String label) {
    final isSelected = _frequency == freq;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onFrequencySelected(freq),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tagYellowBg : AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.gold : AppColors.borderDefault),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.montserrat(
              fontSize: 13,
              color: isSelected ? AppColors.gold : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.openSans(color: highlight ? AppColors.white : AppColors.white70)),
          Text(value, style: AppTheme.montserrat(color: highlight ? AppColors.green : AppColors.white)),
        ],
      ),
    );
  }
}
