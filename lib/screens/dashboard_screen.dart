import 'package:flutter/material.dart';

import '../constants.dart';
import '../data/app_data.dart';
import '../logic/sla.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';

// The project at a glance: progress, how many tasks have each SLA status,
// and the tasks that need attention.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void openTask(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
    );
    // The task may have changed, so rebuild with the new data.
    setState(() {});
  }

  void addTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TaskFormScreen()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    // Count the tasks for each SLA status.
    int onTrack = countSla(AppData.tasks, slaOnTrack, today);
    int atRisk = countSla(AppData.tasks, slaAtRisk, today);
    int overdue = countSla(AppData.tasks, slaOverdue, today);
    int completed = countSla(AppData.tasks, slaCompleted, today);

    // The tasks that need attention: Overdue or At Risk.
    List<Task> needsAttention = [];
    for (Task task in AppData.tasks) {
      String sla = getSlaStatus(task, today);
      if (sla == slaOverdue || sla == slaAtRisk) {
        needsAttention.add(task);
      }
    }
    // Soonest due date first, the same order as the task list.
    needsAttention.sort((a, b) {
      return a.dueDate.compareTo(b.dueDate);
    });

    // Progress = completed tasks / all tasks. Check for 0 first so we never
    // divide by zero.
    double progress = 0;
    if (AppData.tasks.isNotEmpty) {
      progress = completed / AppData.tasks.length;
    }

    String firstName = AppData.currentUser()!.name.split(' ')[0];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hello, $firstName',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Progress card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('$completed of ${AppData.tasks.length} tasks completed'),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: progress, minHeight: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Two rows of two boxes. Expanded makes both boxes in a row
          // share the width equally.
          Row(
            children: [
              Expanded(child: countBox(slaOnTrack, onTrack, onTrackColor)),
              Expanded(child: countBox(slaAtRisk, atRisk, atRiskColor)),
            ],
          ),
          Row(
            children: [
              Expanded(child: countBox(slaOverdue, overdue, overdueColor)),
              Expanded(
                child: countBox(slaCompleted, completed, completedColor),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Needs attention',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (needsAttention.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nothing is overdue or at risk. Good job!'),
            ),
          for (Task task in needsAttention)
            TaskCard(task: task, onTap: () => openTask(task)),
          const SizedBox(height: 80), // space so the + button covers nothing
        ],
      ),
    );
  }

  // One coloured box with a number and a label.
  Widget countBox(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
