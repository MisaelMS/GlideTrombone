import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import '../services/audio_service.dart';
import '../widgets/turner_meter.dart';

class TunerScreen extends StatefulWidget {
  const TunerScreen({Key? key}) : super(key: key);

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> with TickerProviderStateMixin {
  bool _isInitializing = false;
  String _initializationStatus = '';
  bool _isListening = false;
  double _currentFrequency = 0.0;
  String _currentNote = '';
  int _currentCents = 0;
  bool _isInTune = false;

  late AnimationController _needleController;
  late AnimationController _tuneIndicatorController;
  late Animation<double> _needleAnimation;
  late Animation<Color?> _tuneColorAnimation;

  final AudioService _audioService = AudioService();

  StreamSubscription<Uint8List>? _audioSubscription;

  List<String?> _recentDetections = [];
  final int _detectionBufferSize = 5;

  final Map<String, double> _tromboneNotes = {
    'Bb2': 116.54,  // Posição 1
    'C3': 130.81,   // Posição 6
    'D3': 146.83,   // Posição 4
    'Eb3': 155.56,  // Posição 3
    'F3': 174.61,   // Posição 1
    'G3': 196.00,   // Posição 4
    'A3': 220.00,   // Posição 2
    'Bb3': 233.08,  // Posição 1
    'C4': 261.63,   // Posição 6
    'D4': 293.66,   // Posição 4
    'Eb4': 311.13,  // Posição 3
    'F4': 349.23,   // Posição 1
    'G4': 392.00,   // Posição 4
    'A4': 440.00,   // Posição 2
    'Bb4': 466.16,  // Posição 1
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _needleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tuneIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _needleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _needleController,
      curve: Curves.easeInOut,
    ));

    _tuneColorAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.green,
    ).animate(_tuneIndicatorController);
  }

  @override
  void dispose() {
    _needleController.dispose();
    _tuneIndicatorController.dispose();
    _audioSubscription?.cancel();
    _stopListening();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isListening) {
      setState(() {
        _isInitializing = true;
        _initializationStatus = 'Parando afinador...';
      });

      await _stopListening();

      setState(() {
        _isInitializing = false;
      });
    } else {
      setState(() {
        _isInitializing = true;
        _initializationStatus = 'Preparando afinador...';
      });

      await _startListening();

      setState(() {
        _isInitializing = false;
        _isListening = true;
      });
    }
  }

  Future<void> _startListening() async {
    try {
      setState(() {
        _initializationStatus = 'Iniciando microfone...';
      });

      if (!_audioService.isInitialized) {
        await _audioService.initialize();
      }

      _recentDetections.clear();
      _audioService.clearAudioBuffer();

      setState(() {
        _initializationStatus = 'Conectando ao microfone...';
      });

      await _audioService.startRecording();

      if (!_audioService.isRecording) {
        throw Exception('Não foi possível iniciar a gravação');
      }

      setState(() {
        _initializationStatus = 'Processando áudio...';
      });

      _audioSubscription = _audioService.audioStream?.listen(
            (audioData) {
          _processAudioData(audioData);
        },
        onError: (error) {
          print('Erro no stream de áudio: $error');
          _handleStreamError(error);
        },
        onDone: () {
          print('Stream de áudio finalizado');
        },
      );

      if (_audioSubscription == null) {
        throw Exception('Não foi possível conectar ao stream de áudio');
      }

    } catch (e) {
      print('Erro ao iniciar detecção: $e');
      setState(() {
        _isListening = false;
      });
      _showErrorDialog('Erro ao acessar o microfone: $e\nVerifique as permissões e tente novamente.');
    }
  }

  void _handleStreamError(dynamic error) {
    setState(() {
      _isListening = false;
    });
    _showErrorDialog('Erro no stream de áudio: $error');
  }

  Future<void> _stopListening() async {
    try {
      await _audioSubscription?.cancel();
      _audioSubscription = null;

      if (_audioService.isRecording) {
        await _audioService.stopRecording();
      }

      setState(() {
        _isListening = false;
        _currentFrequency = 0.0;
        _currentNote = '';
        _currentCents = 0;
        _isInTune = false;
      });

      _needleController.reset();
      _tuneIndicatorController.reset();

    } catch (e) {
      print('Erro ao parar detecção: $e');
      setState(() {
        _isListening = false;
        _currentFrequency = 0.0;
        _currentNote = '';
        _currentCents = 0;
        _isInTune = false;
      });
    }
  }

  void _processAudioData(Uint8List rawAudioData) {
    try {
      if (rawAudioData.isEmpty || !_isListening) {
        return;
      }

      List<double>? audioSamples = _audioService.processAudioChunk(rawAudioData);

      if (audioSamples == null) {
        return;
      }

      double energy = 0.0;
      for (double sample in audioSamples) {
        energy += sample * sample;
      }
      energy = energy / audioSamples.length;

      if (energy < 0.001) {
        return;
      }

      double? frequency = _detectFrequencyYIN(audioSamples, 22050);

      if (frequency != null && frequency >= 80 && frequency <= 2000) {
        String? detectedNote = _frequencyToPitch(frequency);

        if (detectedNote != null) {
          String? smoothedNote = _smoothDetection(detectedNote);

          if (smoothedNote != null) {
            _updateWithDetectedFrequency(smoothedNote, frequency);
          }
        }
      }
    } catch (e) {
      print('Erro ao processar áudio: $e');
    }
  }

  double? _detectFrequencyYIN(List<double> buffer, double sampleRate) {
    int bufferSize = buffer.length;
    if (bufferSize < 1024) return null;

    List<double> yinBuffer = List.filled(bufferSize ~/ 2, 0.0);

    for (int tau = 0; tau < yinBuffer.length; tau++) {
      for (int i = 0; i < yinBuffer.length; i++) {
        if (i + tau < buffer.length) {
          double delta = buffer[i] - buffer[i + tau];
          yinBuffer[tau] += delta * delta;
        }
      }
    }

    yinBuffer[0] = 1.0;
    double runningSum = 0.0;

    for (int tau = 1; tau < yinBuffer.length; tau++) {
      runningSum += yinBuffer[tau];
      if (runningSum > 0) {
        yinBuffer[tau] *= tau / runningSum;
      }
    }

    double threshold = 0.1;
    int tau = 2;

    while (tau < yinBuffer.length) {
      if (yinBuffer[tau] < threshold) {
        while (tau + 1 < yinBuffer.length && yinBuffer[tau + 1] < yinBuffer[tau]) {
          tau++;
        }
        break;
      }
      tau++;
    }

    if (tau == yinBuffer.length || yinBuffer[tau] >= threshold) {
      return null;
    }

    double betterTau = tau.toDouble();
    if (tau > 0 && tau < yinBuffer.length - 1) {
      double s0 = yinBuffer[tau - 1];
      double s1 = yinBuffer[tau];
      double s2 = yinBuffer[tau + 1];
      double denominator = 2 * (2 * s1 - s2 - s0);
      if (denominator != 0) {
        betterTau = tau + (s2 - s0) / denominator;
      }
    }

    return sampleRate / betterTau;
  }

  String? _frequencyToPitch(double frequency) {
    if (frequency <= 0) return null;

    double a4 = 440.0;
    double c0 = a4 * math.pow(2, -4.75);

    double halfSteps = 12 * (math.log(frequency / c0) / math.ln2);
    int roundedHalfSteps = halfSteps.round();

    List<String> noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

    int octave = roundedHalfSteps ~/ 12;
    int noteIndex = roundedHalfSteps % 12;

    if (octave < 0 || octave > 8 || noteIndex < 0) return null;

    return '${noteNames[noteIndex]}$octave';
  }

  String? _smoothDetection(String? currentNote) {
    _recentDetections.add(currentNote);

    if (_recentDetections.length > _detectionBufferSize) {
      _recentDetections.removeAt(0);
    }

    Map<String?, int> counts = {};
    for (String? note in _recentDetections) {
      counts[note] = (counts[note] ?? 0) + 1;
    }

    String? mostCommon;
    int maxCount = 0;

    counts.forEach((note, count) {
      if (note != null && count > maxCount) {
        mostCommon = note;
        maxCount = count;
      }
    });

    return maxCount >= (_detectionBufferSize * 0.6) ? mostCommon : null;
  }

  void _updateWithDetectedFrequency(String note, double frequency) {
    final result = _getNearestNote(frequency);

    setState(() {
      _currentFrequency = frequency;
      _currentNote = result['note'];
      _currentCents = result['cents'];
      _isInTune = result['cents'].abs() <= 10;
    });

    final needlePosition = (result['cents'] + 50) / 100;
    _needleController.animateTo(needlePosition.clamp(0.0, 1.0));

    if (_isInTune) {
      _tuneIndicatorController.forward();
      HapticFeedback.lightImpact();
    } else {
      _tuneIndicatorController.reverse();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> _getNearestNote(double frequency) {
    if (frequency <= 0) return {'note': '', 'cents': 0};

    String nearestNote = '';
    double nearestFreq = 0;
    double minDiff = double.infinity;

    _tromboneNotes.forEach((note, freq) {
      final diff = (frequency - freq).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearestNote = note;
        nearestFreq = freq;
      }
    });

    final cents = nearestFreq > 0
        ? (1200 * math.log(frequency / nearestFreq) / math.ln2).round()
        : 0;

    return {
      'note': nearestNote,
      'cents': cents,
    };
  }

  String _getTrombonePosition(String note) {
    const positions = {
      'Bb2': '1ª', 'Bb3': '1ª', 'Bb4': '1ª', 'F3': '1ª', 'F4': '1ª',
      'A3': '2ª', 'A4': '2ª',
      'Eb3': '3ª', 'Eb4': '3ª',
      'D3': '4ª', 'D4': '4ª', 'G3': '4ª', 'G4': '4ª',
      'C3': '6ª', 'C4': '6ª',
    };
    return positions[note] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Afinador'),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade400,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _currentNote.isEmpty ? '--' : _currentNote,
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: _isInTune ? Colors.green.shade600 : Colors.black87,
                              ),
                            ),
                            if (_currentNote.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Posição ${_getTrombonePosition(_currentNote)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_currentFrequency.toStringAsFixed(1)} Hz',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      TunerMeter(
                        needlePosition: _needleAnimation.value,
                        isInTune: _isInTune,
                        cents: _currentCents,
                        showCentsLabel: true,
                        showScale: true,
                        height: 200,
                      ),

                      const SizedBox(height: 40),

                      AnimatedBuilder(
                        animation: _tuneColorAnimation,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _isInTune
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _isInTune
                                    ? Colors.green.shade300
                                    : Colors.red.shade300,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isInTune ? Icons.check_circle : Icons.music_note,
                                  color: _isInTune
                                      ? Colors.green.shade600
                                      : Colors.red.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isInTune ? 'AFINADO' : _isListening ? 'AJUSTE A AFINAÇÃO' : 'TOQUE UMA NOTA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _isInTune
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (_isInitializing) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(
                              _initializationStatus,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isInitializing ? null : _toggleListening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening
                              ? Colors.red.shade600
                              : Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isInitializing) ...[
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'INICIALIZANDO...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ] else ...[
                              Icon(
                                _isListening ? Icons.stop : Icons.play_arrow,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _isListening ? 'PARAR' : 'INICIAR AFINADOR',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}