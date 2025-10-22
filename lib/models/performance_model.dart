import 'package:hive/hive.dart';

part 'performance_model.g.dart';

@HiveType(typeId: 4)
class PerformanceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String scoreId;

  @HiveField(2)
  double accuracy;

  @HiveField(3)
  double timing;

  @HiveField(4)
  int totalScore;

  @HiveField(5)
  DateTime playedAt;

  @HiveField(6)
  List<PlayedNoteModel> playedNotes;

  @HiveField(7)
  String userId;

  PerformanceModel({
    required this.id,
    required this.scoreId,
    required this.accuracy,
    required this.timing,
    required this.totalScore,
    required this.playedAt,
    required this.playedNotes,
    required this.userId,
  });

  factory PerformanceModel.create({
    required String scoreId,
    required String userId,
    required double accuracy,
    required double timing,
    required int totalScore,
    required List<PlayedNoteModel> playedNotes,
  }) {
    return PerformanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scoreId: scoreId,
      userId: userId,
      accuracy: accuracy,
      timing: timing,
      totalScore: totalScore,
      playedAt: DateTime.now(),
      playedNotes: playedNotes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scoreId': scoreId,
      'userId': userId,
      'accuracy': accuracy,
      'timing': timing,
      'totalScore': totalScore,
      'playedAt': playedAt.toIso8601String(),
      'playedNotes': playedNotes.map((note) => note.toMap()).toList(),
    };
  }
}

@HiveType(typeId: 6)
class PlayedNoteModel extends HiveObject {
  @HiveField(0)
  String expectedPitch;

  @HiveField(1)
  String playedPitch;

  @HiveField(2)
  double expectedTime;

  @HiveField(3)
  double playedTime;

  @HiveField(4)
  bool isCorrect;

  PlayedNoteModel({
    required this.expectedPitch,
    required this.playedPitch,
    required this.expectedTime,
    required this.playedTime,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'expectedPitch': expectedPitch,
      'playedPitch': playedPitch,
      'expectedTime': expectedTime,
      'playedTime': playedTime,
      'isCorrect': isCorrect,
    };
  }
}