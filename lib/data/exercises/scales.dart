// lib/data/exercises/scales.dart
import '../../widgets/score_display.dart';
import '../../models/exercise.dart';

class ScalesLibrary {
  // ========== ESCALAS MAIORES ==========

  static final Exercise scaleCMajor = Exercise(
    id: 'scale_c_major',
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
      id: 'scale_test',
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
    // Exercise(
    //   name: 'Escala de F Maior',
    //   keySignature: 'F', // 1 bemol (Bb)
    //   tempo: 120,
    //   notes: [
    //     MusicalNote(note: 'F3', displayName: 'Fá', position: '1°'),
    //     MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
    //     MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
    //     MusicalNote(note: 'Bb3', displayName: 'Si♭', position: '1°'),
    //     MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
    //     MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
    //     MusicalNote(note: 'E4', displayName: 'Mi', position: '2°'),
    //     MusicalNote(note: 'F4', displayName: 'Fá', position: '1°'),
    //   ],
    // ),

    // Exercise(
    //   name: 'Escala de Bb Maior',
    //   keySignature: 'Bb', // 2 bemóis (Bb, Eb)
    //   tempo: 120,
    //   notes: [
    //     MusicalNote(note: 'Bb3', displayName: 'Si♭', position: '1°'),
    //     MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
    //     MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
    //     MusicalNote(note: 'Eb4', displayName: 'Mi♭', position: '3°'),
    //     MusicalNote(note: 'F4', displayName: 'Fá', position: '1°'),
    //     MusicalNote(note: 'G4', displayName: 'Sol', position: '4°'),
    //     MusicalNote(note: 'A4', displayName: 'Lá', position: '2°'),
    //     MusicalNote(note: 'Bb4', displayName: 'Si♭', position: '1°'),
    //   ],
    // ),

    Exercise(
      id: 'scale_eb_major',
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

    // Exercise(
    //   name: 'Escala de Ab Maior',
    //   keySignature: 'Ab', // 4 bemóis (Bb, Eb, Ab, Db)
    //   tempo: 120,
    //   notes: [
    //     MusicalNote(note: 'Ab3', displayName: 'Lá♭', position: '3°'),
    //     MusicalNote(note: 'Bb3', displayName: 'Si♭', position: '1°'),
    //     MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
    //     MusicalNote(note: 'Db4', displayName: 'Ré♭', position: '5°'),
    //     MusicalNote(note: 'Eb4', displayName: 'Mi♭', position: '3°'),
    //     MusicalNote(note: 'F4', displayName: 'Fá', position: '1°'),
    //     MusicalNote(note: 'G4', displayName: 'Sol', position: '4°'),
    //     MusicalNote(note: 'Ab4', displayName: 'Lá♭', position: '3°'),
    //   ],
    // ),
  ];

  // static final List<Exercise> scalesMajorSharps = [
  //   Exercise(
  //     name: 'Escala de G Maior',
  //     keySignature: 'G', // 1 sustenido (F#)
  //     tempo: 120,
  //     notes: [
  //       MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
  //       MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
  //       MusicalNote(note: 'B3', displayName: 'Si', position: '1°'),
  //       MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
  //       MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
  //       MusicalNote(note: 'E4', displayName: 'Mi', position: '2°'),
  //       MusicalNote(note: 'F#4', displayName: 'Fá♯', position: '5°'),
  //       MusicalNote(note: 'G4', displayName: 'Sol', position: '4°'),
  //     ],
  //   ),
  //
  //   Exercise(
  //     name: 'Escala de D Maior',
  //     keySignature: 'D', // 2 sustenidos (F#, C#)
  //     tempo: 120,
  //     notes: [
  //       MusicalNote(note: 'D3', displayName: 'Ré', position: '4°'),
  //       MusicalNote(note: 'E3', displayName: 'Mi', position: '2°'),
  //       MusicalNote(note: 'F#3', displayName: 'Fá♯', position: '5°'),
  //       MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
  //       MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
  //       MusicalNote(note: 'B3', displayName: 'Si', position: '1°'),
  //       MusicalNote(note: 'C#4', displayName: 'Dó♯', position: '5°'),
  //       MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
  //     ],
  //   ),
  //
  //   Exercise(
  //     name: 'Escala de A Maior',
  //     keySignature: 'A', // 3 sustenidos (F#, C#, G#)
  //     tempo: 120,
  //     notes: [
  //       MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
  //       MusicalNote(note: 'B3', displayName: 'Si', position: '1°'),
  //       MusicalNote(note: 'C#4', displayName: 'Dó♯', position: '5°'),
  //       MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
  //       MusicalNote(note: 'E4', displayName: 'Mi', position: '2°'),
  //       MusicalNote(note: 'F#4', displayName: 'Fá♯', position: '5°'),
  //       MusicalNote(note: 'G#4', displayName: 'Sol♯', position: '3°'),
  //       MusicalNote(note: 'A4', displayName: 'Lá', position: '2°'),
  //     ],
  //   ),
  //
  //   Exercise(
  //     name: 'Escala de E Maior',
  //     keySignature: 'E', // 4 sustenidos (F#, C#, G#, D#)
  //     tempo: 120,
  //     notes: [
  //       MusicalNote(note: 'E3', displayName: 'Mi', position: '2°'),
  //       MusicalNote(note: 'F#3', displayName: 'Fá♯', position: '5°'),
  //       MusicalNote(note: 'G#3', displayName: 'Sol♯', position: '3°'),
  //       MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
  //       MusicalNote(note: 'B3', displayName: 'Si', position: '1°'),
  //       MusicalNote(note: 'C#4', displayName: 'Dó♯', position: '5°'),
  //       MusicalNote(note: 'D#4', displayName: 'Ré♯', position: '3°'),
  //       MusicalNote(note: 'E4', displayName: 'Mi', position: '2°'),
  //     ],
  //   ),
  // ];

  // ========== ESCALAS MENORES NATURAIS ==========

  // static final Exercise scaleAMinor = Exercise(
  //   name: 'Escala de A menor (natural)',
  //   keySignature: 'C', // Relativa de C Maior
  //   tempo: 100,
  //   notes: [
  //     MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
  //     MusicalNote(note: 'B3', displayName: 'Si', position: '1°'),
  //     MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
  //     MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
  //     MusicalNote(note: 'E4', displayName: 'Mi', position: '2°'),
  //     MusicalNote(note: 'F4', displayName: 'Fá', position: '1°'),
  //     MusicalNote(note: 'G4', displayName: 'Sol', position: '4°'),
  //     MusicalNote(note: 'A4', displayName: 'Lá', position: '2°'),
  //   ],
  // );

  static final List<Exercise> scalesMinorFlats = [
    // Exercise(
    //   name: 'Escala de D menor (natural)',
    //   keySignature: 'F', // 1 bemol (Bb)
    //   tempo: 100,
    //   notes: [
    //     MusicalNote(note: 'D3', displayName: 'Ré', position: '4°'),
    //     MusicalNote(note: 'E3', displayName: 'Mi', position: '2°'),
    //     MusicalNote(note: 'F3', displayName: 'Fá', position: '1°'),
    //     MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
    //     MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
    //     MusicalNote(note: 'Bb3', displayName: 'Si♭', position: '1°'),
    //     MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
    //     MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
    //   ],
    // ),

    // Exercise(
    //   name: 'Escala de G menor (natural)',
    //   keySignature: 'Bb', // 2 bemóis (Bb, Eb)
    //   tempo: 100,
    //   notes: [
    //     MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
    //     MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
    //     MusicalNote(note: 'Bb3', displayName: 'Si♭', position: '1°'),
    //     MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
    //     MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
    //     MusicalNote(note: 'Eb4', displayName: 'Mi♭', position: '3°'),
    //     MusicalNote(note: 'F4', displayName: 'Fá', position: '1°'),
    //     MusicalNote(note: 'G4', displayName: 'Sol', position: '4°'),
    //   ],
    // ),

    Exercise(
      id: 'scale_c_minor',
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

    // Exercise(
    //   name: 'Escala de F menor (natural)',
    //   keySignature: 'Ab', // 4 bemóis (Bb, Eb, Ab, Db)
    //   tempo: 100,
    //   notes: [
    //     MusicalNote(note: 'F3', displayName: 'Fá', position: '1°'),
    //     MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
    //     MusicalNote(note: 'Ab3', displayName: 'Lá♭', position: '3°'),
    //     MusicalNote(note: 'Bb3', displayName: 'Si♭', position: '1°'),
    //     MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
    //     MusicalNote(note: 'Db4', displayName: 'Ré♭', position: '5°'),
    //     MusicalNote(note: 'Eb4', displayName: 'Mi♭', position: '3°'),
    //     MusicalNote(note: 'F4', displayName: 'Fá', position: '1°'),
    //   ],
    // ),
  ];

  static final List<Exercise> scalesMinorSharps = [
    // Exercise(
    //   name: 'Escala de E menor (natural)',
    //   keySignature: 'G', // 1 sustenido (F#)
    //   tempo: 100,
    //   notes: [
    //     MusicalNote(note: 'E3', displayName: 'Mi', position: '2°'),
    //     MusicalNote(note: 'F#3', displayName: 'Fá♯', position: '5°'),
    //     MusicalNote(note: 'G3', displayName: 'Sol', position: '4°'),
    //     MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
    //     MusicalNote(note: 'B3', displayName: 'Si', position: '1°'),
    //     MusicalNote(note: 'C4', displayName: 'Dó', position: '6°'),
    //     MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
    //     MusicalNote(note: 'E4', displayName: 'Mi', position: '2°'),
    //   ],
    // ),

    // Exercise(
    //   name: 'Escala de B menor (natural)',
    //   keySignature: 'D', // 2 sustenidos (F#, C#)
    //   tempo: 100,
    //   notes: [
    //     MusicalNote(note: 'B3', displayName: 'Si', position: '1°'),
    //     MusicalNote(note: 'C#4', displayName: 'Dó♯', position: '5°'),
    //     MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
    //     MusicalNote(note: 'E4', displayName: 'Mi', position: '2°'),
    //     MusicalNote(note: 'F#4', displayName: 'Fá♯', position: '5°'),
    //     MusicalNote(note: 'G4', displayName: 'Sol', position: '4°'),
    //     MusicalNote(note: 'A4', displayName: 'Lá', position: '2°'),
    //     MusicalNote(note: 'B4', displayName: 'Si', position: '1°'),
    //   ],
    // ),

    // Exercise(
    //   name: 'Escala de F# menor (natural)',
    //   keySignature: 'A', // 3 sustenidos (F#, C#, G#)
    //   tempo: 100,
    //   notes: [
    //     MusicalNote(note: 'F#3', displayName: 'Fá♯', position: '5°'),
    //     MusicalNote(note: 'G#3', displayName: 'Sol♯', position: '3°'),
    //     MusicalNote(note: 'A3', displayName: 'Lá', position: '2°'),
    //     MusicalNote(note: 'B3', displayName: 'Si', position: '1°'),
    //     MusicalNote(note: 'C#4', displayName: 'Dó♯', position: '5°'),
    //     MusicalNote(note: 'D4', displayName: 'Ré', position: '4°'),
    //     MusicalNote(note: 'E4', displayName: 'Mi', position: '2°'),
    //     MusicalNote(note: 'F#4', displayName: 'Fá♯', position: '5°'),
    //   ],
    // ),

    Exercise(
      id: 'scale_csharp_minor',
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
      // ...scalesMajorSharps,
    ];
  }

  /// Retorna todas as escalas menores
  static List<Exercise> getAllMinorScales() {
    return [
      // scaleAMinor,
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
      // 'Maiores (sustenidos)': scalesMajorSharps,
      // 'Menores (A e bemóis)': [scaleAMinor, ...scalesMinorFlats],
      'Menores (sustenidos)': scalesMinorSharps,
    };
  }
}