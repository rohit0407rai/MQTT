import 'package:flutter/material.dart';
import './mqtt_connect.dart';

class MQTTViews extends StatefulWidget {
  @override
  _MQTTViewsState createState() => _MQTTViewsState();
}

class _MQTTViewsState extends State<MQTTViews> {
  TextEditingController _topic= TextEditingController();
  TextEditingController _message=TextEditingController();

  void _subscribeToTopic() async {
    await MQTTConnection.mqtt.onSubscribeToTopic(_topic.text);
  }

  void _publishMessage() async {
    await MQTTConnection.mqtt.onPublishMessageToTopic(_topic.text, [_message.text]);
  }
  void _connect() async{
    await MQTTConnection.mqtt.checkMQTTConnection();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Manager'),
      ),
      body: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Topic'),
            controller: _topic,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Message'),
            controller: _message,
          ),
          ElevatedButton(
            child: Text('Connect'),
            onPressed: _connect,
          ),
          ElevatedButton(
            child: Text('Subscribe'),
            onPressed: _subscribeToTopic,
          ),
          ElevatedButton(
            child: Text('Publish'),
            onPressed: _publishMessage,
          ),
        ],
      ),
    );
  }
}