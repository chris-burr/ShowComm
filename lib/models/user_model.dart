import 'package:flutter/foundation.dart';

enum Permission {
  directEdit,
  propose,
  view;

  String get label => switch (this) {
        Permission.directEdit => 'Editor',
        Permission.propose => 'Propose',
        Permission.view => 'Viewer',
      };

  String get jsonValue => switch (this) {
        Permission.directEdit => 'direct_edit',
        Permission.propose => 'propose',
        Permission.view => 'view',
      };

  static Permission fromJson(String value) => switch (value) {
        'direct_edit' => Permission.directEdit,
        'propose' => Permission.propose,
        _ => Permission.view,
      };
}

@immutable
class UserModel {
  const UserModel({
    required this.name,
    required this.role,
    required this.permission,
    this.isMaster = false,
    this.deviceId,
    this.isConnected = false,
  });

  final String name;
  final String role;
  final Permission permission;
  final bool isMaster;
  final String? deviceId;
  final bool isConnected;

  String get initials {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] as String,
        role: json['role'] as String,
        permission: Permission.fromJson(json['permission'] as String),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'permission': permission.jsonValue,
      };

  UserModel copyWith({
    String? name,
    String? role,
    Permission? permission,
    bool? isMaster,
    String? deviceId,
    bool? isConnected,
  }) =>
      UserModel(
        name: name ?? this.name,
        role: role ?? this.role,
        permission: permission ?? this.permission,
        isMaster: isMaster ?? this.isMaster,
        deviceId: deviceId ?? this.deviceId,
        isConnected: isConnected ?? this.isConnected,
      );
}
