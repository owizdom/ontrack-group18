import 'package:flutter/material.dart';

import '../logic/sla.dart';

// The small coloured label that shows a task's SLA status.
class SlaBadge extends StatelessWidget {
  final String slaStatus;

  const SlaBadge({super.key, required this.slaStatus});

  @override
  Widget build(BuildContext context) {
    Color color = getSlaColor(slaStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        slaStatus,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
