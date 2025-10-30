// lib/data/exercises/scales.dart
import '../../widgets/score_display.dart';
import '../../models/exercise.dart';

class ScalesLibrary {
  // ========== ESCALAS MAIORES ==========

  static final Exercise scaleCMajor = Exercise(
    id: '1000000000001', // ID fixo impossível de gerar naturalmente
    name: 'Escala de C Maior',
    keySignature: 'C', // Sem acidentes
    tempo: 100,
    notes: [
      MusicalNote(note: 'C3', displayName: 'Dó', position: '6°'),
      MusicalNote(note: 'D3', displayName: 'Ré', position: '4°'),
      MusicalNote(note: 'E3', displayName: 'Mi', position: '2°'),
      MusicalNote(note: 'F3', displayName: 'Fá', position: '1°'),
      MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
      MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
      MusicalNote(note: 'B3', displayName: 'Si', position: '1°'),
      MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
    ],
  );

  static final List<Exercise> scalesMajorFlats = [
    Exercise(
      id: '1000000000002', // ID fixo impossível de gerar naturalmente
      name: 'Escala de Teste',
      keySignature: 'F', // 1 bemol (Bb)
      tempo: 120,
      notes: [
        MusicalNote(note: 'A2', displayName: 'La', position: '2°'),
        MusicalNote(note: 'Bb2', displayName: 'Sib', position: '1°'),
        MusicalNote(note: 'C3', displayName: 'Dó', position: '6°'),
        MusicalNote(note: 'D3', displayName: 'Ré', position: '4°'),
        MusicalNote(note: 'E3', displayName: 'Mi', position: '2°'),
        MusicalNote(note: 'F3', displayName: 'Fá', position: '1°'),
        MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
        MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
        MusicalNote(note: 'Bb3', displayName: 'Sib', position: '1°'),
        MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
        MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
        MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
        MusicalNote(note: 'Bb3', displayName: 'Sib', position: '1°'),
        MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
        MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
        MusicalNote(note: 'F3', displayName: 'Fá', position: '1°'),
        MusicalNote(note: 'E3', displayName: 'Mi', position: '2°'),
        MusicalNote(note: 'D3', displayName: 'Ré', position: '4°'),
      ],
    ),

    Exercise(
      id: '1000000000003', // ID fixo impossível de gerar naturalmente
      name: 'Escala de Eb Maior',
      keySignature: 'Eb', // 3 bemóis (Bb, Eb, Ab)
      tempo: 120,
      notes: [
        MusicalNote(note: 'Eb3', displayName: 'Mi♭', position: '3°'),
        MusicalNote(note: 'F3', displayName: 'Fá', position: '1°'),
        MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
        MusicalNote(note: 'Ab3', displayName: 'Lá♭', position: '3°'),
        MusicalNote(note: 'Bb3', displayName: 'Si♭', position: '1°'),
        MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
        MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
        MusicalNote(note: 'Eb4', displayName: 'Mi♭', position: '3°'),
      ],
    ),
  ];

  // ========== ESCALAS MENORES NATURAIS ==========

  static final List<Exercise> scalesMinorFlats = [
    Exercise(
      id: '1000000000004', // ID fixo impossível de gerar naturalmente
      name: 'Escala de C menor (natural)',
      keySignature: 'Eb', // 3 bemóis (Bb, Eb, Ab)
      tempo: 100,
      notes: [
        MusicalNote(note: 'C3', displayName: 'Dó', position: '6°'),
        MusicalNote(note: 'D3', displayName: 'Ré', position: '4°'),
        MusicalNote(note: 'Eb3', displayName: 'Mi♭', position: '3°'),
        MusicalNote(note: 'F3', displayName: 'Fá', position: '1°'),
        MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
        MusicalNote(note: 'Ab3', displayName: 'Lá♭', position: '3°'),
        MusicalNote(note: 'Bb3', displayName: 'Si♭', position: '1°'),
        MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
      ],
    ),
  ];

  static final List<Exercise> scalesMinorSharps = [
    Exercise(
      id: '1000000000005', // ID fixo impossível de gerar naturalmente
      name: 'Escala de C# menor (natural)',
      keySignature: 'E', // 4 sustenidos (F#, C#, G#, D#)
      tempo: 100,
      notes: [
        MusicalNote(note: 'C#3', displayName: 'Dó♯', position: '5°'),
        MusicalNote(note: 'D#3', displayName: 'Ré♯', position: '3°'),
        MusicalNote(note: 'E3', displayName: 'Mi', position: '2°'),
        MusicalNote(note: 'F#3', displayName: 'Fá♯', position: '5°'),
        MusicalNote(note: 'G#3', displayName: 'Sol♯', position: '3°'),
        MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
        MusicalNote(note: 'B3', displayName: 'Si', position: '1°'),
        MusicalNote(note: 'C#4', displayName: 'Dó♯', position: '5°'),
      ],
    ),
  ];

  // ========== MÉTODOS DE ACESSO ==========

  /// Retorna todas as escalas maiores
  static List<Exercise> getAllMajorScales() {
    return [
      scaleCMajor,
      ...scalesMajorFlats,
    ];
  }

  /// Retorna todas as escalas menores
  static List<Exercise> getAllMinorScales() {
    return [
      ...scalesMinorFlats,
      ...scalesMinorSharps,
    ];
  }

  /// Retorna todas as escalas
  static List<Exercise> getAllScales() {
    return [
      ...getAllMajorScales(),
      ...getAllMinorScales(),
    ];
  }

  /// Retorna escalas organizadas por categoria
  static Map<String, List<Exercise>> getScalesByCategory() {
    return {
      'Maiores (C e bemóis)': [scaleCMajor, ...scalesMajorFlats],
      'Menores (C e C#)': [...scalesMinorFlats, ...scalesMinorSharps],
    };
  }
}