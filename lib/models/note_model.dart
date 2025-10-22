import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 2)
class NoteModel extends HiveObject {
  @HiveField(0)
  String pitch;

  @HiveField(1)
  int octave;

  @HiveField(2)
  double duration;

  @HiveField(3)
  double startTime;

  @HiveField(4)
  String? displayName;

  @HiveField(5)
  String? position;

  @HiveField(6)
  bool isRest;

  NoteModel({
    required this.pitch,
    required this.octave,
    required this.duration,
    required this.startTime,
    this.displayName,
    this.position,
    this.isRest = false,
  });

  factory NoteModel.rest({
    required double duration,
    required double startTime,
  }) {
    return NoteModel(
      pitch: '',
      octave: 0,
      duration: duration,
      startTime: startTime,
      isRest: true,
    );
  }

  factory NoteModel.fromFullNote({
    required String fullNote,
    required double duration,
    required double startTime,
    String? displayName,
    String? position,
  }) {
    String pitch;
    int octave;

    if (fullNote.length == 2) {
      pitch = fullNote[0];
      octave = int.parse(fullNote[1]);
    } else if (fullNote.length == 3) {
      pitch = fullNote.substring(0, 2);
      octave = int.parse(fullNote[2]);
    } else {
      throw ArgumentError('Formato de nota inválido: $fullNote');
    }

    return NoteModel(
      pitch: pitch,
      octave: octave,
      duration: duration,
      startTime: startTime,
      displayName: displayName,
      position: position,
    );
  }

  String get fullNote => '$pitch$octave';
  String get name => displayName ?? fullNote;

  NoteModel copyWith({
    String? pitch,
    int? octave,
    double? duration,
    double? startTime,
    String? displayName,
    String? position,
    bool? isRest,
  }) {
    return NoteModel(
      pitch: pitch ?? this.pitch,
      octave: octave ?? this.octave,
      duration: duration ?? this.duration,
      startTime: startTime ?? this.startTime,
      displayName: displayName ?? this.displayName,
      position: position ?? this.position,
      isRest: isRest ?? this.isRest,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pitch': pitch,
      'octave': octave,
      'duration': duration,
      'startTime': startTime,
      'displayName': displayName,
      'position': position,
      'isRest': isRest,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      pitch: map['pitch'] as String,
      octave: map['octave'] as int,
      duration: map['duration'] as double,
      startTime: map['startTime'] as double,
      displayName: map['displayName'] as String?,
      position: map['position'] as String?,
      isRest: map['isRest'] as bool? ?? false,
    );
  }
}