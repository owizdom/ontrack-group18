# Tasks: Group 18

Each member owns a set of files and works on a branch with their name. No file has two owners. Every branch goes into `main` through a pull request.

| Member | Branch | Files |
|--------|--------|-------|
| Wisdom Ikechukwu Okechukwu | `wisdom` | `lib/main.dart`, `lib/logic/sla.dart`, `lib/screens/home_screen.dart`, `lib/screens/dashboard_screen.dart`, `test/sla_test.dart`, `test/app_test.dart` |
| Pacifique Kami | `pacifique` | `lib/screens/task_list_screen.dart`, `lib/screens/task_details_screen.dart`, `lib/screens/task_form_screen.dart`, `lib/widgets/task_card.dart` |
| Nyiramanzi Igihozo | `nyiramanzi` | `lib/models/task.dart`, `lib/models/member.dart`, `lib/data/app_data.dart`, `test/app_data_test.dart` |
| Abigail Salem Tendo | `abigail` | `lib/constants.dart`, `lib/widgets/sla_badge.dart`, `lib/screens/sign_in_screen.dart`, `lib/screens/member_form_screen.dart`, `lib/screens/team_screen.dart`, `lib/screens/profile_screen.dart` |

What each person explains in the demo:

- Wisdom: the SLA rules, `main()` loading data, the bottom navigation bar, the dashboard counts and progress bar.
- Pacifique: the task form and its validation, `Navigator.push` and `Navigator.pop`, changing status, deleting with a dialog, search and filter.
- Nyiramanzi: the `Task` and `Member` classes, `toMap` and `fromMap`, saving and loading with SharedPreferences, why not SQLite, the damaged data case.
- Abigail: colours and design choices, the sign in flow, the member form and its validation, the team list, the profile screen and sign out.

Merge order: nyiramanzi, abigail, pacifique, wisdom.
