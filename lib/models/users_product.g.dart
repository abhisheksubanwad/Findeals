// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProductModelAdapter extends TypeAdapter<UserProductModel> {
  @override
  final int typeId = 1;

  @override
  UserProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProductModel(
      bankName: fields[0] as String,
      productType: fields[1] as String?,
      productId: fields[2] as String,
      isConfirmed: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserProductModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.bankName)
      ..writeByte(1)
      ..write(obj.productType)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.isConfirmed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
