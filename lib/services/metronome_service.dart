import 'dart:async';
import 'audio_service.dart';

class MetronomeService {
  final AudioService _audioService;

  Timer? _timer;
  int _currentBeat = 1;
  int _beatsPerMeasure = 4;
  int _bpm = 60;
  bool _isRunning = false;

  Function(int currentBeat, int totalBeats)? onBeatChanged;

  MetronomeService(this._audioService);

  void start({
    int bpm = 60,
    int beatsPerMeasure = 4,
    Function(int, int)? onBeat,
  }) {
    if (_isRunning) {
      print('Metrônomo já está rodando');
      return;
    }

    _bpm = bpm;
    _beatsPerMeasure = beatsPerMeasure;
    _currentBeat = 1;
    onBeatChanged = onBeat;

    int intervalMs = (60000 / bpm).round();

    print('Metrônomo iniciado: $bpm BPM, $beatsPerMeasure tempos por compasso');

    _playBeat();

    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      _playBeat();
    });

    _isRunning = true;
  }

  void _playBeat() {
    bool isAccent = (_currentBeat == 1);

    _audioService.playMetronome(isAccent: isAccent);

    onBeatChanged?.call(_currentBeat, _beatsPerMeasure);

    _currentBeat++;
    if (_currentBeat > _beatsPerMeasure) {
      _currentBeat = 1;
    }
  }

  void stop() {
    if (!_isRunning) {
      print('Metrônomo já está parado');
      return;
    }

    _timer?.cancel();
    _timer = null;
    _currentBeat = 1;
    _isRunning = false;

    print('Metrônomo parado');
  }

  void changeTempo(int newBpm) {
    if (!_isRunning) {
      _bpm = newBpm;
      return;
    }

    bool wasRunning = _isRunning;
    int currentBeatsPerMeasure = _beatsPerMeasure;
    var callback = onBeatChanged;

    stop();

    if (wasRunning) {
      start(
        bpm: newBpm,
        beatsPerMeasure: currentBeatsPerMeasure,
        onBeat: callback,
      );
    }

    print('Tempo alterado para $newBpm BPM');
  }

  void changeTimeSignature(int beatsPerMeasure) {
    if (!_isRunning) {
      _beatsPerMeasure = beatsPerMeasure;
      return;
    }

    bool wasRunning = _isRunning;
    int currentBpm = _bpm;
    var callback = onBeatChanged;

    stop();

    if (wasRunning) {
      start(
        bpm: currentBpm,
        beatsPerMeasure: beatsPerMeasure,
        onBeat: callback,
      );
    }

    print('Compasso alterado para $beatsPerMeasure tempos');
  }

  void playClick({bool isAccent = false}) {
    _audioService.playMetronome(isAccent: isAccent);
  }

  bool get isRunning => _isRunning;
  int get currentBeat => _currentBeat;
  int get beatsPerMeasure => _beatsPerMeasure;
  int get bpm => _bpm;

  void dispose() {
    stop();
    onBeatChanged = null;
    print('MetronomeService disposed');
  }
}