import 'package:flutter/material.dart';

import '../constants.dart';
import '../data/app_data.dart';
import '../logic/sla.dart';
import '../models/member.dart';
import '../models/task.dart';
import 'sla_badge.dart';

// One task in a list. Used on the dashboard and on the task list.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String sla = getSlaStatus(task, DateTime.now());

    Member? assignee = AppData.findMember(task.assigneeId);
    String assigneeName = 'Unassigned';
    if (assignee != null) {
      assigneeName = assignee.name;
    }

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$assigneeName • ${task.priority}\nDue ${formatDate(task.dueDate)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: SlaBadge(slaStatus: sla),
      ),
    );
  }
}
