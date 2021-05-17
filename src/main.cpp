#include <Arduino.h>
#include <ESP32Servo.h>
#include "WiFi.h"
#include "html.h"

//servo inputs on esp32
#define NEEDLE_SERVO_PIN_PULL 13
#define NEEDLE_SERVO_PIN_PUSH 12
#define SWITCH_SERVO_PIN_UP 14
#define SWITCH_SERVO_PIN_DOWN 27


const char* ssid = "Vodafone-5B96";
const char* password =  "TfaEhytbqapgHeqT";
 
WiFiServer server(80);
Servo needle_slider_pull_servo;
Servo needle_slider_push_servo;
Servo switch_servo_up;
Servo switch_servo_down;

bool MUSIC_PLAYING = false;

void setup_wifi(){
  int not_connected_counter = 0;
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
     not_connected_counter++;
    if(not_connected_counter > 5) { // Reset board if not connected after 5s
        Serial.println("Resetting due to Wifi not connecting...");
        ESP.restart();
    }
  }
  
  Serial.println(WiFi.localIP());
}

void moveArmToggleServo(String toggle_state){
  int start_value_switch_down = 0;
  int start_value_switch_up = 180;
  int end_pos_down = 80;
  int end_pos_up = 40;

  Serial.println("toggle");
  if (toggle_state == "ON"){
    Serial.println("toggle on");

    for (int current_value = start_value_switch_down; current_value < end_pos_down; current_value++){
      switch_servo_down.write(current_value);
      delay(30);
    }
    delay(100);

    for (int current_value = end_pos_up; current_value > start_value_switch_down; current_value-=4){
      switch_servo_down.write(current_value);
      delay(15);
    }
    delay(100);
  } else if (toggle_state == "OFF") {

    //switch_servo_up.write(end_pos_down);
    //switch_servo_up.write(0);
    for (int current_value = start_value_switch_up; current_value > end_pos_up; current_value--){
      switch_servo_up.write(current_value);
      delay(30);
    }
    delay(100);
    for (int current_value = end_pos_up; current_value < start_value_switch_up; current_value+= 4){
      switch_servo_up.write(current_value);
      delay(15);
    }
    delay(100);
  }
}

void sendRequestAnwser(WiFiClient client){
  client.println("HTTP/1.1 200 OK");
  client.println("Content-type:text/html");
  client.println("Connection: close");
  client.println();
  client.print(index_html);
}

void setup(){
  Serial.begin(9600);
  needle_slider_pull_servo.attach(NEEDLE_SERVO_PIN_PULL);
  needle_slider_push_servo.attach(NEEDLE_SERVO_PIN_PUSH);
  switch_servo_up.attach(SWITCH_SERVO_PIN_UP);
  switch_servo_down.attach(SWITCH_SERVO_PIN_DOWN);

  setup_wifi();
  server.begin();

  moveArmToggleServo("OFF");
}


void moveServoToValue(int servo_pos){
  //move needle to start
  const int start_value_servo_pull = 0;
  const int start_value_servo_push = 180;

  int end_pos = 105;
  int moving_pos = start_value_servo_push - servo_pos; // has to be above 20

  //this code didnt work inside of functions for whatever reasons so its a repetitious
  for (int current_value = start_value_servo_pull; current_value < end_pos; current_value++){
    needle_slider_pull_servo.write(current_value);
    delay(30);
  }
  delay(100);

  Serial.println("Now backwards");
  for (int current_value = end_pos; current_value > start_value_servo_pull; current_value-= 4){
    needle_slider_pull_servo.write(current_value);
    delay(15);
  }
  delay(100);
  
  // Now move the second servo to the precise position
  for (int current_value = start_value_servo_push; current_value > moving_pos; current_value--){
    needle_slider_push_servo.write(current_value);
    delay(30);
  }
  delay(100);

  for (int current_value = moving_pos; current_value < start_value_servo_push; current_value+=4){
    needle_slider_push_servo.write(current_value);
    delay(15);
  }
}

void loop(){
  int pos1, pos2;
  WiFiClient client = server.available();


  if (client){
    Serial.println("New Client connected...");
    String header = client.readStringUntil('\r');
    while (client.connected()){
      sendRequestAnwser(client);

      Serial.println(header);
      if (header.indexOf("GET /?") >= 0){
        String request_type;
        pos1 = header.indexOf("?");
        pos2 = header.indexOf("=");

        request_type = header.substring(pos1+1,pos2);

        if (request_type == "armstatus"){
          String arm_toggle;
          pos1 = header.indexOf("=");
          pos2 = header.indexOf("&");

          arm_toggle = header.substring(pos1+1,pos2);
          
          moveArmToggleServo(arm_toggle);

        } else if (request_type = "needlevalue"){
          int servo_pos = 0;

          pos1 = header.indexOf("=");
          pos2 = header.indexOf("&");

          servo_pos = header.substring(pos1+1,pos2).toInt();        
          Serial.printf("slider_value: %d\n",servo_pos);
          moveServoToValue(servo_pos);
          delay(100);

        }
      }
      break;
    }
    client.stop();
    Serial.println("Client disconnected");
  }
}