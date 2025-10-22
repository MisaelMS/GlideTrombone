import 'package:hive/hive.dart';
import 'note_model.dart';

part 'score_model.g.dart';

@HiveType(typeId: 5)
class ScoreModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int bpm;

  @HiveField(3)
  String timeSignature;

  @HiveField(4)
  String keySignature;

  @HiveField(5)
  List<NoteModel> notes;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String userId;

  @HiveField(8)
  DateTime? updatedAt;

  @HiveField(9)
  String? description;

  @HiveField(10)
  String? category;

  @HiveField(11)
  int? difficulty;

  ScoreModel({
    required this.id,
    required this.title,
    required this.bpm,
    required this.timeSignature,
    required this.keySignature,
    required this.notes,
    required this.createdAt,
    required this.userId,
    this.updatedAt,
    this.description,
    this.category,
    this.difficulty,
  });

  factory ScoreModel.create({
    required String title,
    required int bpm,
    required String timeSignature,
    required String keySignature,
    required List<NoteModel> notes,
    required String userId,
    String? description,
    String? category,
    int? difficulty,
  }) {
    return ScoreModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      bpm: bpm,
      timeSignature: timeSignature,
      keySignature: keySignature,
      notes: notes,
      userId: userId,
      createdAt: DateTime.now(),
      description: description,
      category: category,
      difficulty: difficulty,
    );
  }

  double get totalDurationBeats {
    return notes.fold(0.0, (sum, note) => sum + note.duration);
  }

  int get measureCount {
    final beatsPerMeasure = _getBeatsPerMeasure();
    return (totalDurationBeats / beatsPerMeasure).ceil();
  }

  double _getBeatsPerMeasure() {
    final parts = timeSignature.split('/');
    if (parts.length == 2) {
      return double.tryParse(parts[0]) ?? 4.0;
    }
    return 4.0;
  }

  int get noteCount {
    return notes.where((note) => !note.isRest).length;
  }

  bool get isEmpty => notes.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'bpm': bpm,
      'timeSignature': timeSignature,
      'keySignature': keySignature,
      'notes': notes.map((note) => note.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'updatedAt': updatedAt?.toIso8601String(),
      'description': description,
      'category': category,
      'difficulty': difficulty,
    };
  }
}