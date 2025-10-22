import 'package:flutter/material.dart';

class PracticeTimerWidget extends StatelessWidget {
  final String formattedTime;
  final bool isListening;

  const PracticeTimerWidget({
    Key? key,
    required this.formattedTime,
    required this.isListening,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: isListening ? Colors.red : Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isListening ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}