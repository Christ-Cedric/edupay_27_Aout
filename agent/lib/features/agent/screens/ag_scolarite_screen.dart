import 'package:flutter/material.dart';
import '../../../core/models/client_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/api_client.dart';

class AgScolariteScreen extends StatefulWidget {
  final String familyId;
  final ChildModel child;

  const AgScolariteScreen({
    super.key,
    required this.familyId,
    required this.child,
  });

  @override
  _AgScolariteScreenState createState() => _AgScolariteScreenState();
}

enum PlanFrequency { daily, weekly, monthly }

class _AgScolariteScreenState extends State<AgScolariteScreen> {
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _payAmountController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  bool _isLoading = false;
  
  // Wizard state
  bool _isConfiguring = false;
  double _targetAmount = 0;
  PlanFrequency? _frequency;
  double _capacity = 0;

  SchoolingGoalModel? get _goal => widget.child.schoolingGoal;

  @override
  void dispose() {
    _targetAmountController.dispose();
    _payAmountController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _goToConfiguration() {
    final val = double.tryParse(_targetAmountController.text.replaceAll(' ', '')) ?? 0;
    if (val < 25000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le montant de la scolarité doit être d\'au moins 25 000 FCFA'), backgroundColor: AppColors.orange),
      );
      return;
    }
    setState(() {
      _targetAmount = val;
      _isConfiguring = true;
    });
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

  Future<void> _saveTargetAmount() async {
    if (_frequency == null || _capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir un plan et une capacité valide')),
      );
      return;
    }

    if (_capacity > _targetAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La capacité ne peut excéder le montant total')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiClient.post('/agent/me/families/${widget.familyId}/children/${widget.child.id}/schooling', {
        'amount': _targetAmount.toInt(),
        'name': 'Scolarité ${widget.child.firstName}',
        'frequency': _frequency.toString().split('.').last,
        'capacity': _capacity.toInt(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objectif scolarité créé !'), backgroundColor: AppColors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _payContribution() async {
    final val = double.tryParse(_payAmountController.text.replaceAll(' ', '')) ?? 0;
    if (val <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant valide'), backgroundColor: AppColors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiClient.post('/agent/me/families/${widget.familyId}/contributions', {
        'amount': val.toInt(),
        'targetGoalType': 'registration',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement enregistré !'), backgroundColor: AppColors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur serveur: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processRefund() async {
    final totalPaid = _goal?.savedAmount ?? 0;
    if (totalPaid <= 0) return;
    final penalty = totalPaid * 0.03;
    final netRefund = totalPaid - penalty;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg2,
        title: Text('⚠️ Abandon', style: AppTheme.montserrat(color: AppColors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vous avez déjà payé : ${totalPaid.toInt()} FCFA', style: AppTheme.openSans(color: AppColors.white)),
            const SizedBox(height: 16),
            Text('Êtes-vous sûr de vouloir abandonner ?', style: AppTheme.openSans(color: AppColors.white)),
            const SizedBox(height: 16),
            Text('Pénalité (3%) : -${penalty.toInt()} FCFA', style: AppTheme.openSans(color: AppColors.red)),
            const Divider(color: AppColors.borderDefault),
            Text('Remboursement : ${netRefund.toInt()} FCFA', style: AppTheme.montserrat(color: AppColors.green)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler', style: TextStyle(color: AppColors.white50))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await ApiClient.post('/agent/me/families/${widget.familyId}/refund', {
                  'amount': netRefund.toInt(),
                  'reason': 'Abandon scolarité pour ${widget.child.firstName}',
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demande de remboursement envoyée.'), backgroundColor: AppColors.green),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur serveur'), backgroundColor: AppColors.red),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Oui, abandonner', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scolarité')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _goal == null
              ? (_isConfiguring ? _buildConfigurationView() : _buildTargetAmountSetup())
              : _buildActivePlanView(),
    );
  }

  Widget _buildTargetAmountSetup() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Entrez le coût total de la scolarité pour ${widget.child.firstName}', 
               style: AppTheme.montserrat(fontSize: 18), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextField(
            controller: _targetAmountController,
            keyboardType: TextInputType.number,
            style: AppTheme.montserrat(fontSize: 24, color: AppColors.gold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Ex: 300000',
              suffixText: 'FCFA',
              filled: true,
              fillColor: AppColors.cardBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          EduButton(label: 'Continuer', onPressed: _goToConfiguration),
        ],
      ),
    );
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

  Widget _buildConfigurationView() {
    int numberOfContributions = 0;
    if (_capacity > 0) {
      numberOfContributions = (_targetAmount / _capacity).ceil();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => setState(() => _isConfiguring = false)),
              Text('Configuration du plan', style: AppTheme.montserrat(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.child.firstName, style: AppTheme.montserrat(fontSize: 20)),
          Text('Coût total: ${_targetAmount.toInt()} FCFA', style: AppTheme.openSans(color: AppColors.white70)),
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
                  _buildSummaryRow('Scolarité', '${_targetAmount.toInt()} FCFA'),
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
              onPressed: _saveTargetAmount,
            ),
          ],
          const SizedBox(height: 40),
        ],
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

  Widget _buildActivePlanView() {
    final goal = _goal!;
    final progress = goal.targetAmount > 0 ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
    final remainingAmount = goal.targetAmount - goal.savedAmount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('COTISATION SCOLARITÉ', style: AppTheme.montserrat(fontSize: 14, color: AppColors.white50), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(widget.child.firstName, style: AppTheme.montserrat(fontSize: 20), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total', style: AppTheme.openSans(color: AppColors.white70)),
                  Text('${goal.targetAmount.toInt()} FCFA', style: AppTheme.montserrat()),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Reste', style: AppTheme.openSans(color: AppColors.orange)),
                  Text('${remainingAmount.toInt()} FCFA', style: AppTheme.montserrat(color: AppColors.orange)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text('Déjà payé : ${goal.savedAmount.toInt()} FCFA', style: AppTheme.openSans(color: AppColors.green)),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(height: 12, decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(6))),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(height: 12, decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(6))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).toInt()} %', textAlign: TextAlign.right, style: AppTheme.montserrat(color: AppColors.green)),
          const SizedBox(height: 32),

          if (goal.planCapacity != null && goal.planFrequency != null) ...[
            Text('Échéancier', style: AppTheme.montserrat(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fréquence:', style: AppTheme.openSans(color: AppColors.white70)),
                      Text(goal.planFrequency == 'daily' ? 'Journalière' : goal.planFrequency == 'weekly' ? 'Hebdomadaire' : 'Mensuelle', style: AppTheme.montserrat()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Capacité:', style: AppTheme.openSans(color: AppColors.white70)),
                      GestureDetector(
                        onTap: () {
                          _payAmountController.text = goal.planCapacity!.toInt().toString();
                          _payContribution();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gold),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.payment, color: AppColors.gold, size: 16),
                              const SizedBox(width: 8),
                              Text('Payer ${goal.planCapacity!.toInt()} FCFA', style: AppTheme.montserrat(color: AppColors.gold, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (remainingAmount > 0) ...[
            Text('Effectuer un paiement', style: AppTheme.montserrat(fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _payAmountController,
              keyboardType: TextInputType.number,
              style: AppTheme.montserrat(fontSize: 20, color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Montant à payer',
                suffixText: 'FCFA',
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            EduButton.green('Payer la scolarité', onPressed: _payContribution),
            const SizedBox(height: 32),
          ] else ...[
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: AppColors.green.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: AppColors.green),
               ),
               child: Text('🎉 Scolarité entièrement payée !', 
                 style: AppTheme.montserrat(color: AppColors.green, fontSize: 16), 
                 textAlign: TextAlign.center
               ),
             ),
             const SizedBox(height: 32),
          ],
          
          TextButton(
            onPressed: _processRefund,
            child: Text('Abandonner ma cotisation', style: AppTheme.openSans(color: AppColors.red)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
