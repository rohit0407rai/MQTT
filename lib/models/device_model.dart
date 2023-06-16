import 'dart:io';

class DeviceModel {
  String id;
  String name;
  DeviceModel({required this.id, required this.name});

  factory DeviceModel.fromDocument(Map<String, dynamic> doc) {
    return DeviceModel(
      id: doc['id'],
      name: doc['name'],
    );
  }

  Map<String, dynamic> toMap() {
    final doc = <String, dynamic>{};
    doc['id'] = id;
    doc['name'] = name;
    return doc;
  }
}