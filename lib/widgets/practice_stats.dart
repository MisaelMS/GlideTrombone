import 'package:flutter/material.dart';
import '../models/exercise.dart';

class PracticeStatsWidget extends StatelessWidget {
  final Exercise exercise;
  final int currentNoteIndex;
  final String currentNote;
  final double pitchAccuracy;
  final Animation<Color?> accuracyColorAnimation;

  const PracticeStatsWidget({
    Key? key,
    required this.exercise,
    required this.currentNoteIndex,
    required this.currentNote,
    required this.pitchAccuracy,
    required this.accuracyColorAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentTargetNote = exercise.notes[currentNoteIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(
            'Alvo',
            currentTargetNote.displayName ?? currentTargetNote.note,
            Colors.indigo,
          ),
          _buildStatColumn(
            'Posição',
            currentTargetNote.position ?? '---',
            Colors.indigo,
          ),
          _buildDetectedColumn(),
          _buildStatColumn(
            'Precisão',
            '${(pitchAccuracy * 100).toStringAsFixed(0)}%',
            pitchAccuracy > 0.7 ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetectedColumn() {
    return Column(
      children: [
        Text(
          'Detectado',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        AnimatedBuilder(
          animation: accuracyColorAnimation,
          builder: (context, child) {
            return Text(
              currentNote.isNotEmpty ? currentNote : '---',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accuracyColorAnimation.value ?? Colors.grey,
              ),
            );
          },
        ),
      ],
    );
  }
}