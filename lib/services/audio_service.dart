import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final _midiPro = MidiPro();
  bool _soundFontLoaded = false;
  int? _soundFontId;

  List<int> _audioBuffer = [];
  static const int REQUIRED_SAMPLES = 1024;

  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  AudioPlayer? _audioPlayer;

  bool _isRecording = false;
  bool _isInitialized = false;

  StreamController<Uint8List>? _audioStreamController;
  Stream<Uint8List>? get audioStream => _audioStreamController?.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    print('AudioService: Iniciando inicialização...');

    var status = await Permission.microphone.status;
    print('AudioService: Status da permissão: $status');

    if (!status.isGranted) {
      print('AudioService: Solicitando permissão...');
      status = await Permission.microphone.request();
      print('AudioService: Nova permissão: $status');
    }

    if (!status.isGranted) {
      throw Exception('Permissão do microfone negada');
    }

    try {
      print('AudioService: Criando instâncias...');
      _recorder = FlutterSoundRecorder();
      _player = FlutterSoundPlayer();
      _audioPlayer = AudioPlayer();

      print('AudioService: Abrindo recorder...');
      await _recorder!.openRecorder();
      await _player!.openPlayer();

      print('AudioService: Criando stream controller...');
      _audioStreamController = StreamController<Uint8List>.broadcast();

      _isInitialized = true;
      print('AudioService: Inicialização completa!');

    } catch (e) {
      print('AudioService: Erro na inicialização: $e');
      rethrow;
    }

    await Future.delayed(Duration(milliseconds: 500));
    await _initializeMidi();
  }

  Future<void> _initializeMidi() async {
    try {
      print('Inicializando MIDI...');

      final ByteData data = await rootBundle.load('assets/sounds/Trombone.sf2');
      print('Arquivo carregado: ${data.lengthInBytes} bytes');

      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/Trombone.sf2';

      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
      print('Arquivo salvo em: $tempPath');

      if (!await tempFile.exists()) {
        throw Exception('Arquivo temporário não foi criado');
      }

      print('Arquivo existe: ${await tempFile.length()} bytes');

      _soundFontId = await _midiPro.loadSoundfont(
        path: tempPath,
        bank: 0,
        program: 57,
      );

      print('SoundFont carregado! ID: $_soundFontId');

      await _testMidi();

      _soundFontLoaded = true;
      print('MIDI totalmente configurado e testado!');

    } catch (e, stackTrace) {
      print('Erro ao carregar SoundFont: $e');
      print('Stack: $stackTrace');
      _soundFontLoaded = false;
      _soundFontId = null;
      print('Aplicativo continuará usando síntese de áudio');
    }
  }

  Future<void> _testMidi() async {
    try {
      print('Testando MIDI...');

      await _midiPro.playNote(
        key: 60,
        velocity: 100,
        sfId: _soundFontId ?? 0,
      );

      await Future.delayed(Duration(milliseconds: 200));

      await _midiPro.stopNote(
        key: 60,
        sfId: _soundFontId ?? 0,
      );

      print('Teste MIDI concluído');
    } catch (e) {
      print('Erro no teste MIDI: $e');
      rethrow;
    }
  }

  Future<void> startRecording() async {
    if (!_isInitialized) {
      print('AudioService: Não inicializado!');
      return;
    }

    if (_isRecording) {
      print('AudioService: Já está gravando!');
      return;
    }

    try {
      print('AudioService: Iniciando gravação...');

      _audioBuffer.clear();

      await _recorder!.startRecorder(
        toStream: _audioStreamController!.sink,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: 22050,
      );

      _isRecording = true;
      print('AudioService: Gravação iniciada!');

    } catch (e) {
      print('AudioService: Erro ao iniciar gravação: $e');
      rethrow;
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    try {
      print('AudioService: Parando gravação...');
      await _recorder!.stopRecorder();
      _isRecording = false;
      _audioBuffer.clear();
      print('AudioService: Gravação parada!');
    } catch (e) {
      print('AudioService: Erro ao parar gravação: $e');
    }
  }

  Future<void> playNote(String pitch, int octave, double duration) async {
    if (!_isInitialized) {
      print('AudioService não inicializado');
      return;
    }

    bool wasRecording = _isRecording;
    if (wasRecording) {
      await stopRecording();
    }

    print('Tocando nota: $pitch$octave (duração: ${duration}s)');

    bool useMidi = false;

    try {
      if (useMidi && _soundFontLoaded && _soundFontId != null) {
        int midiNote = _getNoteToMidiNumber(pitch, octave);
        print('MIDI note: $midiNote, SoundFont ID: $_soundFontId');

        // Tocar nota MIDI
        await _midiPro.playNote(
          key: midiNote,
          velocity: 100,
          sfId: _soundFontId!,
        );

        print('Nota MIDI tocada');

        // Aguardar duração
        await Future.delayed(Duration(milliseconds: (duration * 1000).toInt()));

        // Parar nota
        await _midiPro.stopNote(
          key: midiNote,
          sfId: _soundFontId!,
        );

        print('Nota MIDI parada');

      } else {
        print('Usando SÍNTESE (MIDI desabilitado temporariamente)');
        await _playSynthesizedNote(pitch, octave, duration);
      }
    } catch (e, stackTrace) {
      print('Erro ao tocar nota: $e');
      print('Stack: $stackTrace');

      print('Tentando síntese como fallback');
      try {
        await _playSynthesizedNote(pitch, octave, duration);
      } catch (e2) {
        print('Erro também na síntese: $e2');
      }
    }

    if (wasRecording) {
      await Future.delayed(Duration(milliseconds: 100));
      await startRecording();
    }
  }

  int _getNoteToMidiNumber(String pitch, int octave) {
    final Map<String, int> pitchToSemitone = {
      'C': 0, 'C#': 1, 'Db': 1,
      'D': 2, 'D#': 3, 'Eb': 3,
      'E': 4,
      'F': 5, 'F#': 6, 'Gb': 6,
      'G': 7, 'G#': 8, 'Ab': 8,
      'A': 9, 'A#': 10, 'Bb': 10,
      'B': 11,
    };

    int semitone = pitchToSemitone[pitch] ?? 9;
    return 12 + semitone + (octave * 12);
  }

  Future<void> _playSynthesizedNote(String pitch, int octave, double duration) async {
    print('Iniciando síntese: $pitch$octave');

    double frequency = _getNoteFrequency(pitch, octave);
    print('Frequência: $frequency Hz');

    const int sampleRate = 44100;
    int numSamples = (sampleRate * duration).toInt();

    List<int> samples = [];
    for (int i = 0; i < numSamples; i++) {
      double time = i / sampleRate;
      double value = math.sin(2 * math.pi * frequency * time);
      double envelope = _calculateEnvelope(i, numSamples);
      int sample = (value * envelope * 32767 * 0.9).toInt(); // Volume alto para teste
      samples.add(sample & 0xFF);
      samples.add((sample >> 8) & 0xFF);
    }

    Uint8List audioData = Uint8List.fromList(samples);
    print('Dados gerados: ${audioData.length} bytes');

    try {
      await _player!.startPlayer(
        fromDataBuffer: audioData,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: sampleRate,
      );
      print('Player iniciado');

      await Future.delayed(Duration(milliseconds: (duration * 1000).toInt()));

      await _player!.stopPlayer();
      print('Player parado');
    } catch (e) {
      print('Erro no player: $e');
      rethrow;
    }
  }

  double _calculateEnvelope(int sample, int totalSamples) {
    double position = sample / totalSamples;

    if (position < 0.1) {
      return position / 0.1;
    } else if (position < 0.2) {
      return 1.0 - ((position - 0.1) / 0.1) * 0.2;
    } else if (position < 0.8) {
      return 0.8;
    } else {
      return 0.8 * (1.0 - (position - 0.8) / 0.2);
    }
  }

  double _getNoteFrequency(String pitch, int octave) {
    final Map<String, int> pitchToSemitone = {
      'C': 0, 'C#': 1, 'Db': 1,
      'D': 2, 'D#': 3, 'Eb': 3,
      'E': 4,
      'F': 5, 'F#': 6, 'Gb': 6,
      'G': 7, 'G#': 8, 'Ab': 8,
      'A': 9, 'A#': 10, 'Bb': 10,
      'B': 11,
    };

    int semitone = pitchToSemitone[pitch] ?? 9;
    int midiNote = semitone + (octave * 12);
    double frequency = 440.0 * math.pow(2, (midiNote - 69) / 12);

    return frequency;
  }

  Future<void> playMetronome({bool isAccent = false}) async {
    if (!_isInitialized) {
      print('AudioService não inicializado');
      return;
    }

    _playMetronomeAsync(isAccent);
  }

  Future<void> _playMetronomeAsync(bool isAccent) async {
    try {
      const int sampleRate = 44100;
      double duration = isAccent ? 0.08 : 0.05;
      int numSamples = (sampleRate * duration).toInt();

      List<int> samples = [];
      final random = math.Random();

      for (int i = 0; i < numSamples; i++) {
        double time = i / sampleRate;

        double noise = (random.nextDouble() * 2 - 1) * 0.4;
        double tone = math.sin(2 * math.pi * (isAccent ? 1200 : 1800) * time) * 0.6;

        double value = noise + tone;
        double envelope = math.exp(-20 * time / duration);
        double volume = isAccent ? 0.8 : 0.6;

        int sample = (value * envelope * 32767 * volume).toInt();

        samples.add(sample & 0xFF);
        samples.add((sample >> 8) & 0xFF);
      }

      Uint8List audioData = Uint8List.fromList(samples);

      await _player!.startPlayer(
        fromDataBuffer: audioData,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: sampleRate,
      );

    } catch (e) {
      print('Erro ao reproduzir metrônomo: $e');
    }
  }

  Future<void> playCorrectSound() async {
    try {
      print('AudioService: Som de acerto');
      await _audioPlayer!.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      print('AudioService: Som de acerto não encontrado');
    }
  }

  Future<void> playIncorrectSound() async {
    try {
      print('AudioService: Som de erro');
      await _audioPlayer!.play(AssetSource('sounds/incorrect.mp3'));
    } catch (e) {
      print('AudioService: Som de erro não encontrado');
    }
  }

  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;

  List<double>? processAudioChunk(Uint8List audioData) {
    _audioBuffer.addAll(audioData);

    int requiredBytes = REQUIRED_SAMPLES * 2;
    if (_audioBuffer.length < requiredBytes) {
      return null;
    }

    List<double> samples = [];
    int bytesToProcess = math.min(_audioBuffer.length, requiredBytes);

    for (int i = 0; i < bytesToProcess - 1; i += 2) {
      int sample16bit = (_audioBuffer[i + 1] << 8) | _audioBuffer[i];

      if (sample16bit > 32767) {
        sample16bit -= 65536;
      }

      double normalizedSample = sample16bit / 32768.0;
      samples.add(normalizedSample);

      if (samples.length >= REQUIRED_SAMPLES) {
        break;
      }
    }

    int samplesToRemove = math.min(_audioBuffer.length, REQUIRED_SAMPLES);
    _audioBuffer.removeRange(0, samplesToRemove);

    return samples.length >= REQUIRED_SAMPLES ? samples : null;
  }

  void clearAudioBuffer() {
    _audioBuffer.clear();
    print('AudioService: Buffer limpo');
  }

  int get bufferSize => _audioBuffer.length;

  void dispose() {
    print('AudioService: Fazendo dispose...');
    _recorder?.closeRecorder();
    _audioPlayer?.dispose();
    _player?.closePlayer();
    _audioStreamController?.close();
    _audioBuffer.clear();
    _isInitialized = false;
    _isRecording = false;
  }
}

// Enhanced Pitch Detection Service
class EnhancedPitchDetectionService {
  static final EnhancedPitchDetectionService _instance =
  EnhancedPitchDetectionService._internal();
  factory EnhancedPitchDetectionService() => _instance;
  EnhancedPitchDetectionService._internal();

  List<String?> _recentDetections = [];
  final int _bufferSize = 3;

  String? detectPitch(List<double> audioData, {double sampleRate = 22050}) {
    if (audioData.length < 512) {
      return null;
    }

    double energy = _calculateEnergy(audioData);
    if (energy < 0.001) {
      return null;
    }

    List<double> filteredData = _highPassFilter(audioData);
    double? frequency = _detectFrequencyYIN(filteredData, sampleRate);

    if (frequency == null || frequency < 80 || frequency > 2000) {
      return null;
    }

    String? pitch = _frequencyToPitch(frequency);
    return _smoothDetection(pitch);
  }

  double _calculateEnergy(List<double> samples) {
    double sum = 0.0;
    for (double sample in samples) {
      sum += sample * sample;
    }
    return sum / samples.length;
  }

  List<double> _highPassFilter(List<double> input) {
    List<double> output = List.from(input);
    double alpha = 0.95;

    for (int i = 1; i < output.length; i++) {
      output[i] = alpha * (output[i-1] + input[i] - input[i-1]);
    }

    return output;
  }

  double? _detectFrequencyYIN(List<double> buffer, double sampleRate) {
    int bufferSize = math.min(buffer.length, 2048);
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

    double threshold = 0.15;
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

    if (tau >= yinBuffer.length || yinBuffer[tau] >= threshold) {
      return null;
    }

    double betterTau = tau.toDouble();
    if (tau > 0 && tau < yinBuffer.length - 1) {
      double s0 = yinBuffer[tau - 1];
      double s1 = yinBuffer[tau];
      double s2 = yinBuffer[tau + 1];
      if ((2 * s1 - s2 - s0) != 0) {
        betterTau = tau + (s2 - s0) / (2 * (2 * s1 - s2 - s0));
      }
    }

    return sampleRate / betterTau;
  }

  String? _frequencyToPitch(double frequency) {
    double a4 = 440.0;
    double c0 = a4 * pow(2, -4.75);

    if (frequency <= 0) return null;

    double halfSteps = 12 * (log(frequency / c0) / ln2);
    int roundedHalfSteps = halfSteps.round();

    List<String> noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'Bb', 'B'];

    int octave = roundedHalfSteps ~/ 12;
    int noteIndex = roundedHalfSteps % 12;

    if (noteIndex < 0) {
      noteIndex += 12;
      octave -= 1;
    }

    if (octave < 0 || octave > 8) return null;

    return '${noteNames[noteIndex]}$octave';
  }

  String? _smoothDetection(String? currentPitch) {
    _recentDetections.add(currentPitch);

    if (_recentDetections.length > _bufferSize) {
      _recentDetections.removeAt(0);
    }

    Map<String?, int> counts = {};
    for (String? pitch in _recentDetections) {
      counts[pitch] = (counts[pitch] ?? 0) + 1;
    }

    String? mostCommon;
    int maxCount = 0;

    counts.forEach((pitch, count) {
      if (pitch != null && count > maxCount) {
        mostCommon = pitch;
        maxCount = count;
      }
    });

    return maxCount >= (_bufferSize * 0.4) ? mostCommon : null;
  }

  void reset() {
    _recentDetections.clear();
  }
}