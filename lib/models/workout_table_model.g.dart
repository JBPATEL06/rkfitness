// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_table_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutTableModel _$WorkoutTableModelFromJson(Map<String, dynamic> json) =>
    WorkoutTableModel(
      workoutId: json['Workout id'] as String,
      workoutName: json['Workout Name'] as String,
      workoutType: json['Workout type'] as String,
      workoutCategory: json['Workout Categor'] as String?,
      sets: (json['sets'] as num?)?.toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      duration: json['duration'] as String?,
      gifPath: json['Gif Path'] as String?,
      description: json['Description'] as String?,
    );

Map<String, dynamic> _$WorkoutTableModelToJson(WorkoutTableModel instance) =>
    <String, dynamic>{
      'Workout id': instance.workoutId,
      'Workout Name': instance.workoutName,
      'Workout type': instance.workoutType,
      'Workout Categor': instance.workoutCategory,
      'sets': instance.sets,
      'reps': instance.reps,
      'duration': instance.duration,
      'Gif Path': instance.gifPath,
      'Description': instance.description,
    };
