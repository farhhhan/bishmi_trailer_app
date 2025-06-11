// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RestaurantAdapter extends TypeAdapter<Restaurant> {
  @override
  final int typeId = 0;

  @override
  Restaurant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Restaurant(
      date: fields[4] as String,
      name: fields[0] as String,
      mobile: fields[1] as String,
      category: fields[2] as String,
      employees: (fields[3] as List).cast<Employee>(),
    );
  }

  @override
  void write(BinaryWriter writer, Restaurant obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.mobile)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.employees);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmployeeAdapter extends TypeAdapter<Employee> {
  @override
  final int typeId = 1;

  @override
  Employee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Employee(
      feedBack: fields[4] as String,
      name: fields[0] as String,
      position: fields[1] as String,
      uniformConfig: (fields[2] as List).cast<UniformItemConfig>(),
      gender: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Employee obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.position)
      ..writeByte(2)
      ..write(obj.uniformConfig)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.feedBack);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UniformItemConfigAdapter extends TypeAdapter<UniformItemConfig> {
  @override
  final int typeId = 2;

  @override
  UniformItemConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UniformItemConfig(
      itemName: fields[0] as String,
      isNeeded: fields[1] as bool,
      isReadyMade: fields[2] as bool,
      selectedSize: fields[3] as String?,
      measurements: (fields[4] as Map).cast<String, String>(),
      sleeveType: fields[5] as String?,
      tshirtStyle: fields[6] as String?,
      materialType: fields[7] as String?,
      capStyle: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UniformItemConfig obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.itemName)
      ..writeByte(1)
      ..write(obj.isNeeded)
      ..writeByte(2)
      ..write(obj.isReadyMade)
      ..writeByte(3)
      ..write(obj.selectedSize)
      ..writeByte(4)
      ..write(obj.measurements)
      ..writeByte(5)
      ..write(obj.sleeveType)
      ..writeByte(6)
      ..write(obj.tshirtStyle)
      ..writeByte(7)
      ..write(obj.materialType)
      ..writeByte(8)
      ..write(obj.capStyle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniformItemConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
