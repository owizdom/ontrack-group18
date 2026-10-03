# Spec: Project & SLA Task Tracker

Status: written by the team before any code.

## Objective

A Flutter mobile app that lets a small software team manage project tasks: create and edit them, assign them, set a priority and a deadline, change their status, and see which ones need attention. Every task shows an SLA status calculated from its deadline and status.

## Non-goals

- No backend and no real login.
- No state management package. State is `setState()` only.
- The only extra package is `shared_preferences`.
- Phone only, portrait only.

## Screens

| Screen | Purpose |
|--------|---------|
| Sign in | Choose which team member you are, or add a new member |
| Dashboard | Progress bar, a count for each SLA status, tasks that need attention |
| Task list | All tasks, search by title, filter by SLA status |
| Task details | One task, change its status, see why it has its SLA status, edit, delete |
| Create / edit task | One form used for both |
| Team | Members and their open tasks, add, edit, remove |
| Member form | Add or edit a member |
| Profile | Your details, your task counts, the SLA rules, sign out |

## SLA rules

Checked in this order. The first rule that matches wins.

1. Completed: the status is Done.
2. Overdue: the due date has passed.
3. At Risk: the due date is close. High priority: 3 days or less. Medium: 2 days or less. Low: 1 day or less.
4. On Track: everything else.

A task is due by the end of its due date, so a task due today is At Risk, not Overdue. The SLA status is never saved. It is calculated every time a screen is built, so it is always up to date.

## Data

- All data lives in one class, `AppData`, as three static fields: `tasks`, `members`, `currentUserId`.
- `AppData.save()` turns the lists into JSON text and saves them with SharedPreferences. It is called after every change.
- `AppData.load()` runs once in `main()` before the first screen.
- First launch adds sample data once. A `seeded` flag stops it coming back.
- If the saved text is damaged, the app starts empty and shows a message. It does not crash.
- Why SharedPreferences and not SQLite: we have two small lists that we always load completely. We never search the saved data, so we do not need tables or queries.

## State and navigation

- Each screen is a `StatefulWidget`. When something on a screen changes, the screen calls `setState()`.
- After opening another screen with `await Navigator.push(...)`, the screen calls `setState(() {})` so it shows the latest data when the user comes back.
- Sign in uses `Navigator.pushReplacement`, so the back button does not return to sign in. Sign out uses `Navigator.pushAndRemoveUntil`.
- The home screen has a `BottomNavigationBar` with four tabs: Dashboard, Tasks, Team, Profile.

## Validation

Task form:
- Title: required, at least 3 characters, at most 50.
- Description: optional, at most 200 characters.
- Assign to: required.
- Due date: required. The date picker does not allow past dates for a new task.

Member form:
- Name: 2 to 30 characters.
- Email: required, must contain "@" and ".", must not belong to another member.
- Role: required.

Errors show after the first press on Save, then update as the user types.

Other:
- Deleting a task or a member asks for confirmation first.
- Removing a member makes their tasks unassigned.
- You cannot remove yourself.

## Acceptance tests

| Test | File |
|------|------|
| Done task is Completed even after its due date | `test/sla_test.dart` |
| Open task after its due date is Overdue; due today is At Risk | `test/sla_test.dart` |
| At Risk window is 3, 2 and 1 days for High, Medium and Low | `test/sla_test.dart` |
| First launch adds sample data, and only once | `test/app_data_test.dart` |
| Saved data comes back after a restart | `test/app_data_test.dart` |
| Damaged saved data does not crash the app | `test/app_data_test.dart` |
| Empty task form shows the error messages | `test/app_test.dart` |
| Create a task, restart, the task is still there | `test/app_test.dart` |
| Changing an overdue task to Done shows Completed | `test/app_test.dart` |
| A fixed field loses its error while typing | `test/app_test.dart` |
| A 30-character name does not overflow on a 320 px screen | `test/app_test.dart` |
| No error shows before the first press on Save | `test/app_test.dart` |

## Pre-mortem

It is demo day and we lost marks. Most likely reasons:

1. Someone cannot explain their code. So: small files, plain `if` statements, comments on every important part.
2. Data is lost after closing the app during the demo. So: the restart test.
3. Nobody can explain an SLA status. So: the details screen prints the reason in words.
4. A screen overflows. So: every screen scrolls and long text is cut with "...".
