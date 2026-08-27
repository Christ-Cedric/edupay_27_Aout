// =============================================================================
// CORE/MODELS/CLIENT_MODEL.DART — Modèle client (Famille)
// =============================================================================

class ClientModel {
  final String id;
  final String fullName;
  final String phone;
  final String city;
  final String? district;
  final String plan;
  final double balance;
  final double targetAmount;
  final String status;
  final String deliveryStatus;
  final String? familyCode;
  final String? assignedAgentName;
  final List<ChildModel>? children;
  final String registeredAt;
  final String? temporaryPassword;

  ClientModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.city,
    this.district,
    required this.plan,
    required this.balance,
    required this.targetAmount,
    required this.status,
    required this.deliveryStatus,
    this.familyCode,
    this.assignedAgentName,
    this.children,
    required this.registeredAt,
    this.temporaryPassword,
  });

  String get initials {
    final parts = fullName.split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get isLate => status == 'lateOverdue';
  bool get isCompleted => targetAmount > 0 && balance >= targetAmount;

  // Backward compatibility for lateWeeks if UI needs it
  int get lateWeeks => isLate ? 1 : 0;
  String get address => city;

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      city: json['city'] ?? '',
      district: json['district'],
      plan: json['plan'] ?? 'weekly',
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      targetAmount:
          double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'active',
      deliveryStatus: json['delivery_status'] ?? 'pending',
      familyCode: json['family_code'],
      assignedAgentName: json['assigned_agent_name'],
      registeredAt: json['registered_at'] ?? '',
      temporaryPassword: json['temporary_password'],
      children: json['children'] != null
          ? (json['children'] as List)
                .map((i) => ChildModel.fromJson(i))
                .toList()
          : null,
    );
  }
}

class ChildModel {
  final String id;
  final String firstName;
  final String? level;
  final String? school;
  final String? kitId;
  final double? targetAmount;
  final double? savedAmount;

  ChildModel({
    required this.id,
    required this.firstName,
    this.level,
    this.school,
    this.kitId,
    this.targetAmount,
    this.savedAmount,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      level: json['level'],
      school: json['school'],
      kitId: json['kit_id'],
      targetAmount: double.tryParse(json['target_amount']?.toString() ?? '0'),
      savedAmount: double.tryParse(json['saved_amount']?.toString() ?? '0'),
    );
  }
}

// Retained simple version of Wallet/SavingPlan if needed by other models but not primarily used in ClientModel anymore
class SavingPlanModel {
  final String id;
  final String name;
  final String frequency;
  final double amount;
  final double goalAmount;

  SavingPlanModel({
    required this.id,
    required this.name,
    required this.frequency,
    required this.amount,
    required this.goalAmount,
  });

  factory SavingPlanModel.fromJson(Map<String, dynamic> json) {
    return SavingPlanModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      frequency: json['frequency'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      goalAmount: double.tryParse(json['goalAmount']?.toString() ?? '0') ?? 0,
    );
  }
}
