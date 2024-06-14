#include <Servo.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ESP8266WebServer.h>


// WiFi credentials
const char* ssid = "WHOKNOWS";
const char* password = "87:T4q18";
const char* mqtt_server = "test.mosquitto.org";


// Pin definitions
const int intLED = D1; // Interior LED
const int extLED = D8; // Exterior LED
const int servoPin1 = D4; // Servo motor 1
const int servoPin2 = D6; // Servo motor 2


WiFiClient espClient;
PubSubClient client(espClient);
ESP8266WebServer server(80);
Servo myservo1;
Servo myservo2;


void setup_wifi() {
  delay(100);
  Serial.begin(9600);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}


void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("]: ");
 
  String message;
  for (unsigned int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  Serial.println(message);


  if (String(topic) == "Interior Lamp") {
    if (message.equals("1")) {
      Serial.println("Turning on the Interior LED");
      digitalWrite(intLED, HIGH); // Turn on Interior LED
    } else if (message.equals("0")) {
      Serial.println("Turning off the Interior LED");
      digitalWrite(intLED, LOW); // Turn off Interior LED
    }
  } else if (String(topic) == "Exterior Lamp") {
    if (message.equals("1")) {
      Serial.println("Turning on the Exterior LED");
      digitalWrite(extLED, HIGH); // Turn on Exterior LED
    } else if (message.equals("0")) {
      Serial.println("Turning off the Exterior LED");
      digitalWrite(extLED, LOW); // Turn off Exterior LED
    }
  } else if (String(topic) == "Garage") {
    int angle = 0;
    if (message == "1") {
      // angle = 9;
      // myservo1.write(angle);
      // myservo2.write(angle);
      angle = 40;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 20;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 30;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 40;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 50;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 60;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 70;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 80;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 90;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 100;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 1100;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 120;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);

    } else if (message == "0") {
      angle = 0;
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 1100;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 100;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 90;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 80;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 70;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 60;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 50;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 40;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 30;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 20;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 100;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
      // angle = 0;
      // delay(100);
      // myservo1.write(angle);
      // myservo2.write(angle);
    } else {
      Serial.println("Unknown command");
      return;
    }
    myservo1.write(angle);
    // delay(500);
    myservo2.write(angle);
    delay(1000);
    myservo1.write(angle);
    // delay(500);
    myservo2.write(angle);
    Serial.print("Servo angles set to: ");
    Serial.println(angle);
  }
}


void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
      client.subscribe("Interior Lamp");  
      client.subscribe("Exterior Lamp");
      client.subscribe("Garage");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}


void setup() {
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
  pinMode(intLED, OUTPUT);
  pinMode(extLED, OUTPUT);
  myservo1.attach(servoPin1);
  myservo2.attach(servoPin2);
 
  server.on("/intState", HTTP_GET, [](){
    server.send(200, "text/plain", String(digitalRead(intLED)));
  });


  server.on("/extState", HTTP_GET, [](){
    server.send(200, "text/plain", String(digitalRead(extLED)));
  });


  server.begin();
  Serial.println("HTTP server started");
}


void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  server.handleClient();
}



