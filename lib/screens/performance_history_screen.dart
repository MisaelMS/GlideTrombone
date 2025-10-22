import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/performance_model.dart';
import '../models/score_model.dart';

class PerformanceHistoryScreen extends StatefulWidget {
  @override
  _PerformanceHistoryScreenState createState() => _PerformanceHistoryScreenState();
}

class _PerformanceHistoryScreenState extends State<PerformanceHistoryScreen> {
  late Box<PerformanceModel> _performancesBox;
  late Box<ScoreModel> _scoresBox;

  @override
  void initState() {
    super.initState();
    _performancesBox = Hive.box<PerformanceModel>('performances');
    _scoresBox = Hive.box<ScoreModel>('scores');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Performances'),
        backgroundColor: Colors.green[600],
      ),
      body: ValueListenableBuilder(
        valueListenable: _performancesBox.listenable(),
        builder: (context, Box<PerformanceModel> box, _) {
          final performances = box.values.toList()
            ..sort((a, b) => b.playedAt.compareTo(a.playedAt));

          if (performances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma performance registrada',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toque algumas partituras para ver seu histórico aqui',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: performances.length,
            itemBuilder: (context, index) {
              final performance = performances[index];
              final score = _scoresBox.get(performance.scoreId);

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getScoreColor(performance.totalScore),
                    child: Text(
                      performance.totalScore.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(score?.title ?? 'Partitura removida'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precisão: ${(performance.accuracy * 100).toStringAsFixed(1)}% | '
                            'Tempo: ${(performance.timing * 100).toStringAsFixed(1)}%',
                      ),
                      Text(
                        '${_formatDate(performance.playedAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    _showPerformanceDetails(performance, score);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showPerformanceDetails(PerformanceModel performance, ScoreModel? score) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalhes da Performance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Partitura: ${score?.title ?? 'Removida'}'),
            Text('Pontuação: ${performance.totalScore}'),
            Text('Precisão: ${(performance.accuracy * 100).toStringAsFixed(1)}%'),
            Text('Tempo: ${(performance.timing * 100).toStringAsFixed(1)}%'),
            Text('Data: ${_formatDate(performance.playedAt)}'),
            Text('Notas tocadas: ${performance.playedNotes.length}'),
            Text('Notas corretas: ${performance.playedNotes.where((n) => n.isCorrect).length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
}