import 'package:json_annotation/json_annotation.dart';

part 'workout_table_model.g.dart';

@JsonSerializable()
class WorkoutTableModel {
  @JsonKey(name: 'Workout id')
  final String workoutId;
  @JsonKey(name: 'Workout Name')
  final String workoutName;
  @JsonKey(name: 'Workout type')
  final String workoutType;
  @JsonKey(name: 'Workout Categor')
  final String? workoutCategory;
  final int? sets;
  final int? reps;
  final String? duration;
  @JsonKey(name: 'Gif Path')
  final String? gifPath;
  final String? description;

  WorkoutTableModel({
    required this.workoutId,
    required this.workoutName,
    required this.workoutType,
    this.workoutCategory,
    this.sets,
    this.reps,
    this.duration,
    this.gifPath,
    this.description,
  });

  factory WorkoutTableModel.fromJson(Map<String, dynamic> json) => _$WorkoutTableModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutTableModelToJson(this);
}