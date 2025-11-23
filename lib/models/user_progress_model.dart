// lib/models/user_progress_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'user_progress_model.g.dart';

@JsonSerializable()
class UserProgressModel {
  // Required because the database table is NOT NULL
  final String id;

  @JsonKey(name: 'day')
  final String? day;

  @JsonKey(name: 'time stamp')
  final DateTime? time;

  @JsonKey(name: 'User Email')
  final String? userEmail;

  @JsonKey(name: 'completedExercise')
  final int? completedExerciseCount;

  @JsonKey(name: 'completedCardio')
  final int? completedCardioCount;

  UserProgressModel({
    required this.id, // Made required
    this.day,
    this.time,
    this.userEmail,
    this.completedExerciseCount,
    this.completedCardioCount,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) => _$UserProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProgressModelToJson(this);
}