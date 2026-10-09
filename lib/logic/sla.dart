import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/task.dart';

// SLA RULES (checked in this order, the first one that matches wins):
//   1. Completed: the status is Done.
//   2. Overdue:   the due date has passed.
//   3. At Risk:   the due date is close. "Close" depends on the priority:
//                 High = 3 days or less, Medium = 2 days or less,
//                 Low = 1 day or less.
//   4. On Track:  everything else.
//
// `today` is passed in (instead of using DateTime.now() inside) so the
// tests can use a fixed date.

// How many days are left until the due date. 0 means due today,
// a negative number means the due date has passed.
int daysLeft(DateTime dueDate, DateTime today) {
  DateTime due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  DateTime day = DateTime(today.year, today.month, today.day);
  // We count hours and divide by 24, then round, so a day that is 23 or
  // 25 hours long (daylight saving) still counts as one day.
  return (due.difference(day).inHours / 24).round();
}

// How many days before the deadline a task becomes At Risk.
int riskDays(String priority) {
  if (priority == priorityHigh) {
    return 3;
  } else if (priority == priorityMedium) {
    return 2;
  } else {
    return 1;
  }
}

String getSlaStatus(Task task, DateTime today) {
  if (task.status == statusDone) {
    return slaCompleted;
  }

  int left = daysLeft(task.dueDate, today);

  if (left < 0) {
    return slaOverdue;
  }
  if (left <= riskDays(task.priority)) {
    return slaAtRisk;
  }
  return slaOnTrack;
}

Color getSlaColor(String slaStatus) {
  if (slaStatus == slaCompleted) {
    return completedColor;
  } else if (slaStatus == slaOverdue) {
    return overdueColor;
  } else if (slaStatus == slaAtRisk) {
    return atRiskColor;
  } else {
    return onTrackColor;
  }
}

// A sentence that explains the SLA status, shown on the task details screen.
String getSlaMessage(Task task, DateTime today) {
  String sla = getSlaStatus(task, today);
  int left = daysLeft(task.dueDate, today);

  if (sla == slaCompleted) {
    return 'This task is done.';
  } else if (sla == slaOverdue) {
    return 'The due date passed ${-left} day(s) ago and the task is not done.';
  } else if (sla == slaAtRisk) {
    return 'Only $left day(s) left. ${task.priority} priority tasks become '
        'At Risk ${riskDays(task.priority)} day(s) before the deadline.';
  } else {
    return '$left day(s) left. The task is on schedule.';
  }
}

// Counts how many tasks in the list have the given SLA status.
// Used by the dashboard so the counting is written only once.
int countSla(List<Task> tasks, String slaStatus, DateTime today) {
  int count = 0;
  for (Task task in tasks) {
    if (getSlaStatus(task, today) == slaStatus) {
      count++;
    }
  }
  return count;
}
