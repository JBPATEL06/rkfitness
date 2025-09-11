import 'package:json_annotation/json_annotation.dart';

part 'user_progress_model.g.dart';

@JsonSerializable()
class UserProgress {
  final String id;
  final String? day;
  @JsonKey(name: 'workout count')
  final int? workoutCount;
  @JsonKey(name: 'all complete')
  final bool? allComplete;
  @JsonKey(name: 'time stamp')
  final DateTime? timeStamp;

  UserProgress({
    required this.id,
    this.day,
    this.workoutCount,
    this.allComplete,
    this.timeStamp,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) => _$UserProgressFromJson(json);

  Map<String, dynamic> toJson() => _$UserProgressToJson(this);
}
