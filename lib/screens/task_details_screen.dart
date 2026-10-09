import 'package:flutter/material.dart';

import '../constants.dart';
import '../data/app_data.dart';
import '../logic/sla.dart';
import '../models/task.dart';
import '../widgets/sla_badge.dart';
import 'task_form_screen.dart';

// Shows one task. The status can be changed here, and the SLA box
// explains why the task has its SLA status.
class TaskDetailsScreen extends StatefulWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  void changeStatus(String newStatus) async {
    setState(() {
      widget.task.status = newStatus;
    });
    await AppData.save();
  }

  void editTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: widget.task),
      ),
    );
    setState(() {});
  }

  void deleteTask() async {
    // Ask first. showDialog returns true only if "Delete" was pressed.
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${widget.task.title}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: overdueColor)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    AppData.tasks.remove(widget.task);
    await AppData.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Task deleted')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Task task = widget.task;
    DateTime today = DateTime.now();
    String sla = getSlaStatus(task, today);
    Color slaColor = getSlaColor(sla);

    String assigneeName = AppData.memberName(task.assigneeId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
        actions: [
          IconButton(
            onPressed: deleteTask,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete task',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            task.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(task.description.isEmpty ? 'No description' : task.description),
          const SizedBox(height: 16),

          // SLA box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: slaColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wrap moves the badge to the next line on a narrow screen.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'SLA status: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SlaBadge(slaStatus: sla),
                  ],
                ),
                const SizedBox(height: 8),
                Text(getSlaMessage(task, today)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Assigned to'),
                  subtitle: Text(assigneeName),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Due date'),
                  trailing: Text(formatDate(task.dueDate)),
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Priority'),
                  trailing: Text(task.priority),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            key: const Key('statusDropdown'),
            value: task.status,
            isExpanded: true,
            items: [
              for (String status in statuses)
                DropdownMenuItem(value: status, child: Text(status)),
            ],
            onChanged: (value) {
              if (value != null) {
                changeStatus(value);
              }
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: editTask,
            icon: const Icon(Icons.edit),
            label: const Text('Edit task'),
          ),
        ],
      ),
    );
  }
}
