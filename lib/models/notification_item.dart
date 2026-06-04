import 'package:flutter/material.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.color,
    this.isUnread = true,
  });

  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
  final Color color;
  final bool isUnread;
}
