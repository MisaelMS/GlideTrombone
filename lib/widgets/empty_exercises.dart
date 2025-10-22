import 'package:flutter/material.dart';

class EmptyExercisesWidget extends StatelessWidget {
  final VoidCallback onReload;

  const EmptyExercisesWidget({
    Key? key,
    required this.onReload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prática de Trombone'),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Nenhum exercício disponível'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onReload,
              icon: const Icon(Icons.refresh),
              label: const Text('Recarregar'),
            ),
          ],
        ),
      ),
    );
  }
}