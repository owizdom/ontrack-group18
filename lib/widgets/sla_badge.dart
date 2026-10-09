import 'package:flutter/material.dart';

import '../constants.dart';

// The colour for each SLA status.
Color getSlaColor(String slaStatus) {
  if (slaStatus == slaCompleted) {
    return completedColor;
  } else if (slaStatus == slaOverdue) {
    return overdueColor;
  } else if (slaStatus == slaAtRisk) {
    return atRiskColor;
  } else {
    return onTrackColor;
  }
}

// The icon for each SLA status. With an icon, the badge is still clear for
// someone who cannot tell the colours apart.
IconData getSlaIcon(String slaStatus) {
  if (slaStatus == slaCompleted) {
    return Icons.check_circle;
  } else if (slaStatus == slaOverdue) {
    return Icons.error;
  } else if (slaStatus == slaAtRisk) {
    return Icons.warning;
  } else {
    return Icons.trending_up;
  }
}

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
      child: Row(
        // min: the badge is only as wide as its icon and text.
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getSlaIcon(slaStatus), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            slaStatus,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
