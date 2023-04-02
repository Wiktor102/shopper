// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lists_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskObjectAdapter extends TypeAdapter<TaskObject> {
  @override
  final int typeId = 1;

  @override
  TaskObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskObject(
      fields[0] as String,
      fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskObject obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.item)
      ..writeByte(1)
      ..write(obj.checked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroceryListAdapter extends TypeAdapter<GroceryList> {
  @override
  final int typeId = 2;

  @override
  GroceryList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroceryList(
      fields[0] as String,
      (fields[1] as List).cast<TaskObject>().toSet(),
    );
  }

  @override
  void write(BinaryWriter writer, GroceryList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.items.toList());
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroceryListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
