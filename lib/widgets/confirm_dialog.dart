import 'package:flutter/material.dart';

import '../constants.dart';

// Asks the user to confirm before something is deleted. Used for deleting
// a task and for removing a member, so both dialogs look the same.
// Returns true only if the red button was pressed.
Future<bool> askToConfirm(
  BuildContext context,
  String title,
  String message,
  String confirmLabel,
) async {
  bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
            style: const TextStyle(color: overdueColor),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}
