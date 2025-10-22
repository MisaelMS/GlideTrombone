import 'package:flutter/material.dart';
import '../../models/exercise.dart';

class CompletionDialog {
  static void show({
    required BuildContext context,
    required Exercise exercise,
    required String formattedTime,
    required int totalScore,
    int? bestScore,
    required String scoreMessage,
    required bool isNewRecord,
    required VoidCallback onRepeat,
    required VoidCallback onNext,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone de sucesso
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isNewRecord ? Colors.amber : Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNewRecord ? Icons.emoji_events : Icons.check,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                isNewRecord ? ' Novo Recorde!' : ' Exercício Concluído!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                exercise.name,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pontuação:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$totalScore',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isNewRecord ? Colors.amber[700] : Colors.green[700],
                          ),
                        ),
                      ],
                    ),

                    if (bestScore != null && !isNewRecord) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Melhor:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '$bestScore',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Divider(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tempo:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isNewRecord ? Colors.amber[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isNewRecord ? Colors.amber[200]! : Colors.blue[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isNewRecord ? Icons.celebration : Icons.info_outline,
                      color: isNewRecord ? Colors.amber[700] : Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        scoreMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: isNewRecord ? Colors.amber[900] : Colors.blue[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRepeat,
                      icon: const Icon(Icons.replay),
                      label: const Text('Repetir'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onNext,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Próximo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}