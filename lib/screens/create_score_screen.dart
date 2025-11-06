import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/score_model.dart';
import '../models/note_model.dart';
import '../widgets/score_display.dart';
import '../services/database_service.dart';

class CreateScoreScreen extends StatefulWidget {
  final ScoreModel? scoreToEdit;

  const CreateScoreScreen({
    Key? key,
    this.scoreToEdit,
  }) : super(key: key);

  @override
  _CreateScoreScreenState createState() => _CreateScoreScreenState();
}

class _CreateScoreScreenState extends State<CreateScoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bpmController = TextEditingController(text: '120');

  String _timeSignature = '4/4';
  String _keySignature = 'C';
  List<NoteModel> _notes = [];

  late Box<ScoreModel> _scoresBox;

  bool get isEditing => widget.scoreToEdit != null;

  @override
  void initState() {
    super.initState();
    _loadScoreData();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      _scoresBox = Hive.box<ScoreModel>('scores');
    } catch (e) {
      _scoresBox = await Hive.openBox<ScoreModel>('scores');
    }
  }

  void _loadScoreData() {
    if (widget.scoreToEdit != null) {
      final score = widget.scoreToEdit!;

      print('   DEBUG - Carregando partitura para edição:');
      print('   ID: ${score.id}');
      print('   Título: ${score.title}');
      print('   BPM: ${score.bpm}');
      print('   Notas: ${score.notes.length}');

      _titleController.text = score.title;
      _bpmController.text = score.bpm.toString();
      _timeSignature = score.timeSignature;
      _keySignature = score.keySignature;
      _notes = List.from(score.notes);

      print('Dados carregados com sucesso!');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bpmController.dispose();
    super.dispose();
  }

  List<MusicalNote> _convertToMusicalNotes() {
    return _notes.map((note) {
      if (note.isRest) {
        return MusicalNote.rest(duration: note.duration);
      }
      return MusicalNote(
        note: '${note.pitch}${note.octave}',
        duration: note.duration,
        displayName: note.displayName,
        position: note.position,
      );
    }).toList();
  }

  void _addNote() {
    showDialog(
      context: context,
      builder: (context) => _NoteDialog(
        onNoteAdded: (note) {
          setState(() {
            _notes.add(note);
            _notes.sort((a, b) => a.startTime.compareTo(b.startTime));
          });
        },
        nextStartTime: _notes.isEmpty ? 0.0 : _notes.last.startTime + _notes.last.duration,
      ),
    );
  }

  void _editNote(int index) {
    final note = _notes[index];
    showDialog(
      context: context,
      builder: (context) => _NoteDialog(
        onNoteAdded: (editedNote) {
          setState(() {
            _notes[index] = editedNote;
            _notes.sort((a, b) => a.startTime.compareTo(b.startTime));
          });
        },
        nextStartTime: note.startTime,
        initialNote: note,
      ),
    );
  }

  void _saveScore() async {
    if (_formKey.currentState!.validate()) {
      if (_notes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adicione pelo menos uma nota à partitura'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final currentUser = DatabaseService().getCurrentUser();
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Usuário não está logado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScoreModel score;

      if (isEditing) {
        score = ScoreModel(
          id: widget.scoreToEdit!.id,
          title: _titleController.text,
          bpm: int.parse(_bpmController.text),
          timeSignature: _timeSignature,
          keySignature: _keySignature,
          notes: _notes,
          userId: widget.scoreToEdit!.userId,
          createdAt: widget.scoreToEdit!.createdAt,
          updatedAt: DateTime.now(),
          category: widget.scoreToEdit!.category,
          description: widget.scoreToEdit!.description,
          difficulty: widget.scoreToEdit!.difficulty,
        );
        print('Atualizando partitura ID: ${score.id}');
      } else {
        score = ScoreModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          bpm: int.parse(_bpmController.text),
          timeSignature: _timeSignature,
          keySignature: _keySignature,
          notes: _notes,
          userId: currentUser.id,
          createdAt: DateTime.now(),
          category: 'Criação Própria',
        );
        print('Criando nova partitura ID: ${score.id}');
      }

      await _scoresBox.put(score.id, score);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isEditing
                    ? 'Partitura atualizada com sucesso!'
                    : 'Partitura salva com sucesso!'
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detecta tamanho da tela
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isLandscape = size.width > size.height;
    final useTwoColumns = isLandscape && size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Partitura' : 'Criar Partitura',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveScore,
            tooltip: isEditing ? 'Atualizar Partitura' : 'Salvar Partitura',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: useTwoColumns
              ? _buildLandscapeLayout(isSmallScreen)
              : _buildPortraitLayout(isSmallScreen),
        ),
      ),
    );
  }

  // Layout vertical (modo retrato)
  Widget _buildPortraitLayout(bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informações da Partitura
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações da Partitura',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título da Partitura',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.music_note),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite um título';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    _buildConfigFields(isSmallScreen),
                  ],
                ),
              ),
            ),
          ),

          // Header da lista de notas
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12.0 : 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Partitura (${_notes.length} notas)',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                ElevatedButton.icon(
                  onPressed: _addNote,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    isSmallScreen ? 'Nota' : 'Adicionar Nota',
                    style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isSmallScreen ? 8 : 12),

          // Visualização e lista de notas
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12.0 : 16.0,
            ),
            child: _notes.isEmpty
                ? _buildEmptyState(isSmallScreen)
                : _buildNotesContent(isSmallScreen),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),
        ],
      ),
    );
  }

  // Layout horizontal (modo paisagem para telas pequenas)
  Widget _buildLandscapeLayout(bool isSmallScreen) {
    return Row(
      children: [
        // Coluna esquerda: Formulário
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informações',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.music_note),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite um título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildConfigFields(true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_notes.length} notas',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addNote,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Nota', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildNotesList(true),
              ],
            ),
          ),
        ),

        // Coluna direita: Partitura
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _notes.isEmpty
                ? _buildEmptyState(true)
                : Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ScoreDisplayWidget(
                  notes: _convertToMusicalNotes(),
                  currentNoteIndex: -1,
                  title: _titleController.text.isEmpty
                      ? 'Nova Partitura'
                      : _titleController.text,
                  keySignature: _keySignature,
                  timeSignature: _timeSignature,
                  tempo: int.tryParse(_bpmController.text),
                  isListening: false,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Campos de configuração (BPM, Compasso, Tom)
  Widget _buildConfigFields(bool isSmallScreen) {
    return isSmallScreen
        ? Column(
      children: [
        TextFormField(
          controller: _bpmController,
          decoration: const InputDecoration(
            labelText: 'BPM',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.speed),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Digite o BPM';
            }
            final bpm = int.tryParse(value);
            if (bpm == null) {
              return 'Número inválido';
            }
            if (bpm < 40 || bpm > 240) {
              return 'BPM entre 40-240';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _timeSignature,
                decoration: const InputDecoration(
                  labelText: 'Compasso',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                  isDense: true,
                ),
                items: ['4/4', '3/4', '2/4', '6/8']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _timeSignature = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _keySignature,
                decoration: const InputDecoration(
                  labelText: 'Tom',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                  isDense: true,
                ),
                items: ['C', 'F', 'Bb', 'Eb', 'Ab', 'G', 'D', 'A', 'E']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _keySignature = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    )
        : Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _bpmController,
            decoration: const InputDecoration(
              labelText: 'BPM',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.speed),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Digite o BPM';
              }
              final bpm = int.tryParse(value);
              if (bpm == null) {
                return 'Número inválido';
              }
              if (bpm < 40 || bpm > 240) {
                return 'BPM entre 40-240';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _timeSignature,
            decoration: const InputDecoration(
              labelText: 'Compasso',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timer),
              isDense: true,
            ),
            items: ['4/4', '3/4', '2/4', '6/8']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _timeSignature = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _keySignature,
            decoration: const InputDecoration(
              labelText: 'Tom',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.key),
              isDense: true,
            ),
            items: ['C', 'F', 'Bb', 'Eb', 'Ab', 'G', 'D', 'A', 'E']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _keySignature = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  // Estado vazio
  Widget _buildEmptyState(bool isSmallScreen) {
    return SizedBox(
      height: isSmallScreen ? 200 : 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_music,
              size: isSmallScreen ? 60 : 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Nenhuma nota adicionada',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'Toque em "Adicionar Nota" para começar',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Conteúdo com notas (partitura + lista)
  Widget _buildNotesContent(bool isSmallScreen) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: ScoreDisplayWidget(
              notes: _convertToMusicalNotes(),
              currentNoteIndex: -1,
              title: _titleController.text.isEmpty
                  ? 'Nova Partitura'
                  : _titleController.text,
              keySignature: _keySignature,
              timeSignature: _timeSignature,
              tempo: int.tryParse(_bpmController.text),
              isListening: false,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Expanded(
            flex: 2,
            child: _buildNotesList(isSmallScreen),
          ),
        ],
      ),
    );
  }

  // Lista de notas
  Widget _buildNotesList(bool isSmallScreen) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
            child: Row(
              children: [
                Icon(
                  Icons.list,
                  color: Colors.indigo.shade600,
                  size: isSmallScreen ? 18 : 20,
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  'Sequência de Notas',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8.0 : 16.0,
                    vertical: isSmallScreen ? 2.0 : 4.0,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    radius: isSmallScreen ? 14 : 16,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                    ),
                  ),
                  title: Text(
                    note.displayName ?? '${note.pitch}${note.octave}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  subtitle: Text(
                    '${_getDurationName(note.duration)} • ${note.startTime.toStringAsFixed(1)}s${note.position != null ? ' • Pos: ${note.position}' : ''}',
                    style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        color: Colors.blue,
                        onPressed: () => _editNote(index),
                        tooltip: 'Editar',
                        padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            _notes.removeAt(index);
                          });
                        },
                        tooltip: 'Excluir',
                        padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getDurationName(double duration) {
    if (duration == 0.25) return 'Semicolcheia';
    if (duration == 0.5) return 'Colcheia';
    if (duration == 1.0) return 'Semínima';
    if (duration == 2.0) return 'Mínima';
    if (duration == 4.0) return 'Semibreve';
    return '${duration.toStringAsFixed(2)} beats';
  }
}

class _NoteDialog extends StatefulWidget {
  final Function(NoteModel) onNoteAdded;
  final double nextStartTime;
  final NoteModel? initialNote;

  const _NoteDialog({
    required this.onNoteAdded,
    required this.nextStartTime,
    this.initialNote,
  });

  @override
  _NoteDialogState createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late String _pitch;
  late int _octave;
  late double _duration;
  late double _startTime;
  String? _displayName;
  String? _position;

  final Map<String, String> _noteNames = {
    'C': 'Dó',
    'C#': 'Dó♯',
    'D': 'Ré',
    'D#': 'Ré♯',
    'E': 'Mi',
    'F': 'Fá',
    'F#': 'Fá♯',
    'G': 'Sol',
    'G#': 'Sol♯',
    'A': 'Lá',
    'A#': 'Lá♯',
    'B': 'Si',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialNote != null) {
      _pitch = widget.initialNote!.pitch;
      _octave = widget.initialNote!.octave;
      _duration = widget.initialNote!.duration;
      _startTime = widget.initialNote!.startTime;
      _displayName = widget.initialNote!.displayName;
      _position = widget.initialNote!.position;
    } else {
      _pitch = 'C';
      _octave = 3;
      _duration = 1.0;
      _startTime = widget.nextStartTime;
      _displayName = _noteNames['C'];
      _position = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 1400;

    return AlertDialog(
      title: Text(
        widget.initialNote != null ? 'Editar Nota' : 'Adicionar Nota',
        style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _pitch,
              decoration: const InputDecoration(
                labelText: 'Nota',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('$value (${_noteNames[value]})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _pitch = value!;
                  _displayName = _noteNames[value];
                });
              },
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            DropdownButtonFormField<int>(
              value: _octave,
              decoration: const InputDecoration(
                labelText: 'Oitava',
                border: OutlineInputBorder(),
                helperText: 'Trombone: geralmente 2-4',
                isDense: true,
              ),
              items: [2, 3, 4, 5].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _octave = value!;
                });
              },
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            DropdownButtonFormField<double>(
              value: _duration,
              decoration: const InputDecoration(
                labelText: 'Duração',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [0.25, 0.5, 1.0, 2.0, 4.0].map((double value) {
                String label = value == 0.25
                    ? 'Semicolcheia (♬)'
                    : value == 0.5
                    ? 'Colcheia (♪)'
                    : value == 1.0
                    ? 'Semínima (♩)'
                    : value == 2.0
                    ? 'Mínima (𝅗𝅥)'
                    : 'Semibreve (𝅝)';
                return DropdownMenuItem<double>(
                  value: value,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _duration = value!;
                });
              },
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            TextFormField(
              initialValue: _position,
              decoration: const InputDecoration(
                labelText: 'Posição do Trombone (opcional)',
                border: OutlineInputBorder(),
                helperText: 'Ex: 1°, 2°, 3°, etc.',
                isDense: true,
              ),
              onChanged: (value) {
                _position = value.isEmpty ? null : value;
              },
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            TextFormField(
              initialValue: _startTime.toStringAsFixed(1),
              decoration: const InputDecoration(
                labelText: 'Tempo de Início (segundos)',
                border: OutlineInputBorder(),
                helperText: 'Quando a nota deve começar a tocar',
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null) {
                  _startTime = parsed;
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancelar',
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final note = NoteModel(
              pitch: _pitch,
              octave: _octave,
              duration: _duration,
              startTime: _startTime,
              displayName: _displayName,
              position: _position,
            );
            widget.onNoteAdded(note);
            Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
          ),
          child: Text(
            widget.initialNote != null ? 'Salvar' : 'Adicionar',
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
          ),
        ),
      ],
    );
  }
}