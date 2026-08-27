// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Session _$SessionFromJson(Map<String, dynamic> json) => _Session(
  userId: json['userId'] as String,
  displayName: json['displayName'] as String,
  phone: json['phone'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  token: json['token'] as String,
);

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'userId': instance.userId,
  'displayName': instance.displayName,
  'phone': instance.phone,
  'role': _$UserRoleEnumMap[instance.role]!,
  'token': instance.token,
};

const _$UserRoleEnumMap = {UserRole.admin: 'admin', UserRole.agent: 'agent'};
