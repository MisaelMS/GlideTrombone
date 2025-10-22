import '../widgets/score_display.dart';

class Exercise {
  final String? id;
  final String name;
  final List<MusicalNote> notes;
  final int tempo;
  final String keySignature;
  final String timeSignature;

  Exercise({
    required this.id,
    required this.name,
    required this.notes,
    required this.tempo,
    this.keySignature = 'C',
    this.timeSignature = '4/4',
  });
}