import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mqtt/Manager/MQTTManager.dart';
import 'package:mqtt/provider/MQTTAppState.dart';
import 'package:provider/provider.dart';

class MQTTView extends StatefulWidget {
  const MQTTView({super.key});

  @override
  State<MQTTView> createState() => _MQTTViewState();
}

class _MQTTViewState extends State<MQTTView> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  late MQTTAppState currentAppState;
  late MQTTManager manager;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _hostTextController.dispose();
    _messageTextController.dispose();
    _topicTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;
    var status = _messageShown(currentAppState.getMqttAppConnectionState);
    print(currentAppState.getHistoryText);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: Container(
                    color: status == "Connected" ? Colors.green : Colors.red,
                    child: Text(
                      status,
                      textAlign: TextAlign.center,
                    ),
                  ))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                  padding: EdgeInsets.all(22),
                  child: textfield(_hostTextController, 'Enter broker address',
                      currentAppState.getMqttAppConnectionState)),
              Padding(
                  padding: EdgeInsets.all(22),
                  child: textfield(_topicTextController, 'Enter topic',
                      currentAppState.getMqttAppConnectionState)),
              Padding(
                  padding: EdgeInsets.all(22),
                  child: textfield(_usernameTextController, 'Enter Username',
                      currentAppState.getMqttAppConnectionState)),
              Padding(
                  padding: EdgeInsets.all(22),
                  child: textfield(_passwordTextController, 'Enter Password',
                      currentAppState.getMqttAppConnectionState)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(22),
                          child: textfield(
                              _messageTextController,
                              'Enter message to Send',
                              currentAppState.getMqttAppConnectionState)),
                    ),
                    SendButton(currentAppState.getMqttAppConnectionState)
                  ],
                ),
              ),
              button(currentAppState.getMqttAppConnectionState),
              SizedBox(
                height: 10,
              ),
              _buildScrollableTextWith(currentAppState.getHistoryText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 400,
        height: 200,
        child: SingleChildScrollView(
          child: Text(text),
        ),
      ),
    );
  }

  Widget SendButton(MQTTAppConnectionState state) {
    return InkWell(
      child: Container(
        height: 40,
        width: 100,
        child: Center(child: const Text('Send')),
        color: Colors.blue,
      ),
      onTap: state == MQTTAppConnectionState.connected
          ? () {
              _publishMessage(_messageTextController.text);
            }
          : null,
    );
  }

  Widget button(
    MQTTAppConnectionState state,
  ) {
    return Row(
      children: [
        Expanded(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
            onPrimary: Colors.white,
          ),
          child: const Text('Connect'),
          onPressed: state == MQTTAppConnectionState.disconnected
              ? _configureAndConnect
              : null,
        )),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
            onPrimary: Colors.white,
          ),
          child: const Text('Disconnect'),
          onPressed:
              state == MQTTAppConnectionState.connected ? _disconnect : null,
        ))
      ],
    );
  }

  String _messageShown(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
    }
  }

  Widget textfield(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if (state == MQTTAppConnectionState.disconnected &&
            controller == _hostTextController ||
        state == MQTTAppConnectionState.disconnected &&
            controller == _topicTextController ||
        state == MQTTAppConnectionState.disconnected &&
            controller == _usernameTextController ||
        state == MQTTAppConnectionState.disconnected &&
            controller == _passwordTextController) {
      shouldEnable = true;
    } else if (state == MQTTAppConnectionState.connected &&
        controller == _messageTextController) {
      shouldEnable = true;
    }
    return TextFormField(
      enabled: shouldEnable,
      controller: controller,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10.0),
          labelText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(22.0)),
          )),
    );
  }

  void _publishMessage(String text) {
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    final String message = osPrefix + ' says: ' + text;
    manager.publish(message);
    _messageTextController.clear();
  }

  void _configureAndConnect() {
    // ignore: flutter_style_todos
    // TODO: Use UUID
    Random random = new Random();
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    manager = MQTTManager(
      host: _hostTextController.text,
      topic: _topicTextController.text,
      identifier: osPrefix + random.nextInt(100).toString(),
      state: currentAppState,
      username: _usernameTextController.text,
      password: _passwordTextController.text,
    );
    manager.initializeMQTTClient();

    manager.Connect();
  }

  void _disconnect() {
    manager.disconnect();
  }
}
