import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String? id; // FIXED: Changed to String? to match UUID table definition
  @JsonKey(name: 'tittle') // FIX: Map the database column name 'tittle'
  final String? title;
  final String? description;

  NotificationModel({
    this.id,
    this.title,
    this.description,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}