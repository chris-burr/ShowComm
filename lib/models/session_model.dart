import 'package:flutter/foundation.dart';
import 'cue.dart';
import 'user_model.dart';

@immutable
class SessionModel {
  const SessionModel({
    required this.id,
    required this.name,
    required this.framerate,
    required this.version,
    required this.masterDeviceId,
    required this.users,
    required this.cues,
    required this.created,
    this.hostAddress,
    this.hostPort,
  });

  final String id;
  final String name;
  final int framerate;
  final int version;
  final String masterDeviceId;
  final List<UserModel> users;
  final List<Cue> cues;
  final DateTime created;
  final String? hostAddress;
  final int? hostPort;

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        id: json['master_device_id'] as String? ?? '',
        name: json['session'] as String,
        framerate: json['framerate'] as int? ?? 25,
        version: json['version'] as int? ?? 1,
        masterDeviceId: json['master_device_id'] as String? ?? '',
        users: (json['users'] as List<dynamic>?)
                ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        cues: (json['cues'] as List<dynamic>?)
                ?.map((e) => Cue.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        created: DateTime.tryParse(json['created'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'session': name,
        'created': created.toIso8601String(),
        'framerate': framerate,
        'version': version,
        'master_device_id': masterDeviceId,
        'users': users.map((u) => u.toJson()).toList(),
        'cues': cues.map((c) => c.toJson()).toList(),
      };

  SessionModel copyWith({
    String? id,
    String? name,
    int? framerate,
    int? version,
    String? masterDeviceId,
    List<UserModel>? users,
    List<Cue>? cues,
    DateTime? created,
    String? hostAddress,
    int? hostPort,
  }) =>
      SessionModel(
        id: id ?? this.id,
        name: name ?? this.name,
        framerate: framerate ?? this.framerate,
        version: version ?? this.version,
        masterDeviceId: masterDeviceId ?? this.masterDeviceId,
        users: users ?? this.users,
        cues: cues ?? this.cues,
        created: created ?? this.created,
        hostAddress: hostAddress ?? this.hostAddress,
        hostPort: hostPort ?? this.hostPort,
      );
}
