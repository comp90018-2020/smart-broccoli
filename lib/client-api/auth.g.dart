// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthenticatedRequestHandler _$AuthenticatedRequestHandlerFromJson(
    Map<String, dynamic> json) {
  return AuthenticatedRequestHandler(
    json['token'] == null
        ? null
        : AuthToken.fromJson(json['token'] as Map<String, dynamic>),
    _$enumDecodeNullable(_$RoleEnumMap, json['role']),
  );
}

Map<String, dynamic> _$AuthenticatedRequestHandlerToJson(
        AuthenticatedRequestHandler instance) =>
    <String, dynamic>{
      'token': instance.token,
      'role': _$RoleEnumMap[instance.role],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$RoleEnumMap = {
  Role.CREATOR: 'CREATOR',
  Role.USER: 'USER',
};

AuthToken _$AuthTokenFromJson(Map<String, dynamic> json) {
  return AuthToken(
    json['value'] as String,
  );
}

Map<String, dynamic> _$AuthTokenToJson(AuthToken instance) => <String, dynamic>{
      'value': instance.value,
    };
