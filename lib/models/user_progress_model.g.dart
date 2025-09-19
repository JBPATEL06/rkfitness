// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProgressModel _$UserProgressModelFromJson(Map<String, dynamic> json) =>
    UserProgressModel(
      gmailId: json['Gmail id'] as String?,
      day: json['day'] as String?,
      workoutCount: (json['workout count'] as num?)?.toInt(),
      allComplete: json['all complete'] as bool?,
      date: json['Date'] == null
          ? null
          : DateTime.parse(json['Date'] as String),
    );

Map<String, dynamic> _$UserProgressModelToJson(UserProgressModel instance) =>
    <String, dynamic>{
      'Gmail id': instance.gmailId,
      'day': instance.day,
      'workout count': instance.workoutCount,
      'all complete': instance.allComplete,
      'Date': instance.date?.toIso8601String(),
    };
