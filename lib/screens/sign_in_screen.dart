import 'package:flutter/material.dart';

import '../constants.dart';
import '../data/app_data.dart';
import '../models/member.dart';
import 'home_screen.dart';
import 'member_form_screen.dart';

// First screen. There is no real login: you choose which team member you are.
class SignInScreen extends StatefulWidget {
  final bool showDataError;

  const SignInScreen({super.key, this.showDataError = false});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  void initState() {
    super.initState();
    // If the saved data was damaged, tell the user once the screen is shown.
    if (widget.showDataError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Saved data could not be read, so the app started empty.',
            ),
          ),
        );
      });
    }
  }

  void signIn(Member member) async {
    AppData.currentUserId = member.id;
    await AppData.save();
    if (!mounted) return;
    // pushReplacement: the sign in screen is removed, so the back button
    // does not come back here. You leave by signing out.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void addMember() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MemberFormScreen()),
    );
    // Rebuild so the new member shows in the list.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.task_alt, size: 64, color: mainColor),
            const SizedBox(height: 12),
            const Text(
              'OnTrack',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Project and SLA task tracker',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text(
              'Who is working today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (Member member in AppData.members)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(member.initials())),
                  title: Text(member.name),
                  subtitle: Text(member.role),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => signIn(member),
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: addMember,
              icon: const Icon(Icons.person_add),
              label: const Text('Add a new member'),
            ),
          ],
        ),
      ),
    );
  }
}
