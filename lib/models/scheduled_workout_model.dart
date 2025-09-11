import 'package:json_annotation/json_annotation.dart';

part 'scheduled_workout_model.g.dart';

@JsonSerializable()
class ScheduledWorkout {
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
  @JsonKey(name: 'custom_duration')
  final int? customDuration;
  @JsonKey(name: 'order_in_day')
  final int? orderInDay;

  ScheduledWorkout({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.dayOfWeek,
    this.customSets,
    this.customReps,
    this.customDuration,
    this.orderInDay,
  });

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) => _$ScheduledWorkoutFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduledWorkoutToJson(this);
}
