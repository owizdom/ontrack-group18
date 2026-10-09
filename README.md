# OnTrack

A Flutter mobile app for a small software team to manage project tasks and see which ones are at risk of missing their deadline.

Each task has an assignee, a priority, a due date and a status. From those, the app shows an SLA status: On Track, At Risk, Overdue or Completed.

## SLA rules

Checked in order, the first match wins:

1. Completed: the status is Done.
2. Overdue: the due date has passed.
3. At Risk: the due date is close. High priority: 3 days or less. Medium: 2 days. Low: 1 day.
4. On Track: everything else.

The code is in `lib/logic/sla.dart`.

## Project structure

```
lib/
  main.dart                    loads saved data, starts the app
  constants.dart               colours, dropdown choices, date format
  models/task.dart             the Task class
  models/member.dart           the Member class
  data/app_data.dart           all data, saved with SharedPreferences
  logic/sla.dart               the SLA rules
  widgets/confirm_dialog.dart  the "are you sure?" dialog
  widgets/sla_badge.dart       coloured SLA label, its colour and icon
  widgets/task_card.dart       one task in a list
  screens/sign_in_screen.dart
  screens/home_screen.dart     bottom navigation bar
  screens/dashboard_screen.dart
  screens/task_list_screen.dart
  screens/task_details_screen.dart
  screens/task_form_screen.dart
  screens/team_screen.dart
  screens/member_form_screen.dart
  screens/profile_screen.dart
test/                          tests for the SLA rules, saving, and the main flows
docs/                          spec and task split
```

## How it works

- State: every screen is a `StatefulWidget` and calls `setState()` when its data changes. After coming back from another screen it calls `setState(() {})` to show the latest data.
- Storage: `AppData` keeps the tasks and members in lists and saves them as JSON text with SharedPreferences after every change.
- Navigation: `Navigator.push` to open a screen, `Navigator.pop` to go back, and a `BottomNavigationBar` for the four main tabs.
- Validation: a `Form` with `TextFormField` validators. Pressing Save with mistakes shows the error under each field.

## Run

```
flutter pub get
flutter run
```

Run it on an emulator or a phone, not in a browser.

## Test

```
flutter analyze
flutter test
```
