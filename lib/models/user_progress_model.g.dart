// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProgressModel _$UserProgressModelFromJson(Map<String, dynamic> json) =>
    UserProgressModel(
      id: json['id'] as String?,
      day: json['day'] as String?,
      time: json['time stamp'] == null
          ? null
          : DateTime.parse(json['time stamp'] as String),
      userEmail: json['User Email'] as String?,
      completedExerciseCount: (json['completedExercise'] as num?)?.toInt(),
      completedCardioCount: (json['completedCardio'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserProgressModelToJson(UserProgressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day': instance.day,
      'time stamp': instance.time?.toIso8601String(),
      'User Email': instance.userEmail,
      'completedExercise': instance.completedExerciseCount,
      'completedCardio': instance.completedCardioCount,
    };
