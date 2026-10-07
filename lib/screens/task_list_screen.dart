import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../logic/sla.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';

// All tasks, with a search box and filters by SLA status.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String searchText = '';
  String selectedFilter = 'All';

  List<String> filters = ['All', 'On Track', 'At Risk', 'Overdue', 'Completed'];

  void openTask(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
    );
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
    // Keep only the tasks that match the search text and the filter.
    List<Task> shownTasks = [];
    for (Task task in AppData.tasks) {
      bool matchesSearch = task.title.toLowerCase().contains(
        searchText.toLowerCase(),
      );
      bool matchesFilter =
          selectedFilter == 'All' ||
          getSlaStatus(task, DateTime.now()) == selectedFilter;
      if (matchesSearch && matchesFilter) {
        shownTasks.add(task);
      }
    }

    // Put the most urgent tasks at the top.
    shownTasks.sort((a, b) {
      // Finished tasks go to the bottom of the list.
      if (a.status == 'Done' && b.status != 'Done') {
        return 1;
      }
      if (b.status == 'Done' && a.status != 'Done') {
        return -1;
      }
      // Otherwise, the soonest due date comes first.
      return a.dueDate.compareTo(b.dueDate);
    });

    // A different message when there are no tasks at all, and when the
    // search or filter hides them all.
    String emptyMessage = 'No tasks match your search or filter.';
    if (AppData.tasks.isEmpty) {
      emptyMessage = 'No tasks yet. Tap + to add one.';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton(
        key: const Key('addTaskButton'),
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('searchField'),
            decoration: const InputDecoration(
              hintText: 'Search tasks',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Wrap puts the chips on a new line if they do not fit.
          Wrap(
            spacing: 8,
            children: [
              for (String filter in filters)
                ChoiceChip(
                  label: Text(filter),
                  selected: selectedFilter == filter,
                  onSelected: (selected) {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (shownTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(emptyMessage, textAlign: TextAlign.center),
            ),
          for (Task task in shownTasks)
            TaskCard(task: task, onTap: () => openTask(task)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}