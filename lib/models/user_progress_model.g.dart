// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) => UserProgress(
  id: json['id'] as String,
  day: json['day'] as String?,
  workoutCount: (json['workout count'] as num?)?.toInt(),
  allComplete: json['all complete'] as bool?,
  timeStamp: json['time stamp'] == null
      ? null
      : DateTime.parse(json['time stamp'] as String),
);

Map<String, dynamic> _$UserProgressToJson(UserProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day': instance.day,
      'workout count': instance.workoutCount,
      'all complete': instance.allComplete,
      'time stamp': instance.timeStamp?.toIso8601String(),
    };
