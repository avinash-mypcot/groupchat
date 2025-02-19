// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TextMessageModelAdapter extends TypeAdapter<TextMessageModel> {
  @override
  final int typeId = 0;

  @override
  TextMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TextMessageModel(
      messageId: fields[0] as String?,
      content: fields[1] as String?,
      senderId: fields[2] as String?,
      receiverName: fields[3] as String?,
      recipientId: fields[4] as String?,
      senderName: fields[5] as String?,
      time: fields[6] as DateTime?,
      type: fields[7] as String?,
      expiredAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TextMessageModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.messageId)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.receiverName)
      ..writeByte(4)
      ..write(obj.recipientId)
      ..writeByte(5)
      ..write(obj.senderName)
      ..writeByte(6)
      ..write(obj.time)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.expiredAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
