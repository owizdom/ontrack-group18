import 'package:flutter/material.dart';

// These are the colours used everywhere in the app, so every screen looks the same
const Color mainColor = Color(0xFF5B3FD6);
const Color backgroundColor = Color(0xFFF5F5FA);
const Color onTrackColor = Color(0xFF2E9E5B);
const Color atRiskColor = Color(0xFFE08A00);
const Color overdueColor = Color(0xFFD64545);
const Color completedColor = Color(0xFF6B7280);

// Choices shown in the dropdowns on task form
const List<String> priorities = ['Low', 'Medium', 'High'];
const List<String> statuses = ['To Do', 'In Progress', 'Done'];

// Turn a date into text like "12/10/2026"
String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
