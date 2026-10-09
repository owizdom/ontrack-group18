import 'package:flutter/material.dart';

// These are the colours used everywhere in the app, so every screen looks the same
const Color mainColor = Color(0xFF5B3FD6);
const Color backgroundColor = Color(0xFFF5F5FA);
const Color onTrackColor = Color(0xFF2E9E5B);
const Color atRiskColor = Color(0xFFE08A00);
const Color overdueColor = Color(0xFFD64545);
const Color completedColor = Color(0xFF6B7280);

// The names of the task statuses, the priorities and the SLA statuses.
// Each name is written once here, so a typing mistake in one screen
// cannot break a comparison.
const String statusToDo = 'To Do';
const String statusInProgress = 'In Progress';
const String statusDone = 'Done';

const String priorityLow = 'Low';
const String priorityMedium = 'Medium';
const String priorityHigh = 'High';

const String slaOnTrack = 'On Track';
const String slaAtRisk = 'At Risk';
const String slaOverdue = 'Overdue';
const String slaCompleted = 'Completed';

// Choices shown in the dropdowns on task form
const List<String> priorities = [priorityLow, priorityMedium, priorityHigh];
const List<String> statuses = [statusToDo, statusInProgress, statusDone];

// Turn a date into text like "12/10/2026"
String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
