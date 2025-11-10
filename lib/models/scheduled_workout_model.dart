// lib/models/scheduled_workout_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'scheduled_workout_model.g.dart';

@JsonSerializable()
class ScheduleWorkoutModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'workout_id')
  final String workoutId;
  @JsonKey(name: 'day_of_week')
  final String dayOfWeek;
  @JsonKey(name: 'custom_sets')
  final int? customSets;
  @JsonKey(name: 'custom_reps')
  final int? customReps;

  // CORRECTED: This now matches the 'custom_duration' column in your SQL table
  @JsonKey(name: 'custom_duration')
  final int? customDuration;

  @JsonKey(name: 'order_in_day')
  final int? orderInDay;

  ScheduleWorkoutModel({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.dayOfWeek,
    this.customSets,
    this.customReps,
    this.customDuration,
    this.orderInDay,
  });

  factory ScheduleWorkoutModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleWorkoutModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleWorkoutModelToJson(this);
}