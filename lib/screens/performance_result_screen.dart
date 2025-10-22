import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/performance_model.dart';

class PerformanceResultScreen extends StatefulWidget {
  final PerformanceModel performance;

  PerformanceResultScreen({required this.performance});

  @override
  _PerformanceResultScreenState createState() => _PerformanceResultScreenState();
}

class _PerformanceResultScreenState extends State<PerformanceResultScreen> {
  late Box<PerformanceModel> _performancesBox;

  @override
  void initState() {
    super.initState();
    _performancesBox = Hive.box<PerformanceModel>('performances');
    _savePerformance();
  }

  void _savePerformance() {
    _performancesBox.put(widget.performance.id, widget.performance);
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return 'Excelente!';
    if (score >= 70) return 'Bom trabalho!';
    if (score >= 50) return 'Continue praticando!';
    return 'Precisa melhorar';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultado da Performance'),
        backgroundColor: Colors.blue[600],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _getScoreColor(widget.performance.totalScore).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    widget.performance.totalScore.toString(),
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(widget.performance.totalScore),
                    ),
                  ),
                  Text(
                    _getScoreMessage(widget.performance.totalScore),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: _getScoreColor(widget.performance.totalScore),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Precisão',
                    '${(widget.performance.accuracy * 100).toStringAsFixed(1)}%',
                    Icons.center_focus_strong,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Tempo',
                    '${(widget.performance.timing * 100).toStringAsFixed(1)}%',
                    Icons.timer,
                    Colors.green,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Análise Detalhada',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.performance.playedNotes.length,
                          itemBuilder: (context, index) {
                            final note = widget.performance.playedNotes[index];
                            return ListTile(
                              leading: Icon(
                                note.isCorrect ? Icons.check_circle : Icons.error,
                                color: note.isCorrect ? Colors.green : Colors.red,
                              ),
                              title: Text('Nota ${index + 1}'),
                              subtitle: Text(
                                'Esperado: ${note.expectedPitch} | '
                                    'Tocado: ${note.playedPitch}',
                              ),
                              trailing: Text(
                                '${((note.playedTime - note.expectedTime).abs() * 1000).toStringAsFixed(0)}ms',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.replay),
                    label: Text('Tocar Novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: Icon(Icons.home),
                    label: Text('Início'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}