import 'package:flutter/material.dart';

class PracticeControlsWidget extends StatelessWidget {
  final bool isListening;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggleListening;
  final VoidCallback onNext;

  const PracticeControlsWidget({
    Key? key,
    required this.isListening,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onToggleListening,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: canGoPrevious ? onPrevious : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(Icons.skip_previous),
          ),

          ElevatedButton(
            onPressed: onToggleListening,
            style: ElevatedButton.styleFrom(
              backgroundColor: isListening ? Colors.red.shade400 : Colors.green.shade400,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(24),
              elevation: 8,
            ),
            child: Icon(
              isListening ? Icons.stop : Icons.mic,
              size: 32,
            ),
          ),

          ElevatedButton(
            onPressed: canGoNext ? onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(Icons.skip_next),
          ),
        ],
      ),
    );
  }
}