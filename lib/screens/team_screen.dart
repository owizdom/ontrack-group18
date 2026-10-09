import 'package:flutter/material.dart';

import '../constants.dart';
import '../data/app_data.dart';
import '../models/member.dart';
import '../models/task.dart';
import 'member_form_screen.dart';

// The list of team members, with how many open tasks each one has.
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  void openForm(Member? member) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MemberFormScreen(member: member)),
    );
    setState(() {});
  }

  void deleteMember(Member member) async {
    // You cannot remove yourself while you are signed in.
    if (member.id == AppData.currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot remove yourself')),
      );
      return;
    }

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${member.name}?'),
        content: const Text('Their tasks will become unassigned.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: overdueColor)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Unassign their tasks, then remove the member.
    for (Task task in AppData.tasks) {
      if (task.assigneeId == member.id) {
        task.assigneeId = '';
      }
    }
    AppData.members.remove(member);
    await AppData.save();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Member removed')));
  }

  // How many tasks of this member are not done yet.
  int openTasks(Member member) {
    int count = 0;
    for (Task task in AppData.tasks) {
      if (task.assigneeId == member.id && task.status != statusDone) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(null),
        child: const Icon(Icons.person_add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppData.members.length,
        itemBuilder: (context, index) {
          Member member = AppData.members[index];
          String role = member.role;
          if (member.id == AppData.currentUserId) {
            role = '$role (you)';
          }

          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(member.initials())),
              title: Text(member.name),
              subtitle: Text('$role\nOpen tasks: ${openTasks(member)}'),
              isThreeLine: true,
              onTap: () => openForm(member),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove member',
                onPressed: () => deleteMember(member),
              ),
            ),
          );
        },
      ),
    );
  }
}
