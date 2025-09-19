// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_workout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleWorkoutModel _$ScheduleWorkoutModelFromJson(
  Map<String, dynamic> json,
) => ScheduleWorkoutModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  workoutId: json['workout_id'] as String,
  dayOfWeek: json['day_of_week'] as String,
  customSets: (json['custom_sets'] as num?)?.toInt(),
  customReps: (json['custom_reps'] as num?)?.toInt(),
  customDuration: (json['custom_duration_integer'] as num?)?.toInt(),
  orderInDay: (json['order_in_day'] as num?)?.toInt(),
);

Map<String, dynamic> _$ScheduleWorkoutModelToJson(
  ScheduleWorkoutModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'workout_id': instance.workoutId,
  'day_of_week': instance.dayOfWeek,
  'custom_sets': instance.customSets,
  'custom_reps': instance.customReps,
  'custom_duration_integer': instance.customDuration,
  'order_in_day': instance.orderInDay,
};
