import 'package:json_annotation/json_annotation.dart';

part 'workout_model.g.dart';

@JsonSerializable()
class Workout {
  @JsonKey(name: 'Workout id')
  final String workoutId;
  @JsonKey(name: 'Workout Name')
  final String workoutName;
  @JsonKey(name: 'Workout type')
  final String? workoutType;
  @JsonKey(name: 'Workout Categor')
  final String? workoutCategory;
  final int? sets;
  final int? reps;
  final String? duration;
  @JsonKey(name: 'Gif Path')
  final String? gifPath;
  final String? description;

  Workout({
    required this.workoutId,
    required this.workoutName,
    this.workoutType,
    this.workoutCategory,
    this.sets,
    this.reps,
    this.duration,
    this.gifPath,
    this.description,
  });

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}
