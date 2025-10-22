// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreModelAdapter extends TypeAdapter<ScoreModel> {
  @override
  final int typeId = 5;

  @override
  ScoreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreModel(
      id: fields[0] as String,
      title: fields[1] as String,
      bpm: fields[2] as int,
      timeSignature: fields[3] as String,
      keySignature: fields[4] as String,
      notes: (fields[5] as List).cast<NoteModel>(),
      createdAt: fields[6] as DateTime,
      userId: fields[7] as String,
      updatedAt: fields[8] as DateTime?,
      description: fields[9] as String?,
      category: fields[10] as String?,
      difficulty: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ScoreModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.bpm)
      ..writeByte(3)
      ..write(obj.timeSignature)
      ..writeByte(4)
      ..write(obj.keySignature)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.userId)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.category)
      ..writeByte(11)
      ..write(obj.difficulty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
