import 'package:hive_flutter/hive_flutter.dart';
import '../models/score_model.dart';
import '../models/note_model.dart';
import '../models/performance_model.dart';
import '../widgets/score_display.dart';
import '../../models/exercise.dart';

class ScoreDatabaseService {
  static const String _scoreBoxName = 'scores';
  static const String _performanceBoxName = 'performances';

  static Box<ScoreModel>? _scoreBox;
  static Box<PerformanceModel>? _performanceBox;

  static final ScoreDatabaseService _instance = ScoreDatabaseService._internal();
  factory ScoreDatabaseService() => _instance;
  ScoreDatabaseService._internal();

  static Future<void> initialize() async {
    try {
      print('Inicializando ScoreDatabaseService...');

      _scoreBox = await Hive.openBox<ScoreModel>(_scoreBoxName);
      _performanceBox = await Hive.openBox<PerformanceModel>(_performanceBoxName);

      print('ScoreBox inicializado com ${_scoreBox!.length} partituras');
      print('PerformanceBox inicializado com ${_performanceBox!.length} performances');

    } catch (e) {
      print('Erro ao inicializar ScoreDatabaseService: $e');
      rethrow;
    }
  }

  Box<ScoreModel> get scoreBox {
    if (_scoreBox == null || !_scoreBox!.isOpen) {
      throw Exception('ScoreBox não inicializado! Chame ScoreDatabaseService.initialize() primeiro.');
    }
    return _scoreBox!;
  }

  Box<PerformanceModel> get performanceBox {
    if (_performanceBox == null || !_performanceBox!.isOpen) {
      throw Exception('PerformanceBox não inicializado! Chame ScoreDatabaseService.initialize() primeiro.');
    }
    return _performanceBox!;
  }

  // ========== CONVERSÃO DE EXERCISE PARA SCOREMODEL ==========

  /// Converte Exercise (das escalas) para ScoreModel
  // ScoreModel exerciseToScoreModel(Exercise exercise, String userId) {
  //   List<NoteModel> noteModels = [];
  //   double currentTime = 0.0;
  //
  //   for (var musicalNote in exercise.notes) {
  //     String fullNote = musicalNote.note;
  //     String pitch;
  //     int octave;
  //
  //     if (fullNote.length == 2) {
  //       // Exemplo: C4
  //       pitch = fullNote[0];
  //       octave = int.parse(fullNote[1]);
  //     } else if (fullNote.length == 3) {
  //       // Exemplo: C#4, Bb4
  //       pitch = fullNote.substring(0, 2);
  //       octave = int.parse(fullNote[2]);
  //     } else {
  //       throw ArgumentError('Formato de nota inválido: $fullNote');
  //     }
  //
  //     noteModels.add(NoteModel(
  //       pitch: pitch,
  //       octave: octave,
  //       duration: 1.0,
  //       startTime: currentTime,
  //       displayName: musicalNote.displayName,
  //       position: musicalNote.position,
  //       isRest: false,
  //     ));
  //
  //     currentTime += 1.0;
  //   }
  //
  //   return ScoreModel.create(
  //     id: exercise.id!.isNotEmpty ? exercise.id : null,
  //     title: exercise.name,
  //     bpm: exercise.tempo,
  //     timeSignature: exercise.timeSignature.isNotEmpty ? exercise.timeSignature :'4/4',
  //     keySignature: exercise.keySignature,
  //     notes: noteModels,
  //     userId: userId,
  //     category: 'Escalas',
  //     difficulty: _inferDifficulty(exercise.notes.length),
  //   );
  // }

  ScoreModel exerciseToScoreModel(Exercise exercise, String userId) {
    print('\n🔄 === CONVERTENDO EXERCISE PARA SCOREMODEL ===');
    print('   Exercise ID: ${exercise.id ?? "NULL"}');
    print('   Exercise Name: ${exercise.name}');
    print('   User ID: $userId');

    List<NoteModel> noteModels = [];
    double currentTime = 0.0;

    for (var musicalNote in exercise.notes) {
      String fullNote = musicalNote.note;
      String pitch;
      int octave;

      if (fullNote.length == 2) {
        // Exemplo: C4
        pitch = fullNote[0];
        octave = int.parse(fullNote[1]);
      } else if (fullNote.length == 3) {
        // Exemplo: C#4, Bb4
        pitch = fullNote.substring(0, 2);
        octave = int.parse(fullNote[2]);
      } else {
        throw ArgumentError('Formato de nota inválido: $fullNote');
      }

      noteModels.add(NoteModel(
        pitch: pitch,
        octave: octave,
        duration: 1.0,
        startTime: currentTime,
        displayName: musicalNote.displayName,
        position: musicalNote.position,
        isRest: false,
      ));

      currentTime += 1.0;
    }

    // 🔥 USA O ID DO EXERCISE OU GERA UM NOVO SE FOR NULL/VAZIO
    final scoreId = (exercise.id != null && exercise.id!.isNotEmpty)
        ? exercise.id!
        : DateTime.now().millisecondsSinceEpoch.toString();

    print('   Score ID será: $scoreId');
    print('   ID veio do Exercise: ${exercise.id != null && exercise.id!.isNotEmpty}');

    // 🔥 USA O CONSTRUTOR DIRETO (como no seu exemplo)
    final score = ScoreModel(
      id: scoreId,
      title: exercise.name,
      bpm: exercise.tempo,
      timeSignature: '4/4',
      keySignature: exercise.keySignature,
      notes: noteModels,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: null,
      description: (exercise.id != null && exercise.id!.isNotEmpty)
          ? 'Exercício pré-definido: ${exercise.name}'
          : null,
      category: 'Escalas',
      difficulty: _inferDifficulty(exercise.notes.length),
    );

    print('   ✅ ScoreModel criado com ID: ${score.id}');
    print('   Total de notas: ${noteModels.length}');
    print('==========================================\n');

    return score;
  }

  Exercise scoreModelToExercise(ScoreModel score) {
    List<MusicalNote> musicalNotes = score.notes.map((noteModel) {
      return MusicalNote(
        note: noteModel.fullNote,
        displayName: noteModel.displayName,
        position: noteModel.position,
      );
    }).toList();

    return Exercise(
      id: score.id,
      name: score.title,
      keySignature: score.keySignature,
      tempo: score.bpm,
      notes: musicalNotes,
    );
  }

  int _inferDifficulty(int noteCount) {
    if (noteCount <= 8) return 1;
    if (noteCount <= 16) return 2;
    if (noteCount <= 24) return 3;
    return 4;
  }

  // ========== CRUD DE PARTITURAS ==========

  /// Salvar nova partitura
  Future<ScoreModel> saveScore({
    required String title,
    required int bpm,
    required String timeSignature,
    required String keySignature,
    required List<NoteModel> notes,
    required String userId,
    String? description,
    String? category,
    int? difficulty,
  }) async {
    final score = ScoreModel.create(
      title: title,
      bpm: bpm,
      timeSignature: timeSignature,
      keySignature: keySignature,
      notes: notes,
      userId: userId,
      description: description,
      category: category,
      difficulty: difficulty,
    );

    await scoreBox.put(score.id, score);
    print('Partitura salva: ${score.title}');
    return score;
  }

  /// Atualizar partitura existente
  Future<void> updateScore(ScoreModel score) async {
    score.updatedAt = DateTime.now();
    await score.save();
    print('Partitura atualizada: ${score.title}');
  }

  /// Deletar partitura
  Future<void> deleteScore(String scoreId) async {
    await scoreBox.delete(scoreId);
    print('Partitura deletada: $scoreId');
  }

  /// Obter partitura por ID
  ScoreModel? getScoreById(String id) {
    return scoreBox.get(id);
  }

  /// Obter todas as partituras do usuário
  List<ScoreModel> getUserScores(String userId) {
    return scoreBox.values
        .where((score) => score.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Obter partituras por categoria
  List<ScoreModel> getScoresByCategory(String userId, String category) {
    return getUserScores(userId)
        .where((score) => score.category == category)
        .toList();
  }

  /// Obter todas as partituras (incluindo padrão)
  List<ScoreModel> getAllScores() {
    return scoreBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Buscar partituras por nome
  List<ScoreModel> searchScores(String userId, String query) {
    final lowerQuery = query.toLowerCase();
    return getUserScores(userId)
        .where((score) =>
    score.title.toLowerCase().contains(lowerQuery) ||
        (score.description?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  // ========== CRUD DE PERFORMANCES ==========

  /// Salvar nova performance
  Future<PerformanceModel> savePerformance({
    required String scoreId,
    required String userId,
    required double accuracy,
    required double timing,
    required int totalScore,
    required List<PlayedNoteModel> playedNotes,
  }) async {
    final performance = PerformanceModel.create(
      scoreId: scoreId,
      userId: userId,
      accuracy: accuracy,
      timing: timing,
      totalScore: totalScore,
      playedNotes: playedNotes,
    );

    await performanceBox.put(performance.id, performance);
    print('Performance salva: Score ${performance.totalScore}');
    return performance;
  }

  /// Obter todas as performances de um usuário
  List<PerformanceModel> getUserPerformances(String userId) {
    return performanceBox.values
        .where((perf) => perf.userId == userId)
        .toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }

  /// Obter performances de uma partitura específica
  List<PerformanceModel> getScorePerformances(String scoreId, String userId) {
    return performanceBox.values
        .where((perf) => perf.scoreId == scoreId && perf.userId == userId)
        .toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }

  /// Obter melhor performance de uma partitura
  PerformanceModel? getBestPerformance(String scoreId, String userId) {
    final performances = getScorePerformances(scoreId, userId);
    if (performances.isEmpty) return null;

    performances.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return performances.first;
  }

  /// Deletar performance
  Future<void> deletePerformance(String performanceId) async {
    await performanceBox.delete(performanceId);
    print('Performance deletada: $performanceId');
  }

  // ========== ESTATÍSTICAS ==========

  /// Obter total de partituras do usuário
  int getUserScoreCount(String userId) {
    return getUserScores(userId).length;
  }

  /// Obter categorias únicas
  List<String> getCategories(String userId) {
    final categories = getUserScores(userId)
        .map((score) => score.category)
        .where((cat) => cat != null)
        .toSet()
        .toList();
    return categories.cast<String>();
  }

  /// Obter total de notas praticadas
  int getTotalNotesCount(String userId) {
    return getUserScores(userId)
        .fold(0, (sum, score) => sum + score.noteCount);
  }

  /// Obter total de performances do usuário
  int getUserPerformanceCount(String userId) {
    return getUserPerformances(userId).length;
  }

  /// Obter média de accuracy do usuário
  double getUserAverageAccuracy(String userId) {
    final performances = getUserPerformances(userId);
    if (performances.isEmpty) return 0.0;

    final totalAccuracy = performances.fold(0.0, (sum, perf) => sum + perf.accuracy);
    return totalAccuracy / performances.length;
  }

  // ========== DEBUG ==========

  void printStats(String userId) {
    print('\n=== ESTATÍSTICAS DE PARTITURAS ===');
    print('Total de partituras: ${getUserScoreCount(userId)}');
    print('Total de notas: ${getTotalNotesCount(userId)}');
    print('Categorias: ${getCategories(userId).join(", ")}');
    print('Total de performances: ${getUserPerformanceCount(userId)}');
    print('Accuracy média: ${getUserAverageAccuracy(userId).toStringAsFixed(1)}%');
    print('===================================\n');
  }

  /// Limpar todas as partituras do usuário
  Future<void> clearUserScores(String userId) async {
    final userScores = getUserScores(userId);
    for (var score in userScores) {
      await scoreBox.delete(score.id);
    }
    print('Todas as partituras do usuário foram deletadas');
  }

  /// Limpar todas as performances do usuário
  Future<void> clearUserPerformances(String userId) async {
    final userPerformances = getUserPerformances(userId);
    for (var perf in userPerformances) {
      await performanceBox.delete(perf.id);
    }
    print('Todas as performances do usuário foram deletadas');
  }

  static Future<void> close() async {
    await _scoreBox?.close();
    await _performanceBox?.close();
    print('ScoreBox e PerformanceBox fechados');
  }
}