import 'package:flutter_test/flutter_test.dart';
import 'package:sla_tracker/logic/sla.dart';
import 'package:sla_tracker/models/task.dart';

void main() {
  // A fixed "today" so the tests always give the same answer.
  DateTime today = DateTime(2026, 10, 10);

  Task makeTask(int daysFromToday, String priority, String status) {
    return Task(
      id: '1',
      title: 'Test task',
      description: '',
      assigneeId: 'm1',
      priority: priority,
      status: status,
      dueDate: today.add(Duration(days: daysFromToday)),
    );
  }

  test('a done task is Completed, even if the date has passed', () {
    expect(getSlaStatus(makeTask(-5, 'High', 'Done'), today), 'Completed');
  });

  test('an open task past its due date is Overdue', () {
    expect(getSlaStatus(makeTask(-1, 'Low', 'In Progress'), today), 'Overdue');
  });

  test('a task due today is At Risk, not Overdue', () {
    expect(getSlaStatus(makeTask(0, 'Low', 'To Do'), today), 'At Risk');
  });

  test('High priority becomes At Risk 3 days before', () {
    expect(getSlaStatus(makeTask(3, 'High', 'To Do'), today), 'At Risk');
    expect(getSlaStatus(makeTask(4, 'High', 'To Do'), today), 'On Track');
  });

  test('Medium priority becomes At Risk 2 days before', () {
    expect(getSlaStatus(makeTask(2, 'Medium', 'To Do'), today), 'At Risk');
    expect(getSlaStatus(makeTask(3, 'Medium', 'To Do'), today), 'On Track');
  });

  test('Low priority becomes At Risk 1 day before', () {
    expect(getSlaStatus(makeTask(1, 'Low', 'To Do'), today), 'At Risk');
    expect(getSlaStatus(makeTask(2, 'Low', 'To Do'), today), 'On Track');
  });

  test('the SLA message explains the status', () {
    expect(
      getSlaMessage(makeTask(-2, 'Low', 'To Do'), today),
      contains('2 day(s) ago'),
    );
    expect(getSlaMessage(makeTask(5, 'Low', 'Done'), today), contains('done'));
  });

  test('countSla counts the tasks with one SLA status', () {
    List<Task> tasks = [
      makeTask(-1, 'High', 'To Do'), // Overdue
      makeTask(-3, 'Low', 'In Progress'), // Overdue
      makeTask(10, 'Low', 'To Do'), // On Track
      makeTask(-5, 'High', 'Done'), // Completed
    ];
    expect(countSla(tasks, 'Overdue', today), 2);
    expect(countSla(tasks, 'On Track', today), 1);
    expect(countSla(tasks, 'Completed', today), 1);
    expect(countSla(tasks, 'At Risk', today), 0);
  });
}
