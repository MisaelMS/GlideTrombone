// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 2;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      pitch: fields[0] as String,
      octave: fields[1] as int,
      duration: fields[2] as double,
      startTime: fields[3] as double,
      displayName: fields[4] as String?,
      position: fields[5] as String?,
      isRest: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.pitch)
      ..writeByte(1)
      ..write(obj.octave)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.displayName)
      ..writeByte(5)
      ..write(obj.position)
      ..writeByte(6)
      ..write(obj.isRest);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
