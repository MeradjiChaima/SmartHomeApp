import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'dart:async';
import 'package:http/http.dart' as http;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade50),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Smart Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool toggle1 = false;
  bool toggle2 = false;
  bool toggle3 = false;
  var textSpeech = "CLICK ON MIC TO ORDER";
  SpeechToText speechToText = SpeechToText();
  var isListening = false;
  late MqttServerClient client;

  void checkMic() async {
    bool micAvailable = await speechToText.initialize();

    if (micAvailable) {
      print("Microphone Available");
    } else {
      print("User Denied the use of speech microphone");
    }
  }

  // Function to handle incoming MQTT messages
  void messageHandler(List<MqttReceivedMessage<MqttMessage>> event) {
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    final String message = utf8.decode(recMess.payload.message as List<int>); // Use utf8.decode
    final String? topic = event[0].topic;
    print("Comming "+message+" from : "+topic!);
    if (topic == "Interior Lamp") {
      setState(() {
        toggle1 = (message == '1');
      });
    } else if (topic == "Exterior Lamp") {
      setState(() {
        toggle2 = (message == '1');
      });
    }
    else if (topic=="Garage"){
      setState(() {
        toggle3 = (message == '1');
      });
    }
  }

  // Function to setup MQTT client and subscribe to topics
  Future<void> setupMqttClient() async {
    client = MqttServerClient('192.168.228.193', '');
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.autoReconnect = true;
    client.onAutoReconnect = onAutoReconnect;
    client.onAutoReconnected = onAutoReconnected;


    final connMess = MqttConnectMessage()
        .withClientIdentifier('MQTT5DartClient')
        .startClean();
    client.connectionMessage = connMess;

    try {
      await client.connect();
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print('Mosquitto client connected');
        // Subscribe to topics
        client.subscribe("Interior Lamp", MqttQos.atLeastOnce);
        client.subscribe("Exterior Lamp", MqttQos.atLeastOnce);
        client.subscribe("Garage", MqttQos.atLeastOnce);

        // Listen for incoming messages
        client.updates.listen(messageHandler);
      } else {
        print(
            'ERROR Mosquitto client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
        client.disconnect();
      }
    } on Exception catch (e) {
      print('client exception - $e');
      client.disconnect();
    }
  }


  void onSubscribed(MqttSubscription topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
  }

  /// The pre auto re connect callback
  void onAutoReconnect() {
    print('Client auto reconnection sequence will start');
  }

  /// The post auto re connect callback
  void onAutoReconnected() {
    print('Client auto reconnection sequence has completed');
  }
    void publishMessage(String topic, String message) {
      final builder = MqttPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }

    void processSpeechCommand(String command) {
      command = command.toLowerCase();

      bool containsOn = command.contains(RegExp(r'\bon\b'));
      bool containsOff = command.contains(RegExp(r'\b(off|of)\b'));
      bool containsInside = command.contains(RegExp(r'\binside\b'));
      bool containsOutside = command.contains(RegExp(r'\boutside\b'));
      bool containsOpen = command.contains(RegExp(r'\bopen\b'));
      bool containsClose = command.contains(RegExp(r'\bclose\b'));

      if (containsOn && containsInside) {
        setState(() {
          toggle1 = true;
        });
        publishMessage('Interior Lamp', '1');
      } else if (containsOff && containsInside) {
        setState(() {
          toggle1 = false;
        });
        publishMessage('Interior Lamp', '0');
      } else if (containsOn && containsOutside) {
        setState(() {
          toggle2 = true;
        });
        publishMessage('Exterior Lamp', '1');
      } else if (containsOff && containsOutside) {
        setState(() {
          toggle2 = false;
        });
        publishMessage('Exterior Lamp', '0');
      } else if (containsOpen) {
        setState(() {
          toggle3 = true;
        });
        publishMessage('Garage', '1');
      } else if (containsClose) {
        setState(() {
          toggle3 = false;
        });
        publishMessage('Garage', '0');
      }
    }

    void getInitialStates() async {
      // Send HTTP GET request to get interior lamp state
      var intStateResponse = await http.get(
          Uri.parse('http://192.168.228.110:80/intState'));
      if (intStateResponse.statusCode == 200) {
        var intState = intStateResponse.body;
        setState(() {
          toggle1 = (intState == '1');
        });
      } else {
        print('Failed to get interior lamp state: ${intStateResponse
            .statusCode}');
      }

      // Send HTTP GET request to get exterior lamp state
      var extStateResponse = await http.get(
          Uri.parse('http://192.168.228.110:80/extState'));
      if (extStateResponse.statusCode == 200) {
        var extState = extStateResponse.body;
        setState(() {
          toggle2 = (extState == '1');
        });
      } else {
        print('Failed to get exterior lamp state: ${extStateResponse
            .statusCode}');
      }
    }


    @override
    void initState() {
      super.initState();
      checkMic();
      getInitialStates();
      setupMqttClient();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: toggle1 ? Colors.greenAccent.shade100.withOpacity(
                          0.2) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Image.asset(toggle1
                              ? 'images/lamp_on.png'
                              : 'images/lamp_off.png', width: 50, height: 50),
                          Text(
                            'Inside Lamp',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                            ),
                          ),
                          Switch(
                            activeColor: Colors.greenAccent.shade400,
                            value: toggle1,
                            onChanged: (value) {
                              setState(() {
                                toggle1 = value;
                              });
                              publishMessage(
                                  'Interior Lamp', toggle1 ? '1' : '0');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: toggle2 ? Colors.greenAccent.shade100.withOpacity(
                          0.2) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Image.asset(toggle2
                              ? 'images/lamp_on.png'
                              : 'images/lamp_off.png', width: 50, height: 50),
                          Text(
                            'Outside Lamp',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                            ),
                          ),
                          Switch(
                            activeColor: Colors.greenAccent.shade400,
                            value: toggle2,
                            onChanged: (value) {
                              setState(() {
                                toggle2 = value;
                              });
                              publishMessage(
                                  'Exterior Lamp', toggle2 ? '1' : '0');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: toggle3 ? Colors.greenAccent.shade100.withOpacity(
                          0.2) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Image.asset(toggle3
                              ? 'images/garage_opened.png'
                              : 'images/garage_closed.png', width: 50,
                              height: 50),
                          Text(
                            'Garage',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                            ),
                          ),
                          Switch(
                            activeColor: Colors.greenAccent.shade400,
                            value: toggle3,
                            onChanged: (value) {
                              setState(() {
                                toggle3 = value;
                              });
                              publishMessage('Garage', toggle3 ? '1' : '0');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: FloatingActionButton(
                  onPressed: () async {
                    if (!isListening) {
                      var available = await speechToText.initialize();
                      if (available) {
                        setState(() {
                          isListening = true;
                        });
                        speechToText.listen(
                          onResult: (result) {
                            setState(() {
                              textSpeech = result.recognizedWords;
                            });
                            if (result.finalResult) {
                              processSpeechCommand(result.recognizedWords);
                              setState(() {
                                isListening = false;
                              });
                            }
                          },
                        );
                      }
                    } else {
                      setState(() {
                        isListening = false;
                      });
                      speechToText.stop();
                    }
                  },
                  child: Icon(isListening ? Icons.mic : Icons.mic_none),
                ),
              ),
            ),
          ],
        ),
      );
    }
}
