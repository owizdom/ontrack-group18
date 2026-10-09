import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/member.dart';
import '../models/task.dart';

// Holds all the data of the app in one place, and saves it on the phone
// with SharedPreferences.
//
// SharedPreferences can only save simple values like text, so each list is
// turned into one JSON text before saving, and back into a list on loading.
class AppData {
  static List<Task> tasks = [];
  static List<Member> members = [];
  static String currentUserId = ''; // '' means nobody is signed in

  // Loads the saved data. Returns false if the saved data was damaged.
  static Future<bool> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // The very first time the app opens, there is nothing saved yet,
    // so we add some sample data.
    if (prefs.getBool('seeded') == null) {
      addSampleData();
      await prefs.setBool('seeded', true);
      await save();
      return true;
    }

    try {
      tasks = [];
      List<dynamic> savedTasks = jsonDecode(prefs.getString('tasks') ?? '[]');
      for (var item in savedTasks) {
        tasks.add(Task.fromMap(item));
      }

      members = [];
      List<dynamic> savedMembers = jsonDecode(
        prefs.getString('members') ?? '[]',
      );
      for (var item in savedMembers) {
        members.add(Member.fromMap(item));
      }

      currentUserId = prefs.getString('currentUserId') ?? '';
      return true;
    } catch (error) {
      // The saved text could not be read. Start empty instead of crashing.
      tasks = [];
      members = [];
      currentUserId = '';
      return false;
    }
  }

  // Saves everything. Called after every change.
  static Future<void> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> taskMaps = [];
    for (Task task in tasks) {
      taskMaps.add(task.toMap());
    }

    List<Map<String, dynamic>> memberMaps = [];
    for (Member member in members) {
      memberMaps.add(member.toMap());
    }

    await prefs.setString('tasks', jsonEncode(taskMaps));
    await prefs.setString('members', jsonEncode(memberMaps));
    await prefs.setString('currentUserId', currentUserId);
  }

  // Finds a member by id. Returns null if there is no such member.
  static Member? findMember(String id) {
    for (Member member in members) {
      if (member.id == id) {
        return member;
      }
    }
    return null;
  }

  static Member? currentUser() {
    return findMember(currentUserId);
  }

  // A new id that no other task or member has: the current time.
  static String newId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static void addSampleData() {
    members = [
      Member(
        id: 'm1',
        name: 'Wisdom Okechukwu',
        email: 'w.okechukwu@alustudent.com',
        role: 'Project Lead',
      ),
      Member(
        id: 'm2',
        name: 'Pacifique Kami',
        email: 'p.kami@alustudent.com',
        role: 'Flutter Developer',
      ),
      Member(
        id: 'm3',
        name: 'Abigail Salem Tendo',
        email: 'a.tendo@alustudent.com',
        role: 'UI Designer',
      ),
      Member(
        id: 'm4',
        name: 'Nyiramanzi Igihozo',
        email: 'n.igihozo@alustudent.com',
        role: 'QA Tester',
      ),
    ];

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    tasks = [
      Task(
        id: 't1',
        title: 'Fix login screen layout',
        description: 'The sign in screen overflows on small phones.',
        assigneeId: 'm2',
        priority: priorityHigh,
        status: statusInProgress,
        dueDate: today.subtract(const Duration(days: 2)),
      ),
      Task(
        id: 't2',
        title: 'Save tasks on the phone',
        description:
            'Use SharedPreferences so tasks stay after closing the app.',
        assigneeId: 'm4',
        priority: priorityHigh,
        status: statusInProgress,
        dueDate: today.add(const Duration(days: 2)),
      ),
      Task(
        id: 't3',
        title: 'Test the task form',
        description: 'Try empty fields and very short titles.',
        assigneeId: 'm4',
        priority: priorityMedium,
        status: statusToDo,
        dueDate: today.add(const Duration(days: 1)),
      ),
      Task(
        id: 't4',
        title: 'Design the dashboard',
        description: 'Cards for each SLA status.',
        assigneeId: 'm3',
        priority: priorityMedium,
        status: statusInProgress,
        dueDate: today.add(const Duration(days: 7)),
      ),
      Task(
        id: 't5',
        title: 'Plan the demo video',
        description: 'Decide who explains which part.',
        assigneeId: 'm1',
        priority: priorityLow,
        status: statusToDo,
        dueDate: today.add(const Duration(days: 10)),
      ),
      Task(
        id: 't6',
        title: 'Set up the GitHub repo',
        description: 'Create the repo and one branch per member.',
        assigneeId: 'm1',
        priority: priorityHigh,
        status: statusDone,
        dueDate: today.subtract(const Duration(days: 5)),
      ),
    ];

    currentUserId = '';
  }
}
