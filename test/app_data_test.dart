import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sla_tracker/data/app_data.dart';
import 'package:sla_tracker/models/member.dart';
import 'package:sla_tracker/models/task.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('the first launch adds sample data', () async {
    await AppData.load();
    expect(AppData.members.length, 4);
    expect(AppData.tasks.isNotEmpty, true);
    expect(AppData.currentUserId, '');
  });

  test('saved data comes back after a restart', () async {
    await AppData.load();
    AppData.tasks.add(
      Task(
        id: 'new',
        title: 'Saved task',
        description: '',
        assigneeId: 'm1',
        priority: 'High',
        status: 'To Do',
        dueDate: DateTime(2026, 12, 1),
      ),
    );
    AppData.currentUserId = 'm1';
    await AppData.save();

    // Clear the lists to act like the app was closed, then load again.
    AppData.tasks = [];
    AppData.currentUserId = '';
    bool ok = await AppData.load();

    expect(ok, true);
    expect(AppData.tasks.last.title, 'Saved task');
    expect(AppData.currentUserId, 'm1');
  });

  test('sample data does not come back after deleting everything', () async {
    await AppData.load();
    AppData.tasks = [];
    await AppData.save();
    await AppData.load();
    expect(AppData.tasks.isEmpty, true);
  });

  test('damaged saved data does not crash the app', () async {
    SharedPreferences.setMockInitialValues({
      'seeded': true,
      'tasks': 'not json',
    });
    bool ok = await AppData.load();
    expect(ok, false);
    expect(AppData.tasks.isEmpty, true);
  });

  test('damaged member data does not crash the app', () async {
    SharedPreferences.setMockInitialValues({
      'seeded': true,
      'tasks': '[]',
      'members': 'not json',
    });
    bool ok = await AppData.load();
    expect(ok, false);
    expect(AppData.members.isEmpty, true);
  });

  test('a task is the same after saving and loading', () {
    Task task = Task(
      id: 't9',
      title: 'Write report',
      description: 'Two pages',
      assigneeId: 'm3',
      priority: 'Low',
      status: 'In Progress',
      dueDate: DateTime(2026, 10, 20),
    );

    Task copy = Task.fromMap(task.toMap());

    expect(copy.id, task.id);
    expect(copy.title, task.title);
    expect(copy.description, task.description);
    expect(copy.assigneeId, task.assigneeId);
    expect(copy.priority, task.priority);
    expect(copy.status, task.status);
    expect(copy.dueDate, task.dueDate);
  });

  test('member initials use the first two names', () {
    Member member = Member(
      id: 'm1',
      name: 'Abigail Salem Tendo',
      email: 'a@b.co',
      role: 'UI',
    );
    expect(member.initials(), 'AS');
  });
}
