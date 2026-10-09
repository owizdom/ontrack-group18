import 'package:flutter/material.dart';

import '../constants.dart';
import '../data/app_data.dart';
import '../models/member.dart';
import '../models/task.dart';

// One form for both creating a new task and editing an existing one.
// If `task` is null we are creating, otherwise we are editing it.
class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  // The key lets us validate all the fields at once.
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();

  String? selectedAssigneeId;
  String selectedPriority = priorityMedium;
  String selectedStatus = statusToDo;
  DateTime? selectedDate;
  bool triedToSave = false; // becomes true after the first press on Save

  @override
  void initState() {
    super.initState();
    // When editing, fill the form with the task's current values.
    Task? task = widget.task;
    if (task != null) {
      titleController.text = task.title;
      descriptionController.text = task.description;
      selectedPriority = task.priority;
      selectedStatus = task.status;
      selectedDate = task.dueDate;
      dateController.text = formatDate(task.dueDate);
      // Only keep the assignee if they are still on the team.
      if (AppData.findMember(task.assigneeId) != null) {
        selectedAssigneeId = task.assigneeId;
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void pickDate() async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    // A new task cannot be due in the past, so the calendar starts today.
    // An old task that is already overdue may keep its date, so for that
    // task the calendar starts at its current due date.
    DateTime firstDate = today;
    if (selectedDate != null && selectedDate!.isBefore(today)) {
      firstDate = selectedDate!;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today.add(const Duration(days: 7)),
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = formatDate(picked);
      });
    }
  }

  // Validation rules. Each returns an error message, or null if it is fine.
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a title';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  void saveTask() async {
    // validate() runs every validator and shows the error messages.
    if (!formKey.currentState!.validate()) {
      setState(() {
        triedToSave = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }

    if (widget.task == null) {
      // Create a new task and add it to the list.
      Task newTask = Task(
        id: AppData.newId(),
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        assigneeId: selectedAssigneeId!,
        priority: selectedPriority,
        status: selectedStatus,
        dueDate: selectedDate!,
      );
      AppData.tasks.insert(0, newTask); // at the start of the list
    } else {
      // Change the existing task.
      Task task = widget.task!;
      task.title = titleController.text.trim();
      task.description = descriptionController.text.trim();
      task.assigneeId = selectedAssigneeId!;
      task.priority = selectedPriority;
      task.status = selectedStatus;
      task.dueDate = selectedDate!;
    }

    await AppData.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.task == null ? 'Task created' : 'Task updated'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool editing = widget.task != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit task' : 'New task')),
      body: Form(
        key: formKey,
        // Errors only show after the first press on Save. From then on
        // the form checks the fields again every time something changes.
        autovalidateMode: triedToSave
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        // SingleChildScrollView lets the form scroll when the keyboard is
        // open. All fields stay built, so all of them get validated.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('titleField'),
                controller: titleController,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: validateTitle,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: const Key('assigneeField'),
                initialValue: selectedAssigneeId,
                isExpanded: true, // long names are cut instead of overflowing
                decoration: const InputDecoration(labelText: 'Assign to'),
                items: [
                  for (Member member in AppData.members)
                    DropdownMenuItem(
                      value: member.id,
                      child: Text(member.name),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedAssigneeId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please choose a team member';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // readOnly: tapping opens the date picker, not the keyboard.
              TextFormField(
                key: const Key('dateField'),
                controller: dateController,
                readOnly: true,
                onTap: pickDate,
                decoration: const InputDecoration(
                  labelText: 'Due date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (selectedDate == null) {
                    return 'Please pick a due date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: [
                  for (String priority in priorities)
                    DropdownMenuItem(value: priority, child: Text(priority)),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  for (String status in statuses)
                    DropdownMenuItem(value: status, child: Text(status)),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('saveTaskButton'),
                onPressed: saveTask,
                child: Text(editing ? 'Save changes' : 'Create task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
