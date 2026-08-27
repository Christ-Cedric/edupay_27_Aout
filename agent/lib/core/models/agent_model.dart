// =============================================================================
// CORE/MODELS/USER_MODEL.DART — Modèle utilisateur/agent
// =============================================================================
import 'dart:convert';

class AgentModel {
  final String id;
  final String fullName;
  final String phone;
  final String zone;
  final String? district;
  final int clientCount;
  final double commission;
  final String contractType;
  final String status;
  final String role; // Retained from earlier but mainly for local use, default 'AGENT'

  AgentModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.zone,
    this.district,
    required this.clientCount,
    required this.commission,
    required this.contractType,
    required this.status,
    required this.role,
  });

  String get initials {
    final parts = fullName.split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    // Handling the case where backend gives full_name inside user or directly
    final user = json['user'] ?? json;
    return AgentModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? user['full_name'] ?? json['fullName'] ?? user['fullName'] ?? '',
      phone: json['phone'] ?? user['phone'] ?? '',
      zone: json['zone'] ?? user['zone'] ?? '',
      district: json['district'] ?? user['district'],
      clientCount: json['client_count'] ?? user['client_count'] ?? 0,
      commission: double.tryParse(json['commission']?.toString() ?? '0') ?? 0,
      contractType: json['contract_type'] ?? user['contract_type'] ?? 'volunteer',
      status: json['status'] ?? user['status'] ?? 'active',
      role: user['role'] ?? json['role'] ?? 'AGENT',
    );
  }

  String toJson() => jsonEncode({
        'id': id,
        'full_name': fullName,
        'phone': phone,
        'zone': zone,
        'district': district,
        'client_count': clientCount,
        'commission': commission,
        'contract_type': contractType,
        'status': status,
        'role': role,
      });
}
