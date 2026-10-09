import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/member.dart';

// Adds a new team member, or edits one if `member` is given.
class MemberFormScreen extends StatefulWidget {
  final Member? member;

  const MemberFormScreen({super.key, this.member});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final roleController = TextEditingController();
  bool triedToSave = false; // becomes true after the first press on Save

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      nameController.text = widget.member!.name;
      emailController.text = widget.member!.email;
      roleController.text = widget.member!.role;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    roleController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Please enter a name (at least 2 characters)';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email';
    }
    String email = value.trim().toLowerCase();
    // A valid email has text, one @, text, a dot, then text: name@site.com
    int at = email.indexOf('@');
    int lastDot = email.lastIndexOf('.');
    bool oneAt = at > 0 && at == email.lastIndexOf('@');
    bool dotAfterAt = lastDot > at + 1 && lastDot < email.length - 1;
    if (!oneAt || !dotAfterAt || email.contains(' ')) {
      return 'Please enter a valid email';
    }
    // No two members can have the same email.
    for (Member other in AppData.members) {
      bool isSamePerson =
          widget.member != null && other.id == widget.member!.id;
      if (!isSamePerson && other.email.toLowerCase() == email) {
        return 'This email is already used';
      }
    }
    return null;
  }

  String? validateRole(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a role';
    }
    return null;
  }

  void saveMember() async {
    if (!formKey.currentState!.validate()) {
      setState(() {
        triedToSave = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }

    if (widget.member == null) {
      AppData.members.add(
        Member(
          id: AppData.newId(),
          name: nameController.text.trim(),
          email: emailController.text.trim().toLowerCase(),
          role: roleController.text.trim(),
        ),
      );
    } else {
      widget.member!.name = nameController.text.trim();
      widget.member!.email = emailController.text.trim().toLowerCase();
      widget.member!.role = roleController.text.trim();
    }

    await AppData.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.member == null ? 'Member added' : 'Member updated',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool editing = widget.member != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit member' : 'New member')),
      body: Form(
        key: formKey,
        // Errors only show after the first press on Save. From then on
        // the form checks the fields again every time something changes.
        autovalidateMode: triedToSave
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('nameField'),
                controller: nameController,
                maxLength: 30,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('emailField'),
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('roleField'),
                controller: roleController,
                maxLength: 30,
                decoration: const InputDecoration(labelText: 'Role'),
                validator: validateRole,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('saveMemberButton'),
                onPressed: saveMember,
                child: Text(editing ? 'Save changes' : 'Add member'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
