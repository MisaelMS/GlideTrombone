import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';
import '../services/score_database_service.dart';
import '../models/score_model.dart';
import './create_score_screen.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({Key? key}) : super(key: key);

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  final DatabaseService _dbService = DatabaseService();
  final ScoreDatabaseService _scoreService = ScoreDatabaseService();

  List<ScoreModel> _scores = [];
  List<ScoreModel> _filteredScores = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _dbService.getCurrentUser();
      if (currentUser == null) {
        Navigator.pop(context, true);
        return;
      }

      final scores = _scoreService.getUserScores(currentUser.id);

      setState(() {
        _scores = scores;
        _filteredScores = scores;
        _isLoading = false;
      });

      print('${scores.length} partituras carregadas');
    } catch (e) {
      print('Erro ao carregar partituras: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterScores() {
    setState(() {
      _filteredScores = _scores.where((score) {
        final matchesSearch = _searchQuery.isEmpty ||
            score.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (score.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        final matchesCategory = _selectedCategory == null ||
            score.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterScores();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterScores();
  }

  List<String> _getCategories() {
    final categories = _scores
        .map((score) => score.category)
        .where((cat) => cat != null)
        .toSet()
        .toList();
    return categories.cast<String>();
  }

  Future<void> _deleteScore(ScoreModel score) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Partitura'),
        content: Text('Tem certeza que deseja excluir "${score.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _scoreService.deleteScore(score.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partitura excluída com sucesso!')),
        );
        _loadScores();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  Future<void> _navigateToCreateOrEdit({ScoreModel? scoreToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateScoreScreen(scoreToEdit: scoreToEdit),
      ),
    );

    if (result == true) {
      setState(() {});
      _loadScores();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _dbService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Partituras'),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScores,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Campo de busca
                  TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Buscar partituras...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),

                  const SizedBox(height: 12),
                  //
                  // if (_getCategories().isNotEmpty)
                  //   SingleChildScrollView(
                  //     scrollDirection: Axis.horizontal,
                  //     child: Row(
                  //       children: [
                  //         FilterChip(
                  //           label: const Text('Todas'),
                  //           selected: _selectedCategory == null,
                  //           onSelected: (selected) {
                  //             _onCategoryChanged(null);
                  //           },
                  //         ),
                  //         const SizedBox(width: 8),
                  //         ..._getCategories().map((category) {
                  //           return Padding(
                  //             padding: const EdgeInsets.only(right: 8),
                  //             child: FilterChip(
                  //               label: Text(category),
                  //               selected: _selectedCategory == category,
                  //               onSelected: (selected) {
                  //                 _onCategoryChanged(selected ? category : null);
                  //               },
                  //             ),
                  //           );
                  //         }).toList(),
                  //       ],
                  //     ),
                  //   ),
                ],
              ),
            ),

            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredScores.length} ${_filteredScores.length == 1 ? 'partitura' : 'partituras'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (currentUser != null)
                      Text(
                        currentUser.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredScores.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredScores.length,
                itemBuilder: (context, index) {
                  final score = _filteredScores[index];
                  return _buildScoreCard(score);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateOrEdit(),
        backgroundColor: Colors.indigo.shade600,
        icon: const Icon(Icons.add),
        label: const Text('Nova Partitura'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.music_note_outlined : Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Nenhuma partitura criada ainda'
                : 'Nenhuma partitura encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Toque no botão + para criar sua primeira partitura'
                : 'Tente buscar com outros termos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(ScoreModel score) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToCreateOrEdit(scoreToEdit: score),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          score.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (score.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            score.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _navigateToCreateOrEdit(scoreToEdit: score);
                      } else if (value == 'delete') {
                        _deleteScore(score);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.music_note,
                    '${score.noteCount} notas',
                    Colors.blue,
                  ),
                  _buildInfoChip(
                    Icons.speed,
                    '${score.bpm} BPM',
                    Colors.orange,
                  ),
                  _buildInfoChip(
                    Icons.straighten,
                    score.timeSignature,
                    Colors.purple,
                  ),
                  _buildInfoChip(
                    Icons.key,
                    score.keySignature,
                    Colors.green,
                  ),
                  // if (score.category != null)
                  //   _buildInfoChip(
                  //     Icons.category,
                  //     score.category!,
                  //     Colors.indigo,
                  //   ),
                  if (score.difficulty != null)
                    _buildInfoChip(
                      Icons.star,
                      'Nível ${score.difficulty}',
                      Colors.amber,
                    ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Criado em ${_formatDate(score.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (score.updatedAt != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.edit, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Editado em ${_formatDate(score.updatedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.darken(0.3),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// Extension para escurecer cores
extension ColorExtension on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
}