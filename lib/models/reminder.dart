import '../utils/json_utils.dart';

class ReminderItem {
  final String publicId;
  final String title;
  final String type;
  final String status;
  final String reminderDateTime;
  final String customerName;

  ReminderItem({required this.publicId, required this.title, required this.type, required this.status, required this.reminderDateTime, required this.customerName});

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      publicId: JsonUtils.str(json['public_id'] ?? json['publicId']),
      title: JsonUtils.str(json['title']),
      type: JsonUtils.str(json['reminder_type'] ?? json['reminderType']),
      status: JsonUtils.str(json['reminder_status'] ?? json['reminderStatus']),
      reminderDateTime: JsonUtils.str(json['reminder_datetime'] ?? json['reminderDateTime']),
      customerName: JsonUtils.str(json['customer_name'] ?? json['customerName']),
    );
  }
}
