import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sla_tracker/data/app_data.dart';
import 'package:sla_tracker/models/task.dart';
import 'package:sla_tracker/screens/task_list_screen.dart';

void main() {
  Task makeTask(String title, int daysFromToday, String status) {
    return Task(
      id: title,
      title: title,
      description: '',
      assigneeId: '',
      priority: 'Low',
      status: status,
      dueDate: DateTime.now().add(Duration(days: daysFromToday)),
    );
  }

  testWidgets('soonest due date first, finished tasks last', (tester) async {
    AppData.members = [];
    AppData.tasks = [
      makeTask('Later', 9, 'To Do'),
      makeTask('Finished', -3, 'Done'),
      makeTask('Soon', 2, 'In Progress'),
    ];

    await tester.pumpWidget(const MaterialApp(home: TaskListScreen()));

    double soon = tester.getTopLeft(find.text('Soon')).dy;
    double later = tester.getTopLeft(find.text('Later')).dy;
    double finished = tester.getTopLeft(find.text('Finished')).dy;
    expect(soon < later, true);
    expect(later < finished, true);
  });

  testWidgets('different empty messages', (tester) async {
    AppData.members = [];
    AppData.tasks = [];
    await tester.pumpWidget(const MaterialApp(home: TaskListScreen()));
    expect(find.text('No tasks yet. Tap + to add one.'), findsOneWidget);

    AppData.tasks = [makeTask('Only task', 5, 'To Do')];
    await tester.pumpWidget(const MaterialApp(home: TaskListScreen()));
    await tester.enterText(find.byKey(const Key('searchField')), 'zzz');
    await tester.pump();
    expect(find.text('No tasks match your search or filter.'), findsOneWidget);
  });
}