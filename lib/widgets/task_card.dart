import 'package:flutter/material.dart';

import '../constants.dart';
import '../data/app_data.dart';
import '../logic/sla.dart';
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

    String assigneeName = AppData.memberName(task.assigneeId);

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // Two separate lines, so a long name is cut with "..." and the
        // due date always stays visible.
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$assigneeName • ${task.priority}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('Due ${formatDate(task.dueDate)}'),
          ],
        ),
        trailing: SlaBadge(slaStatus: sla),
      ),
    );
  }
}
