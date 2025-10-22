import 'package:flutter/material.dart';

class FeedbackDisplay extends StatelessWidget {
  final String feedback;
  final Color feedbackColor;
  final String? detectedPitch;
  final bool isPlaying;

  const FeedbackDisplay({
    Key? key,
    required this.feedback,
    required this.feedbackColor,
    this.detectedPitch,
    required this.isPlaying,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.mic,
                    color: isPlaying ? Colors.red : Colors.grey,
                    size: 24,
                  ),
                  Text(
                    isPlaying ? 'Gravando' : 'Parado',
                    style: TextStyle(
                      color: isPlaying ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.music_note, color: Colors.blue, size: 24),
                  Text(
                    detectedPitch ?? '--',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.feedback, color: feedbackColor, size: 24),
                  Text(
                    'Feedback',
                    style: TextStyle(color: feedbackColor),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            feedback.isEmpty ? 'Toque as notas conforme indicado' : feedback,
            style: TextStyle(
              fontSize: 16,
              color: feedbackColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}