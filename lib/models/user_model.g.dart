// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  gmail: json['gmail'] as String,
  weight: (json['weight'] as num?)?.toDouble(),
  bmi: (json['bmi'] as num?)?.toDouble(),
  gender: json['gender'] as String?,
  age: (json['age'] as num?)?.toInt(),
  streak: (json['streak'] as num?)?.toInt(),
  workoutTime: json['wokrout time'] as String?,
  height: (json['height'] as num?)?.toDouble(),
  profilePicture: json['Profile Picture'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'gmail': instance.gmail,
  'weight': instance.weight,
  'bmi': instance.bmi,
  'gender': instance.gender,
  'age': instance.age,
  'streak': instance.streak,
  'wokrout time': instance.workoutTime,
  'height': instance.height,
  'Profile Picture': instance.profilePicture,
};
