import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sla_tracker/constants.dart';
import 'package:sla_tracker/data/app_data.dart';
import 'package:sla_tracker/main.dart';
import 'package:sla_tracker/models/task.dart';
import 'package:sla_tracker/screens/task_details_screen.dart';
import 'package:sla_tracker/screens/task_form_screen.dart';
import 'package:sla_tracker/widgets/task_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // Starts the app the same way main() does.
  Future<void> startApp(WidgetTester tester) async {
    bool ok = await AppData.load();
    // Remove any app from an earlier start, like closing it.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(MyApp(loadedOk: ok));
    await tester.pumpAndSettle();
  }

  // Opens the new member form from the sign in screen.
  Future<void> openMemberForm(WidgetTester tester) async {
    await tester.scrollUntilVisible(find.text('Add a new member'), 100);
    await tester.ensureVisible(find.text('Add a new member'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add a new member'));
    await tester.pumpAndSettle();
  }

  testWidgets('sign in opens the dashboard', (tester) async {
    await startApp(tester);
    expect(find.text('Who is working today?'), findsOneWidget);

    await tester.tap(find.text('Pacifique Kami'));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Pacifique'), findsOneWidget);
  });

  testWidgets('empty task form shows error messages', (tester) async {
    await startApp(tester);
    await tester.tap(find.text('Pacifique Kami'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.text('Please choose a team member'), findsOneWidget);
    expect(find.text('Please pick a due date'), findsOneWidget);
  });

  testWidgets('create a task, and it is still there after a restart', (
    tester,
  ) async {
    await startApp(tester);
    await tester.tap(find.text('Pacifique Kami'));
    await tester.pumpAndSettle();

    // Open the Tasks tab and the new task form.
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addTaskButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('titleField')),
      'Record the demo',
    );

    await tester.tap(find.byKey(const Key('assigneeField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abigail Salem Tendo').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dateField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Record the demo'), findsOneWidget);

    // Restart: still signed in, and the task is still saved.
    AppData.tasks = [];
    await startApp(tester);
    expect(find.text('Hello, Pacifique'), findsOneWidget);
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('Record the demo'), findsOneWidget);
  });

  testWidgets('marking an overdue task Done makes it Completed', (
    tester,
  ) async {
    await startApp(tester);
    await tester.tap(find.text('Pacifique Kami'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fix login screen layout'));
    await tester.pumpAndSettle();
    expect(find.text('Overdue'), findsOneWidget);

    await tester.tap(find.byKey(const Key('statusDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Overdue'), findsNothing);
  });

  testWidgets('sign out goes back to the sign in screen', (tester) async {
    await startApp(tester);
    await tester.tap(find.text('Pacifique Kami'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    // The list only builds what is on screen, so scroll down to the button.
    await tester.scrollUntilVisible(find.text('Sign out'), 100);
    // Scroll a bit more so the whole button is above the bottom bar.
    await tester.ensureVisible(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Who is working today?'), findsOneWidget);
  });

  testWidgets('a long member name does not break the screens', (tester) async {
    // A small phone, 320 pixels wide.
    tester.view.physicalSize = const Size(960, 1700);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await AppData.load();
    // The longest name the member form allows is 30 characters.
    AppData.members[1].name = 'Pacifique Kamikazi Uwimana Nta';
    Task task = AppData.tasks[0]; // assigned to that member

    // Task details: the "Assigned to" row.
    await tester.pumpWidget(MaterialApp(home: TaskDetailsScreen(task: task)));
    await tester.pumpAndSettle();
    expect(find.text('Pacifique Kamikazi Uwimana Nta'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Task form: the assignee dropdown.
    await tester.pumpWidget(MaterialApp(home: TaskFormScreen(task: task)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('an error goes away as soon as the field is fixed', (
    tester,
  ) async {
    await startApp(tester);
    await tester.tap(find.text('Pacifique Kami'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a title'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('titleField')), 'ab');
    await tester.pumpAndSettle();
    expect(find.text('Title must be at least 3 characters'), findsOneWidget);
  });

  testWidgets('no errors show before the first press on Save', (tester) async {
    await startApp(tester);
    await tester.tap(find.text('Pacifique Kami'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('titleField')), 'R');
    await tester.pumpAndSettle();

    expect(find.text('Please choose a team member'), findsNothing);
    expect(find.text('Please pick a due date'), findsNothing);
    expect(find.text('Title must be at least 3 characters'), findsNothing);
  });

  testWidgets('a task card with a long name still shows the due date', (
    tester,
  ) async {
    // A small phone, 320 pixels wide.
    tester.view.physicalSize = const Size(960, 1700);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await AppData.load();
    AppData.members[1].name = 'Pacifique Kamikazi Uwimana Nta';
    Task task = AppData.tasks[0]; // assigned to that member

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(task: task, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Due ${formatDate(task.dueDate)}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the member form rejects an email like "@."', (tester) async {
    await startApp(tester);
    await openMemberForm(tester);

    await tester.enterText(find.byKey(const Key('nameField')), 'New Person');
    await tester.enterText(find.byKey(const Key('emailField')), '@.');
    await tester.enterText(find.byKey(const Key('roleField')), 'Tester');
    await tester.ensureVisible(find.byKey(const Key('saveMemberButton')));
    await tester.tap(find.byKey(const Key('saveMemberButton')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email'), findsOneWidget);
    expect(AppData.members.length, 4);
  });

  testWidgets('the dashboard lists the most urgent task first', (tester) async {
    // A tall screen, so every card is built.
    tester.view.physicalSize = const Size(1200, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await startApp(tester);
    await tester.tap(find.text('Pacifique Kami'));
    await tester.pumpAndSettle();

    // "Test the task form" is due in 1 day, "Save tasks on the phone" in 2.
    double dueInOne = tester.getTopLeft(find.text('Test the task form')).dy;
    double dueInTwo = tester
        .getTopLeft(find.text('Save tasks on the phone'))
        .dy;
    expect(dueInOne < dueInTwo, true);
  });

  testWidgets('adding a member shows a message', (tester) async {
    await startApp(tester);
    await openMemberForm(tester);

    await tester.enterText(find.byKey(const Key('nameField')), 'New Person');
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'new.person@alustudent.com',
    );
    await tester.enterText(find.byKey(const Key('roleField')), 'Tester');
    await tester.ensureVisible(find.byKey(const Key('saveMemberButton')));
    await tester.tap(find.byKey(const Key('saveMemberButton')));
    await tester.pumpAndSettle();

    expect(find.text('Member added'), findsOneWidget);
    expect(AppData.members.length, 5);
  });

  testWidgets('removing a member unassigns their tasks', (tester) async {
    await startApp(tester);
    await tester.tap(find.text('Pacifique Kami'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Team'));
    await tester.pumpAndSettle();

    // The fourth member in the list is Nyiramanzi, who has two tasks.
    await tester.tap(find.byTooltip('Remove member').at(3));
    await tester.pumpAndSettle();
    expect(find.text('Remove Nyiramanzi Igihozo?'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('Member removed'), findsOneWidget);
    expect(AppData.members.length, 3);
    for (Task task in AppData.tasks) {
      expect(task.assigneeId == 'm4', false);
    }
  });
}
