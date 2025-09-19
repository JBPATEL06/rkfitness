import 'package:json_annotation/json_annotation.dart';

part 'user_progress_model.g.dart';

@JsonSerializable()
class UserProgressModel {
  @JsonKey(name: 'Gmail id')
  final String? gmailId;
  final String? day;
  @JsonKey(name: 'workout count')
  final int? workoutCount;
  @JsonKey(name: 'all complete')
  final bool? allComplete;
  @JsonKey(name: 'Date')
  final DateTime? date;

  UserProgressModel({
    this.gmailId,
    this.day,
    this.workoutCount,
    this.allComplete,
    this.date,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) => _$UserProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProgressModelToJson(this);
}