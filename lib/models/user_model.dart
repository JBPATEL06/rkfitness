import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String gmail;
  final double? weight;
  final double? bmi;
  final String? gender;
  final int? age;
  final int? streak;
  @JsonKey(name: 'wokrout time')
  final String? workoutTime;
  final double? height;
  @JsonKey(name: 'Profile Picture')
  final String? profilePicture;

  User({
    required this.gmail,
    this.weight,
    this.bmi,
    this.gender,
    this.age,
    this.streak,
    this.workoutTime,
    this.height,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
