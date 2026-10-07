import 'package:flutter/material.dart';

import '../constants.dart';
import '../data/app_data.dart';
import '../logic/sla.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../widgets/sla_badge.dart';
import 'member_form_screen.dart';
import 'sign_in_screen.dart';

// The signed-in member: their details, their tasks, the SLA rules,
// and the sign out button.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void editProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberFormScreen(member: AppData.currentUser()),
      ),
    );
    setState(() {});
  }

  void signOut() async {
    AppData.currentUserId = '';
    await AppData.save();
    if (!mounted) return;
    // Go back to the sign in screen and remove every screen behind it.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Member me = AppData.currentUser()!;

    // Count my tasks by SLA status.
    int myTotal = 0;
    int myAtRisk = 0;
    int myOverdue = 0;
    int myDone = 0;
    for (Task task in AppData.tasks) {
      if (task.assigneeId == me.id) {
        myTotal++;
        String sla = getSlaStatus(task, DateTime.now());
        if (sla == 'At Risk') myAtRisk++;
        if (sla == 'Overdue') myOverdue++;
        if (sla == 'Completed') myDone++;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              child: Text(me.initials(), style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            me.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(me.role, textAlign: TextAlign.center),
          Text(
            me.email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // My tasks: four numbers side by side.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  numberColumn('My tasks', myTotal, mainColor),
                  numberColumn('At Risk', myAtRisk, atRiskColor),
                  numberColumn('Overdue', myOverdue, overdueColor),
                  numberColumn('Done', myDone, completedColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How SLA status works',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ruleRow('Completed', 'The task status is Done.'),
                  ruleRow('Overdue', 'The due date has passed.'),
                  ruleRow(
                    'At Risk',
                    'The due date is close. High priority = 3 days, '
                        'Medium = 2 days, Low = 1 day.',
                  ),
                  ruleRow('On Track', 'Everything else.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: editProfile,
            icon: const Icon(Icons.edit),
            label: const Text('Edit profile'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Widget numberColumn(String label, int number, Color color) {
    return Column(
      children: [
        Text(
          '$number',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // One SLA rule with the same icon and colour as the badge.
  Widget ruleRow(String slaStatus, String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(getSlaIcon(slaStatus), size: 18, color: getSlaColor(slaStatus)),
          const SizedBox(width: 8),
          // Expanded lets long rule text wrap instead of overflowing.
          Expanded(child: Text('$slaStatus: $rule')),
        ],
      ),
    );
  }
}
