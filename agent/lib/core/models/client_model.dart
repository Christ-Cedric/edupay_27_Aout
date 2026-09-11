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
  final List<TransportGoalModel>? transportGoals;
  final String registeredAt;

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
    this.transportGoals,
    required this.registeredAt,
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
      targetAmount: double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'active',
      deliveryStatus: json['delivery_status'] ?? 'pending',
      familyCode: json['family_code'],
      assignedAgentName: json['assigned_agent_name'],
      registeredAt: json['registered_at'] ?? '',
      children: json['children'] != null
          ? (json['children'] as List).map((i) => ChildModel.fromJson(i)).toList()
          : null,
      transportGoals: json['transport_goals'] != null
          ? (json['transport_goals'] as List).map((i) => TransportGoalModel.fromJson(i)).toList()
          : null,
    );
  }
}

class TransportGoalModel {
  final String id;
  final String childId;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String status;
  final String? planFrequency;
  final double? planCapacity;

  TransportGoalModel({
    required this.id,
    required this.childId,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.status,
    this.planFrequency,
    this.planCapacity,
  });

  factory TransportGoalModel.fromJson(Map<String, dynamic> json) {
    return TransportGoalModel(
      id: json['id'] ?? '',
      childId: json['child_id'] ?? '',
      name: json['name'] ?? '',
      targetAmount: double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0,
      savedAmount: double.tryParse(json['saved_amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'active',
      planFrequency: json['plan_frequency'],
      planCapacity: double.tryParse(json['plan_capacity']?.toString() ?? ''),
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
  final List<dynamic>? customAddedItems;
  final SchoolingGoalModel? schoolingGoal;
  final TransportGoalModel? transportGoal;

  ChildModel({
    required this.id,
    required this.firstName,
    this.level,
    this.school,
    this.kitId,
    this.targetAmount,
    this.savedAmount,
    this.customAddedItems,
    this.schoolingGoal,
    this.transportGoal,
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
      customAddedItems: json['custom_added_items'] as List<dynamic>?,
      schoolingGoal: json['schooling_goal'] != null ? SchoolingGoalModel.fromJson(json['schooling_goal']) : null,
      transportGoal: json['transport_goal'] != null ? TransportGoalModel.fromJson(json['transport_goal']) : null,
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

class SchoolingGoalModel {
  final String id;
  final double targetAmount;
  final double savedAmount;
  final String status;
  final String? planFrequency;
  final double? planCapacity;

  SchoolingGoalModel({
    required this.id,
    required this.targetAmount,
    required this.savedAmount,
    required this.status,
    this.planFrequency,
    this.planCapacity,
  });

  factory SchoolingGoalModel.fromJson(Map<String, dynamic> json) {
    return SchoolingGoalModel(
      id: json['id'] ?? '',
      targetAmount: double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0,
      savedAmount: double.tryParse(json['saved_amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'active',
      planFrequency: json['plan_frequency'],
      planCapacity: double.tryParse(json['plan_capacity']?.toString() ?? ''),
    );
  }
}

class SchoolingHistoryModel {
  final String id;
  final double amount;
  final String date;
  final String status;
  final String reference;

  SchoolingHistoryModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    required this.reference,
  });

  factory SchoolingHistoryModel.fromJson(Map<String, dynamic> json) {
    return SchoolingHistoryModel(
      id: json['id'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      reference: json['reference'] ?? '',
    );
  }
}

class TransportOptionModel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final double price;

  TransportOptionModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.price,
  });

  factory TransportOptionModel.fromJson(Map<String, dynamic> json) {
    return TransportOptionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }
}

