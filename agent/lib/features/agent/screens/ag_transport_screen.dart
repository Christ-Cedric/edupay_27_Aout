import 'package:flutter/material.dart';
import '../../../core/models/client_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/api_client.dart';
import 'ag_transport_plan_screen.dart';

class AgTransportScreen extends StatefulWidget {
  final String familyId;
  final ChildModel child;

  const AgTransportScreen({
    super.key,
    required this.familyId,
    required this.child,
  });

  @override
  _AgTransportScreenState createState() => _AgTransportScreenState();
}

class _AgTransportScreenState extends State<AgTransportScreen> {
  final TextEditingController _payAmountController = TextEditingController();
  bool _isLoading = false;

  final List<TransportOptionModel> _options = [
    TransportOptionModel(id: '1', name: 'Moto', description: 'Transport par moto', price: 15000, icon: '🏍️'),
    TransportOptionModel(id: '2', name: 'Vélo', description: 'Transport à vélo', price: 5000, icon: '🚲'),
    TransportOptionModel(id: '3', name: 'Minibus', description: 'Ramassage scolaire régulier', price: 25000, icon: '🚐'),
  ];
  final Set<String> _selectedOptionIds = {};

  TransportGoalModel? get _goal => widget.child.transportGoal;

  @override
  void dispose() {
    _payAmountController.dispose();
    super.dispose();
  }

  void _toggleOption(String id) {
    setState(() {
      if (_selectedOptionIds.contains(id)) {
        _selectedOptionIds.remove(id);
      } else {
        _selectedOptionIds.add(id);
      }
    });
  }

  Future<void> _submitTransportChoice() async {
    if (_selectedOptionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un moyen de transport'), backgroundColor: AppColors.orange),
      );
      return;
    }

    final selectedOptions = _options.where((o) => _selectedOptionIds.contains(o.id)).toList();
    final totalPrice = selectedOptions.fold(0.0, (sum, o) => sum + o.price);
    final combinedName = selectedOptions.map((o) => o.name).join(' + ');
    
    final combinedOption = TransportOptionModel(
      id: 'combo_${DateTime.now().millisecondsSinceEpoch}',
      name: combinedName,
      price: totalPrice,
      icon: selectedOptions.first.icon,
    );

    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgTransportPlanScreen(
          transport: combinedOption,
          familyId: widget.familyId,
          childId: widget.child.id,
        ),
      ),
    );

    if (res == true) {
      if (mounted) {
        Navigator.pop(context, true);
      }
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
        'targetGoalType': 'transport',
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
                  'reason': 'Abandon transport pour ${widget.child.firstName}',
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
      appBar: AppBar(title: const Text('Moyens de transport')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _goal == null
              ? _buildOptionsList()
              : _buildActivePlanView(),
    );
  }

  Widget _buildOptionsList() {
    final double totalPrice = _options
        .where((o) => _selectedOptionIds.contains(o.id))
        .fold(0.0, (sum, o) => sum + o.price);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.blue,
                child: Icon(Icons.person, color: AppColors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.child.firstName, style: AppTheme.montserrat(fontSize: 18)),
                    Text(
                      'Sélectionnez un moyen de transport pour cet enfant.',
                      style: AppTheme.openSans(color: AppColors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _options.map((opt) {
              final isSelected = _selectedOptionIds.contains(opt.id);

              return GestureDetector(
                onTap: () => _toggleOption(opt.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tagYellowBg : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.gold : AppColors.borderDefault,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(opt.icon ?? '🚍', style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.name,
                              style: AppTheme.montserrat(fontSize: 16, color: isSelected ? AppColors.gold : AppColors.white),
                            ),
                            if (opt.description != null) ...[
                              const SizedBox(height: 4),
                              Text(opt.description!, style: AppTheme.openSans(fontSize: 12, color: AppColors.white70)),
                            ],
                            const SizedBox(height: 8),
                            Text('${opt.price.toInt()} FCFA', style: AppTheme.montserrat(color: AppColors.green, fontSize: 14)),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                        color: isSelected ? AppColors.gold : AppColors.white50,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.cardBg,
            border: Border(top: BorderSide(color: AppColors.borderDefault)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total :', style: AppTheme.montserrat(fontSize: 16)),
                    Text('${totalPrice.toInt()} FCFA', style: AppTheme.montserrat(fontSize: 20, color: AppColors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                EduButton(
                  label: 'Confirmer',
                  onPressed: _selectedOptionIds.isEmpty ? null : _submitTransportChoice,
                ),
              ],
            ),
          ),
        ),
      ],
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
          Text('COTISATION TRANSPORT', style: AppTheme.montserrat(fontSize: 14, color: AppColors.white50), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(widget.child.firstName, style: AppTheme.montserrat(fontSize: 20), textAlign: TextAlign.center),
          Text(goal.name, style: AppTheme.openSans(fontSize: 14, color: AppColors.gold), textAlign: TextAlign.center),
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
            EduButton.green('Payer le transport', onPressed: _payContribution),
            const SizedBox(height: 32),
          ] else ...[
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: AppColors.green.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: AppColors.green),
               ),
               child: Text('🎉 Transport entièrement payé !', 
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
