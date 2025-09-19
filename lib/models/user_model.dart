// user_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String gmail;
  final String? name; // Added name field
  final String? phone; // Added phone field
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

  final String? userType;

  UserModel({
    required this.gmail,
    this.name, // Added to constructor
    this.phone, // Added to constructor
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

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}