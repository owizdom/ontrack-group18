// One task in the project.
class Task {
  String id;
  String title;
  String description;
  String assigneeId; // id of the team member doing it, '' if nobody
  String priority; // 'Low', 'Medium' or 'High'
  String status; // 'To Do', 'In Progress' or 'Done'
  DateTime dueDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assigneeId,
    required this.priority,
    required this.status,
    required this.dueDate,
  });

  // Turns the task into a Map so it can be saved as JSON text.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigneeId': assigneeId,
      'priority': priority,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
    };
  }

  // Builds a task back from a saved Map.
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      assigneeId: map['assigneeId'],
      priority: map['priority'],
      status: map['status'],
      dueDate: DateTime.parse(map['dueDate']),
    );
  }
}
