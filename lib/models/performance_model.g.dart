// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PerformanceModelAdapter extends TypeAdapter<PerformanceModel> {
  @override
  final int typeId = 4;

  @override
  PerformanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PerformanceModel(
      id: fields[0] as String,
      scoreId: fields[1] as String,
      accuracy: fields[2] as double,
      timing: fields[3] as double,
      totalScore: fields[4] as int,
      playedAt: fields[5] as DateTime,
      playedNotes: (fields[6] as List).cast<PlayedNoteModel>(),
      userId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PerformanceModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.scoreId)
      ..writeByte(2)
      ..write(obj.accuracy)
      ..writeByte(3)
      ..write(obj.timing)
      ..writeByte(4)
      ..write(obj.totalScore)
      ..writeByte(5)
      ..write(obj.playedAt)
      ..writeByte(6)
      ..write(obj.playedNotes)
      ..writeByte(7)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerformanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayedNoteModelAdapter extends TypeAdapter<PlayedNoteModel> {
  @override
  final int typeId = 6;

  @override
  PlayedNoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayedNoteModel(
      expectedPitch: fields[0] as String,
      playedPitch: fields[1] as String,
      expectedTime: fields[2] as double,
      playedTime: fields[3] as double,
      isCorrect: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlayedNoteModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.expectedPitch)
      ..writeByte(1)
      ..write(obj.playedPitch)
      ..writeByte(2)
      ..write(obj.expectedTime)
      ..writeByte(3)
      ..write(obj.playedTime)
      ..writeByte(4)
      ..write(obj.isCorrect);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayedNoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
