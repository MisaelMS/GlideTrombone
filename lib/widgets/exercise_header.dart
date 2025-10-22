import 'package:flutter/material.dart';
import '../../models/exercise.dart';

class ExerciseHeaderWidget extends StatelessWidget {
  final Exercise exercise;
  final int currentNoteIndex;
  final int? bestScore;
  final VoidCallback onPlayReference;

  const ExerciseHeaderWidget({
    Key? key,
    required this.exercise,
    required this.currentNoteIndex,
    this.bestScore,
    required this.onPlayReference,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.keySignature} • ${exercise.tempo} BPM',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              if (bestScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber[400]!, Colors.amber[600]!],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$bestScore',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_border,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sem recorde',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (currentNoteIndex + 1) / exercise.notes.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${currentNoteIndex + 1}/${exercise.notes.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.play_circle_outline),
                color: Colors.indigo,
                onPressed: onPlayReference,
                tooltip: 'Ouvir nota de referência',
              ),
            ],
          ),
        ],
      ),
    );
  }
}