import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import '../services/audio_service.dart';
import '../widgets/score_display.dart';
import '../data/exercises/scales.dart';
import '../../models/exercise.dart';
import '../services/database_service.dart';
import '../services/score_database_service.dart';
import '../services/metronome_service.dart';
import '../widgets/practice_timer.dart';
import '../widgets/exercise_header.dart';
import '../widgets/practice_stats.dart';
import '../widgets/practice_controls.dart';
import '../widgets/completion_dialog.dart';
import '../widgets/loading_screen.dart';
import '../widgets/empty_exercises.dart';
import '../models/performance_model.dart';

class TrombonePracticeScreen extends StatefulWidget {
  const TrombonePracticeScreen({Key? key}) : super(key: key);

  @override
  State<TrombonePracticeScreen> createState() => _TrombonePracticeScreenState();
}

class _TrombonePracticeScreenState extends State<TrombonePracticeScreen>
    with TickerProviderStateMixin {

  final AudioService _audioService = AudioService();
  final DatabaseService _dbService = DatabaseService();
  final ScoreDatabaseService _scoreDbService = ScoreDatabaseService();
  final enhancedPitch = EnhancedPitchDetectionService();

  MetronomeService? _metronomeService;
  bool _isMetronomePlaying = false;

  bool _isListening = false;
  bool _isInitialized = false;
  double _currentPitch = 0.0;
  String _currentNote = '';
  double _pitchAccuracy = 0.0;
  double _lastAccuracy = 0.0;
  String _initializationStatus = 'Inicializando serviços de áudio...';

  DateTime? _practiceStartTime;
  Duration _totalPracticeTime = Duration.zero;
  Timer? _practiceTimer;
  String _formattedTime = '00:00';

  List<PlayedNoteModel> _playedNotes = [];

  int _currentExercise = 0;

  late AnimationController _pulseController;
  late AnimationController _accuracyController;
  late AnimationController _noteProgressController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _accuracyColorAnimation;
  late Animation<double> _noteProgressAnimation;

  StreamSubscription<Uint8List>? _audioSubscription;

  List<Exercise> _exercises = [];
  List<Exercise> _defaultExercises = [];
  List<Exercise> _userExercises = [];

  int _currentNoteIndex = 0;

  int? _bestScore;
  String? _currentScoreId;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _accuracyController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _noteProgressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _accuracyColorAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.green,
    ).animate(_accuracyController);

    _noteProgressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _noteProgressController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeServices() async {
    try {
      setState(() {
        _initializationStatus = 'Inicializando banco de dados...';
      });

      await ScoreDatabaseService.initialize();

      setState(() {
        _initializationStatus = 'Carregando exercícios...';
      });

      await _loadExercises();

      setState(() {
        _initializationStatus = 'Solicitando permissões de áudio...';
      });

      await _audioService.initialize();

      _metronomeService = MetronomeService(_audioService);
      print('MetronomeService inicializado');

      await enhancedPitch.initialize();

      setState(() {
        _isInitialized = true;
        _initializationStatus = 'Pronto para começar!';
      });

    } catch (e) {
      setState(() {
        _initializationStatus = 'Erro na inicialização: $e';
      });

      if (mounted) {
        _showErrorDialog('Erro de Inicialização',
            'Não foi possível inicializar os serviços.\n\nErro: $e');
      }
    }
  }

  Future<void> _loadExercises() async {
    try {
      _stopListening();
      _resetTimer();

      final currentUser = _dbService.getCurrentUser();

      _defaultExercises = ScalesLibrary.getAllScales();

      if (currentUser != null) {
        final userScores = _scoreDbService.getUserScores(currentUser.id);
        _userExercises = userScores
            .map((score) => _scoreDbService.scoreModelToExercise(score))
            .toList();
      }

      setState(() {
        _exercises = [..._defaultExercises, ..._userExercises];
      });

      _loadBestScore();

      print('${_defaultExercises.length} exercícios padrão');
      print('${_userExercises.length} exercícios do usuário');

    } catch (e) {
      print('Erro ao carregar exercícios: $e');
      setState(() {
        _exercises = ScalesLibrary.getAllScales();
      });
    }
  }

  void _loadBestScore() {
    final currentUser = _dbService.getCurrentUser();
    if (currentUser == null) {
      setState(() {
        _bestScore = null;
        _currentScoreId = null;
      });
      return;
    }

    String? scoreId;
    if (_currentExercise >= _defaultExercises.length) {
      int userExerciseIndex = _currentExercise - _defaultExercises.length;
      if (userExerciseIndex < _userExercises.length) {
        final userScores = _scoreDbService.getUserScores(currentUser.id);
        if (userExerciseIndex < userScores.length) {
          scoreId = userScores[userExerciseIndex].id;
        }
      }
    } else {
      final currentExercise = _exercises[_currentExercise];
      final existingScores = _scoreDbService.getUserScores(currentUser.id);

      final matchingScore = existingScores.firstWhere(
            (score) => score.id == currentExercise.id,
        orElse: () {
          final newScore = _scoreDbService.exerciseToScoreModel(
            currentExercise,
            currentUser.id,
          );
          return newScore;
        },
      );
      scoreId = matchingScore.id;
    }

    if (scoreId != null) {
      final bestPerformance = _scoreDbService.getBestPerformance(scoreId, currentUser.id);
      setState(() {
        _currentScoreId = scoreId;
        _bestScore = bestPerformance?.totalScore;
      });
      print('Melhor pontuação carregada: ${_bestScore ?? "Nenhuma"}');
    }
  }

  void _startTimer() {
    _practiceStartTime = DateTime.now().subtract(_totalPracticeTime);

    _practiceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _totalPracticeTime = DateTime.now().difference(_practiceStartTime!);
          _formattedTime = _formatDuration(_totalPracticeTime);
        });
      }
    });
  }

  void _pauseTimer() {
    print('Pausando timer...');
    _practiceTimer?.cancel();
    _practiceTimer = null;

    if (_practiceStartTime != null) {
      _totalPracticeTime = DateTime.now().difference(_practiceStartTime!);
    }

    print('Timer pausado em: ${_formatDuration(_totalPracticeTime)}');
  }

  void _resetTimer() {
    _practiceTimer?.cancel();
    _practiceTimer = null;
    _practiceStartTime = null;
    _totalPracticeTime = Duration.zero;
    setState(() {
      _formattedTime = '00:00';
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _accuracyController.dispose();
    _noteProgressController.dispose();
    _audioSubscription?.cancel();
    _practiceTimer?.cancel();
    _stopListening();
    _audioService.dispose();
    _metronomeService?.dispose();
    super.dispose();
  }

  void _toggleMetronome() {
    if (_metronomeService == null) {
      print('MetronomeService não está pronto ainda');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aguarde a inicialização completa')),
      );
      return;
    }

    setState(() {
      if (_isMetronomePlaying) {
        _metronomeService!.stop();
        _isMetronomePlaying = false;
      } else {
        int bpm = _exercises[_currentExercise].tempo;
        _metronomeService!.start(
          bpm: bpm,
          beatsPerMeasure: 4,
          onBeat: (currentBeat, totalBeats) {
            print('Batida $currentBeat/$totalBeats');
          },
        );
        _isMetronomePlaying = true;
      }
    });
  }

  void _startListening() async {
    if (!_isInitialized || _isListening) return;

    try {
      _playedNotes.clear();

      _startTimer();

      await _audioService.startRecording();
      _audioSubscription = _audioService.audioStream?.listen((audioData) {
        _processAudioData(audioData);
      });

      setState(() {
        _isListening = true;
      });

      HapticFeedback.lightImpact();

    } catch (e) {
      _showErrorDialog('Erro de Gravação',
          'Não foi possível iniciar a gravação de áudio.\n\nErro: $e');
    }
  }

  void _stopListening() async {
    if (!_isListening) return;

    try {
      _pauseTimer();

      await _audioService.stopRecording();
      await _audioSubscription?.cancel();
      _audioSubscription = null;

      setState(() {
        _isListening = false;
        _currentPitch = 0.0;
        _currentNote = '';
        _pitchAccuracy = 0.0;
      });

      _accuracyController.reset();
      _noteProgressController.reset();
      HapticFeedback.lightImpact();

    } catch (e) {
      print('Erro ao parar gravação: $e');
    }
  }

  void _recordPlayedNote({
    required String expectedNote,
    required String playedNote,
    required double expectedTime,
    required double playedTime,
    required bool isCorrect,
  }) {
    final playedNoteModel = PlayedNoteModel(
      expectedPitch: expectedNote,
      playedPitch: playedNote,
      expectedTime: expectedTime,
      playedTime: playedTime,
      isCorrect: isCorrect,
    );

    _playedNotes.add(playedNoteModel);
    print('Nota registrada: $expectedNote -> $playedNote (${isCorrect ? "✓" : "✗"})');
  }

  void _processAudioData(Uint8List audioData) {
    if (!_isListening || audioData.isEmpty) return;

    try {
      List<double>? samples = _audioService.processAudioChunk(audioData);

      if (samples == null || samples.length < 512) {
        return;
      }

      String? detectedNote = enhancedPitch.detectPitch(
        samples,
        sampleRate: 22050,
      );

      if (detectedNote != null) {
        double detectedFreq = _getNoteFrequency(detectedNote);
        String targetNote = _exercises[_currentExercise].notes[_currentNoteIndex].note;
        double targetFreq = _getNoteFrequency(targetNote);

        double difference = (detectedFreq - targetFreq).abs();
        double accuracy = math.max(0, 1 - (difference / (targetFreq * 0.15)));

        setState(() {
          _currentNote = detectedNote;
          _currentPitch = detectedFreq;
          _pitchAccuracy = accuracy;
        });

        _accuracyController.animateTo(_pitchAccuracy);

        if (_pitchAccuracy > 0.8 && _lastAccuracy <= 0.8) {
          _audioService.playCorrectSound();
          _noteProgressController.forward();

          _recordPlayedNote(
            expectedNote: targetNote,
            playedNote: detectedNote,
            expectedTime: _currentNoteIndex.toDouble(),
            playedTime: _totalPracticeTime.inMilliseconds / 1000.0,
            isCorrect: true,
          );

          Future.delayed(const Duration(milliseconds: 1500), () {
            if (_pitchAccuracy > 0.8 && _isListening) {
              _nextNote();
            }
          });
        }

        else if (_pitchAccuracy < 0.3 && _lastAccuracy >= 0.3) {
          _audioService.playIncorrectSound();
          _noteProgressController.reverse();

          _recordPlayedNote(
            expectedNote: targetNote,
            playedNote: detectedNote,
            expectedTime: _currentNoteIndex.toDouble(),
            playedTime: _totalPracticeTime.inMilliseconds / 1000.0,
            isCorrect: false,
          );
        }

        _lastAccuracy = _pitchAccuracy;
      }

    } catch (e) {
      print('Erro no processamento de áudio: $e');
    }
  }

  void _nextNote() {
    if (_currentNoteIndex < _exercises[_currentExercise].notes.length - 1) {
      setState(() {
        _currentNoteIndex++;
      });
      _noteProgressController.reset();
      HapticFeedback.selectionClick();

      String nextNote = _exercises[_currentExercise].notes[_currentNoteIndex].note;
      _playReferenceNote(nextNote);

    } else {
      _completeExercise();
    }
  }

  void _previousNote() {
    if (_currentNoteIndex > 0) {
      setState(() {
        _currentNoteIndex--;
      });
      _noteProgressController.reset();
      HapticFeedback.selectionClick();

      String prevNote = _exercises[_currentExercise].notes[_currentNoteIndex].note;
      _playReferenceNote(prevNote);
    }
  }

  void _playReferenceNote(String note) async {
    String pitch = note.substring(0, note.length - 1);
    int octave = int.parse(note.substring(note.length - 1));
    _audioService.playNote(pitch, octave, 1.0);
  }

  Future<Map<String, dynamic>> _savePerformance() async {
    try {
      final currentUser = _dbService.getCurrentUser();

      if (currentUser == null) {
        print('Nenhum usuário logado. Performance não salva.');
        return {'totalScore': 0, 'message': 'Usuário não logado', 'isNewRecord': false};
      }

      double averageAccuracy = _playedNotes.isEmpty
          ? 0.0
          : _playedNotes.fold(0.0, (sum, note) => sum + (note.isCorrect ? 1.0 : 0.0)) / _playedNotes.length * 100;

      double averageTiming = _calculateAverageTiming();
      int totalScore = (averageAccuracy * 0.7 + averageTiming * 0.3).round();

      String? scoreId = _currentScoreId;

      if (scoreId == null) {
        final currentExercise = _exercises[_currentExercise];
        final scoreModel = _scoreDbService.exerciseToScoreModel(
          currentExercise,
          currentUser.id,
        );
        await _scoreDbService.scoreBox.put(scoreModel.id, scoreModel);
        scoreId = scoreModel.id;
      }

      bool shouldSave = false;
      String message = '';

      if (_bestScore == null) {
        shouldSave = true;
        message = 'Primeira pontuação registrada!';
      } else if (totalScore > _bestScore!) {
        shouldSave = true;
        message = 'Novo recorde! ${_bestScore} → $totalScore';
      } else {
        message = 'Pontuação: $totalScore (Recorde: $_bestScore)';
      }

      if (shouldSave) {
        await _scoreDbService.savePerformance(
          scoreId: scoreId,
          userId: currentUser.id,
          accuracy: averageAccuracy,
          timing: averageTiming,
          totalScore: totalScore,
          playedNotes: _playedNotes,
        );

        setState(() {
          _bestScore = totalScore;
        });

        print('   Performance salva com sucesso!');
        print('   Score: $totalScore');
        print('   Accuracy: ${averageAccuracy.toStringAsFixed(1)}%');
        print('   Timing: ${averageTiming.toStringAsFixed(1)}%');
      } else {
        print('   Performance não salva (pontuação não é recorde)');
        print('   Score atual: $totalScore');
        print('   Melhor score: $_bestScore');
      }

      return {'totalScore': totalScore, 'message': message, 'isNewRecord': shouldSave};

    } catch (e) {
      print('Erro ao salvar performance: $e');
      return {'totalScore': 0, 'message': 'Erro ao salvar', 'isNewRecord': false};
    }
  }

  double _calculateAverageTiming() {
    if (_playedNotes.isEmpty) return 0.0;

    double totalTimingAccuracy = 0.0;
    for (var note in _playedNotes) {
      double timeDiff = (note.playedTime - note.expectedTime).abs();
      double timingAccuracy = 100 - (timeDiff * 10).clamp(0, 100);
      totalTimingAccuracy += timingAccuracy;
    }

    return totalTimingAccuracy / _playedNotes.length;
  }

  void _completeExercise() async {
    _stopListening();
    _pauseTimer();

    final result = await _savePerformance();
    final totalScore = result['totalScore'] as int;
    final message = result['message'] as String;
    final isNewRecord = result['isNewRecord'] as bool;

    CompletionDialog.show(
      context: context,
      exercise: _exercises[_currentExercise],
      formattedTime: _formattedTime,
      totalScore: totalScore,
      bestScore: _bestScore,
      scoreMessage: message,
      isNewRecord: isNewRecord,
      onRepeat: () {
        Navigator.of(context).pop();
        _resetTimer();
        setState(() {
          _currentNoteIndex = 0;
        });
      },
      onNext: () {
        Navigator.of(context).pop();
        _resetTimer();
        if (_currentExercise < _exercises.length - 1) {
          setState(() {
            _currentExercise++;
            _currentNoteIndex = 0;
          });
          _loadBestScore();
        }
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  double _getNoteFrequency(String note) {
    final noteFrequencies = {
      'C3': 130.81, 'C#3': 138.59, 'D3': 146.83, 'D#3': 155.56, 'E3': 164.81,
      'F3': 174.61, 'F#3': 185.00, 'G3': 196.00, 'G#3': 207.65, 'A3': 220.00,
      'A#3': 233.08, 'Bb3': 233.08, 'B3': 246.94,

      'C4': 261.63, 'C#4': 277.18, 'D4': 293.66, 'D#4': 311.13, 'Eb4': 311.13,
      'E4': 329.63, 'F4': 349.23, 'F#4': 369.99, 'G4': 392.00, 'G#4': 415.30,
      'A4': 440.00, 'A#4': 466.16, 'Bb4': 466.16, 'B4': 493.88,

      'C5': 523.25, 'C#5': 554.37, 'D5': 587.33, 'D#5': 622.25, 'Eb5': 622.25,
      'E5': 659.25, 'F5': 698.46, 'F#5': 739.99, 'G5': 783.99, 'G#5': 830.61,
      'A5': 880.00, 'A#5': 932.33, 'Bb5': 932.33, 'B5': 987.77,
    };
    return noteFrequencies[note] ?? 440.0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return LoadingScreenWidget(status: _initializationStatus);
    }

    if (_exercises.isEmpty) {
      return EmptyExercisesWidget(onReload: _loadExercises);
    }

    final currentExercise = _exercises[_currentExercise];
    final currentTargetNote = currentExercise.notes[_currentNoteIndex].note;

    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isSmallDevice = size.width < 1000;
    final isVerySmallWidth = size.width < 400;

    final useTwoColumns = isLandscape && isSmallDevice;

    return Scaffold(
      appBar: AppBar(
        title: isVerySmallWidth
            ? const Text(
          'Prática',
          overflow: TextOverflow.ellipsis,
        )
            : Row(
          children: [
            const Expanded(
              child: Text(
                'Prática de Trombone',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            PracticeTimerWidget(
              formattedTime: _formattedTime,
              isListening: _isListening,
            ),
          ],
        ),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isVerySmallWidth)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: PracticeTimerWidget(
                  formattedTime: _formattedTime,
                  isListening: _isListening,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExercises,
            tooltip: 'Recarregar exercícios',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade600,
              Colors.indigo.shade400,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: useTwoColumns
              ? _buildLandscapeLayout(currentExercise, currentTargetNote)
              : _buildPortraitLayout(currentExercise, currentTargetNote),
        ),
      ),
    );
  }

  // Layout normal (1 coluna) - para em pé ou telas grandes
  Widget _buildPortraitLayout(Exercise currentExercise, String currentTargetNote) {
    return Column(
      children: [
        ExerciseHeaderWidget(
          exercise: currentExercise,
          currentNoteIndex: _currentNoteIndex,
          bestScore: _bestScore,
          onPlayReference: () => _playReferenceNote(currentTargetNote),
        ),

        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: ScoreDisplayWidget(
              notes: currentExercise.notes,
              currentNoteIndex: _currentNoteIndex,
              detectedNote: _currentNote,
              accuracy: _pitchAccuracy,
              isListening: _isListening,
              accuracyAnimation: _accuracyColorAnimation,
              progressAnimation: _noteProgressAnimation,
              title: currentExercise.name,
              keySignature: currentExercise.keySignature,
              timeSignature: '4/4',
            ),
          ),
        ),

        PracticeStatsWidget(
          exercise: currentExercise,
          currentNoteIndex: _currentNoteIndex,
          currentNote: _currentNote,
          pitchAccuracy: _pitchAccuracy,
          accuracyColorAnimation: _accuracyColorAnimation,
        ),

        const SizedBox(height: 20),

        PracticeControlsWidget(
          isListening: _isListening,
          canGoPrevious: _currentNoteIndex > 0,
          canGoNext: _currentNoteIndex < currentExercise.notes.length - 1,
          onPrevious: _previousNote,
          onToggleListening: _isListening ? _stopListening : _startListening,
          onNext: _nextNote,
        ),
      ],
    );
  }

  // Layout de 2 colunas - para deitado em tela pequena
  Widget _buildLandscapeLayout(Exercise currentExercise, String currentTargetNote) {
    return Row(
      children: [
        // Coluna esquerda: Header + Stats + Controls
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ExerciseHeaderWidget(
                  exercise: currentExercise,
                  currentNoteIndex: _currentNoteIndex,
                  bestScore: _bestScore,
                  onPlayReference: () => _playReferenceNote(currentTargetNote),
                ),

                const SizedBox(height: 12),

                PracticeStatsWidget(
                  exercise: currentExercise,
                  currentNoteIndex: _currentNoteIndex,
                  currentNote: _currentNote,
                  pitchAccuracy: _pitchAccuracy,
                  accuracyColorAnimation: _accuracyColorAnimation,
                ),

                const SizedBox(height: 12),

                PracticeControlsWidget(
                  isListening: _isListening,
                  canGoPrevious: _currentNoteIndex > 0,
                  canGoNext: _currentNoteIndex < currentExercise.notes.length - 1,
                  onPrevious: _previousNote,
                  onToggleListening: _isListening ? _stopListening : _startListening,
                  onNext: _nextNote,
                ),
              ],
            ),
          ),
        ),

        // Coluna direita: Partitura
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(12.0),
            child: ScoreDisplayWidget(
              notes: currentExercise.notes,
              currentNoteIndex: _currentNoteIndex,
              detectedNote: _currentNote,
              accuracy: _pitchAccuracy,
              isListening: _isListening,
              accuracyAnimation: _accuracyColorAnimation,
              progressAnimation: _noteProgressAnimation,
              title: currentExercise.name,
              keySignature: currentExercise.keySignature,
              timeSignature: '4/4',
            ),
          ),
        ),
      ],
    );
  }

  void _showSettings() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: isSmallScreen ? 16.0 : 20.0,
            right: isSmallScreen ? 16.0 : 20.0,
            top: isSmallScreen ? 16.0 : 20.0,
            // Adiciona espaço extra para evitar sobreposição com o teclado
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Configurações',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),

              ListTile(
                title: const Text('Exercício'),
                subtitle: Text(_exercises[_currentExercise].name),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showExerciseSelection();
                },
              ),

              ListTile(
                title: Text(
                  _isMetronomePlaying ? 'Parar Metrônomo' : 'Iniciar Metrônomo',
                ),
                subtitle: Text('${_exercises[_currentExercise].tempo} BPM - 4/4'),
                leading: Icon(
                  _isMetronomePlaying ? Icons.stop_circle : Icons.music_note,
                  color: _isMetronomePlaying ? Colors.red : Colors.indigo,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleMetronome();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseSelection() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Escolher Exercício',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
        content: SizedBox(
          width: math.min(MediaQuery.of(context).size.width * 0.8, 400),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _exercises.length,
            itemBuilder: (context, index) {
              final exercise = _exercises[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8.0 : 16.0,
                  vertical: isSmallScreen ? 4.0 : 8.0,
                ),
                title: Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: index == _currentExercise
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '${exercise.notes.length} notas - ${exercise.tempo} BPM',
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                ),
                selected: index == _currentExercise,
                selectedTileColor: Colors.indigo.withOpacity(0.1),
                onTap: () {
                  setState(() {
                    _currentExercise = index;
                    _currentNoteIndex = 0;
                  });
                  Navigator.pop(context);
                  _stopListening();
                  _loadBestScore();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fechar',
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
          ),
        ],
      ),
    );
  }

  void _testMicrophone() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teste do Microfone'),
        content: const Text(
            'Toque em "Iniciar" e fale ou faça algum som. '
                'Se o microfone estiver funcionando, você verá a detecção de pitch.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startListening();
            },
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }
}