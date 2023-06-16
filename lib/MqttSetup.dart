import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/index.dart';

String getRandomString(int length) {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890!@#%^&*()_-+<>?:;{[}]|';
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

MQTTConnection mqtt = MQTTConnection();

class MQTTConnection {
  static final String clientIdentifier = getRandomString(100);
  static final MQTTConnection mqtt = MQTTConnection._internal();
  //final client =
  //    MqttServerClient.withPort('broker.emqx.io', 'flutter_client', 1883);
  //final client =
  //   MqttServerClient.withPort('m1f57201.en.emqx.cloud', 'guna0027', 12254);
  //final client = MqttServerClient.withPort(
  //'soldier.cloudmqtt.com', clientIdentifier, 11489);
  final client =

  MqttServerClient.withPort('44.194.197.162', clientIdentifier, 11677);
  factory MQTTConnection() {
    return mqtt;
  }

  MQTTConnection._internal();
  final ObserverList<Function> _listeners = ObserverList<Function>();
  addListener(Function callback) {
    _listeners.add(callback);
  }

  removeListener(Function callback) {
    _listeners.remove(callback);
  }

  Future<void> reset() async {
    for (var element in _listeners) {
      _listeners.remove(element);
    }
  }

  Future<void> init() async {
    /*final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs('guna0027', '00270027')
        .withClientIdentifier('guna0027')
        .keepAliveFor(60) // Must agree with the keep alive set above or not set
        .withWillQos(MqttQos.atMostOnce);*/
    /*final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs('azfdstvd', 'iZX2nMwVLPWT')
        .withClientIdentifier(clientIdentifier)
        .keepAliveFor(60) // Must agree with the keep alive set above or not set
        .withWillQos(MqttQos.atMostOnce);*/
    print(clientIdentifier);
    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs('ztfplzdv', 'gUY-gVd0oQPI')
        .withClientIdentifier(clientIdentifier)
        .keepAliveFor(60) // Must agree with the keep alive set above or not set
        .withWillQos(MqttQos.atMostOnce);
    print('MQTT client connecting....');
    client.connectionMessage = connMess;
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.autoReconnect = true;
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('socket exception - $e');
      client.disconnect();
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      //onSubscribeToTopic();
    } else {
      print(
          'ERROR MQTT client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      MQTTMessageModel mqttMessageModel = MQTTMessageModel();
      final recMess = c[0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      mqttMessageModel.topic = c[0].topic;
      mqttMessageModel.message = pt.toString();
      //mqttMessageModel.topic = c[0].topic;
      //mqttMessageModel.payload = json.decode(pt);

      // print(pt);
      //List<dynamic> items =c[0].payload;
      //print(json.decode(pt));
      //List<String> data = [
      //  for (final item in recMess.payload.message.buffer.asUint8List()) item.toString()
      //];
      //print(data);
      // print(c[0].payload.header);
      // final payload =
      //    MqttPublishPayload.bytesToStringAsString(message.payload.message);
      for (var callback in _listeners) {
        callback(mqttMessageModel);
      }
    });
  }

  Future<void> onPublishMessageToTopic(
      String topic, List<String> messages) async {
    await MQTTConnection.mqtt.checkMQTTConnection();
    final builder = MqttClientPayloadBuilder();
    for (var i = 0; i < messages.length; i++) {
      builder.addString(messages[i]);
    }
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  Future<void> onSubscribeToTopic(String topic) async {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  Future<void> onUnSubscribeToTopic(String topic) async {
    client.unsubscribe(topic);
  }

  Future<void> checkMQTTConnection() async {
    print('MQTTConnection.mqtt.client.connectionStatus : ' +
        (client.connectionStatus!.returnCode ==
            MqttConnectReturnCode.connectionAccepted)
            .toString());
    if (client.connectionStatus!.returnCode ==
        MqttConnectReturnCode.connectionAccepted) {
    } else {
      try {
        await init();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String pDevice = prefs.getString('primaryDevice') ?? " ";
        await MQTTConnection.mqtt.onUnSubscribeToTopic("#");
        await MQTTConnection.mqtt.onSubscribeToTopic(pDevice);
      } catch (e) {
        print(e);
      }
    }
  }
}