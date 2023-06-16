import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../provider/MQTTAppState.dart';

class MQTTManager {
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final String _identifier;
  final String _host;
  final String _topic;
  final String _username;
  final String _password;


  MQTTManager({
    required String host,
    required String topic,
    required String identifier,
    required MQTTAppState state,
    required String username,
    required String password,

  })
      :_identifier=identifier,
        _host=host,
        _topic=topic,
        _currentState=state,
        _username=username,
        _password=password;


  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = 1883;
    _client!.onDisconnected = onDisconnected;
    _client!.keepAlivePeriod=20;
    _client!.secure=false;
    _client!.logging(on: true);
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;



  final MqttConnectMessage connMess = MqttConnectMessage()
      .withClientIdentifier(_identifier)
      .withWillTopic('willtopic')
      .withWillMessage('My Will Message')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce)
      .authenticateAs(_username, _password);
    _client!.connectionMessage=connMess;
}
  void Connect() async{
    assert(_client!=null); // It checks wether the client is null or not before connection
    try{
      print('EXAMPLE::MOSQUITO start client connecting...');
      _currentState.setMqttAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect();
    } on Exception catch(e){
      print('Example::client exception - $e');
      disconnect();
    }
  }

  void onDisconnected() {
    print("EXAMPLE::OnDisconnected client callback- Client disconnection");
    if(_client!.connectionStatus!.returnCode==MqttConnectReturnCode.noneSpecified){
      print("EXAMPLE::OnDisconnected calllback is solicited this is correct");
    }
    _currentState.setMqttAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  void onConnected() {
    _currentState.setMqttAppConnectionState(MQTTAppConnectionState.connected);
    print('MOSQUITTO CLIENT CONNECTEED');
    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c){
      final MqttPublishMessage recMess=c![0].payload as MqttPublishMessage;
      final String pt=MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
      _currentState.setReceivedText(pt);
      print('EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <--$pt-->');
      print("");
    });
    print('EXAMPLE:: OnConnected client callback -Client connection was successful');
  }

  void onSubscribed(String topic) {
    print("EXAMPLE:Subscription confirm for topic $topic");
  }

  void disconnect() {
    print("Disconnected");
    _client!.disconnect();
  }
  void publish(String message){
    final MqttClientPayloadBuilder builder= MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }
}
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import '../provider/MQTTAppState.dart';
//
// class MQTTManager {
//   final MQTTAppState _currentState;
//   MqttServerClient? _client;
//   final String _identifier;
//   final String _host;
//   final String _topic;
//   final String _username;
//   final String _password;
//
//   MQTTManager({
//     required String host,
//     required String topic,
//     required String identifier,
//     required MQTTAppState state,
//     required String username,
//     required String password,
//   })  : _identifier = identifier,
//         _host = host,
//         _topic = topic,
//         _currentState = state,
//         _username = username,
//         _password = password;
//
//   void initializeMQTTClient() {
//     _client = MqttServerClient(_host, _identifier);
//     _client!.port = 21677;
//     _client!.keepAlivePeriod = 20;
//     _client!.secure = true;
//     _client!.logging(on: true);
//
//     // Set up callbacks
//     _client!.onDisconnected = _onDisconnected;
//     _client!.onConnected = _onConnected;
//   }
//
//   Future<void> connect() async {
//     assert(_client != null); // Check that the client is not null
//     try {
//       print('Connecting to MQTT server...');
//       _currentState.setMqttAppConnectionState(MQTTAppConnectionState.connecting);
//       await _client!.connect(
//           _username, _password); // Pass the username and password to connect()
//     } catch (e) {
//       print('MQTT connection failed: $e');
//       _currentState.setMqttAppConnectionState(MQTTAppConnectionState.disconnected);
//       disconnect();
//     }
//   }
//
//   void _onDisconnected() {
//     print('Disconnected from MQTT server');
//     _currentState.setMqttAppConnectionState(MQTTAppConnectionState.disconnected);
//   }
//
//   void _onConnected() {
//     print('Connected to MQTT server');
//     _currentState.setMqttAppConnectionState(MQTTAppConnectionState.connected);
//     _client!.subscribe(_topic, MqttQos.atLeastOnce);
//     _client!.updates!.listen(_onMessageReceived);
//   }
//
//   void _onMessageReceived(List<MqttReceivedMessage<MqttMessage?>>? messages) {
//     final MqttPublishMessage? message = messages![0].payload as MqttPublishMessage?;
//     final String payload =
//     MqttPublishPayload.bytesToStringAsString(message!.payload.message!);
//     _currentState.setReceivedText(payload);
//     print('Received message: $payload');
//   }
//
//   void disconnect() {
//     print('Disconnecting from MQTT server...');
//     _client?.disconnect();
//     _client = null;
//   }
//
//   void publish(String message) {
//     final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
//     builder.addString(message);
//     _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
//   }
// }
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:uuid/uuid.dart';
// import '../provider/MQTTAppState.dart';
//
// class MQTTManager {
//   final MQTTAppState _currentState;
//   MqttServerClient? _client;
//   final String _identifier;
//   final String _host;
//   final String _topic;
//   final String _username;
//   final String _password;
//   late final Uuid _uuid ;
//
//   MQTTManager({
//     required String host,
//     required String topic,
//     required MQTTAppState state,
//     required String username,
//     required String password,
//   })  : _identifier =Uuid().v4(),
//         _host = host,
//         _topic = topic,
//         _currentState = state,
//         _username = username,
//         _password = password;
//
//   void initializeMQTTClient() {
//     _client = MqttServerClient.withPort(_host, _identifier,11677);
//     _client!.keepAlivePeriod = 20;
//     _client!.secure = true;
//     _client!.logging(on: false);
//
//     // Set up callbacks
//     _client!.onDisconnected = _onDisconnected;
//     _client!.onConnected = _onConnected;
//   }
//
//   Future<void> connect() async {
//     assert(_client != null); // Check that the client is not null
//     try {
//       print('Connecting to MQTT server...');
//       _currentState.setMqttAppConnectionState(MQTTAppConnectionState.connecting);
//       await _client!.connect(_username, _password);
//     } catch (e) {
//       print('MQTT connection failed: $e');
//       _currentState.setMqttAppConnectionState(MQTTAppConnectionState.disconnected);
//       disconnect();
//     }
//   }
//
//   void _onDisconnected() {
//     print('Disconnected from MQTT server');
//     _currentState.setMqttAppConnectionState(MQTTAppConnectionState.disconnected);
//     // Reconnect after a delay
//     Future.delayed(Duration(seconds: 5), () => connect());
//   }
//
//   void _onConnected() {
//     print('Connected to MQTT server');
//     _currentState.setMqttAppConnectionState(MQTTAppConnectionState.connected);
//     _client!.subscribe(_topic, MqttQos.atLeastOnce);
//     _client!.updates!.listen(_onMessageReceived);
//   }
//
//   void _onMessageReceived(List<MqttReceivedMessage<MqttMessage?>>? messages) {
//     final MqttPublishMessage? message = messages![0].payload as MqttPublishMessage?;
//     final String payload =
//     MqttPublishPayload.bytesToStringAsString(message!.payload.message!);
//     _currentState.setReceivedText(payload);
//     print('Received message: $payload');
//   }
//
//   void disconnect() {
//     print('Disconnecting from MQTT server...');
//     _client?.unsubscribe(_topic);
//     _client?.disconnect();
//     _client = null;
//   }
//
//   void publish(String message) {
//     final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
//     builder.addString(message);
//     _client!.publishMessage(_topic, MqttQos.atLeastOnce, builder.payload!);
//   }
// }