import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class Notification {
  final String id;
  final String? tittle;
  final String? description;

  Notification({
    required this.id,
    this.tittle,
    this.description,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}
