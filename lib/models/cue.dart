import 'package:flutter/foundation.dart';

@immutable
class Cue {
  const Cue({
    required this.id,
    required this.label,
    required this.timecode,
  });

  final int id;
  final String label;
  final String timecode; // "HH:MM:SS:FF"

  int toFrames(int framerate) {
    final parts = timecode.split(':');
    if (parts.length != 4) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final s = int.tryParse(parts[2]) ?? 0;
    final f = int.tryParse(parts[3]) ?? 0;
    return ((h * 3600 + m * 60 + s) * framerate) + f;
  }

  factory Cue.fromJson(Map<String, dynamic> json) => Cue(
        id: json['id'] as int,
        label: json['label'] as String,
        timecode: json['timecode'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'timecode': timecode,
      };

  Cue copyWith({int? id, String? label, String? timecode}) => Cue(
        id: id ?? this.id,
        label: label ?? this.label,
        timecode: timecode ?? this.timecode,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cue &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          timecode == other.timecode;

  @override
  int get hashCode => Object.hash(id, label, timecode);
}
