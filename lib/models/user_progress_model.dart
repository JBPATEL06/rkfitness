// lib/models/user_progress_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'user_progress_model.g.dart';

@JsonSerializable()
class UserProgressModel {
  final String? id;

  @JsonKey(name: 'day')
  final String? day;

  @JsonKey(name: 'time stamp')
  final DateTime? time;

  @JsonKey(name: 'User Email')
  final String? userEmail;

  // NEW Columns reflecting the total count of completed workouts for the day
  @JsonKey(name: 'completedExercise')
  final int? completedExerciseCount;

  @JsonKey(name: 'completedCardio')
  final int? completedCardioCount;

  // REMOVED OLD COLUMNS: completed_exercise_ids, completed_cardio_ids, sets_list, reps_list, duration_list_seconds

  UserProgressModel({
    this.id,
    this.day,
    this.time,
    this.userEmail,
    this.completedExerciseCount,
    this.completedCardioCount,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) => _$UserProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProgressModelToJson(this);
}
