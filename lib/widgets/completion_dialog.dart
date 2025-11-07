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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 600;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone de sucesso
                    Container(
                      width: isSmallScreen ? 60 : 80,
                      height: isSmallScreen ? 60 : 80,
                      decoration: BoxDecoration(
                        color: isNewRecord ? Colors.amber : Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isNewRecord ? Icons.emoji_events : Icons.check,
                        color: Colors.white,
                        size: isSmallScreen ? 36 : 48,
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 12 : 16),

                    Text(
                      isNewRecord ? ' Novo Recorde!' : ' Exercício Concluído!',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isSmallScreen ? 6 : 8),

                    Text(
                      exercise.name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isSmallScreen ? 16 : 24),

                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pontuação:',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$totalScore',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: isNewRecord ? Colors.amber[700] : Colors.green[700],
                                ),
                              ),
                            ],
                          ),

                          if (bestScore != null && !isNewRecord) ...[
                            SizedBox(height: isSmallScreen ? 6 : 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Melhor:',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '$bestScore',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          Divider(height: isSmallScreen ? 20 : 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tempo:',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.timer, size: isSmallScreen ? 16 : 18),
                                  SizedBox(width: isSmallScreen ? 3 : 4),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18,
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

                    SizedBox(height: isSmallScreen ? 12 : 16),

                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
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
                            size: isSmallScreen ? 18 : 20,
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Expanded(
                            child: Text(
                              scoreMessage,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: isNewRecord ? Colors.amber[900] : Colors.blue[900],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 16 : 24),

                    if (isSmallScreen)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
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
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: onRepeat,
                              icon: const Icon(Icons.replay),
                              label: const Text('Repetir'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
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
            );
          },
        ),
      ),
    );
  }
}