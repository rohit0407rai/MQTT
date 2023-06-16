import 'dart:io';

class MQTTMessageModel {
  String? topic;
  String? message;
  MQTTMessageModel({this.topic, this.message});
}