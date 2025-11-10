// lib/models/user_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'Gmail')
  final String gmail;
  final String? name;
  // final String? phone; // REMOVED
  final double? weight;
  final double? bmi;
  final String? gender;
  final int? age;

  @JsonKey(name: 'Streak')
  final int? streak;

  @JsonKey(name: 'wokrout time')
  final String? workoutTime;
  final double? height;

  @JsonKey(name: 'Profile Picture')
  final String? profilePicture;

  @JsonKey(name: 'userType')
  final String? userType;

  UserModel({
    required this.gmail,
    this.name,
    // this.phone, // REMOVED
    this.weight,
    this.bmi,
    this.gender,
    this.age,
    this.streak,
    this.workoutTime,
    this.height,
    this.profilePicture,
    this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}