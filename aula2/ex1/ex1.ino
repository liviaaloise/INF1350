#include "event_driven.h"
#include "app.h"
#include "pindefs.h"

int state = 1;
unsigned long old;
unsigned long now1,now2 =0;
int tempo =1000;

void appinit() {
  button_listen(KEY1);
  button_listen(KEY2);
  pinMode(LED1,OUTPUT);
  digitalWrite(LED1, HIGH);
}


void button_changed (int pin, int v) {
  if(pin==KEY1){
    tempo-=10;
  }
  if(pin==KEY2){
    tempo+=10;
  }
}


void timer_expired () {
  state = !state;
  digitalWrite(LED1,state);
}


//void setup () {
//  Serial.begin(9600);
//  pinMode(LED1, OUTPUT); // Enable pin 13 for digital output
//  digitalWrite(LED1, HIGH);
//  pinMode(KEY1, INPUT_PULLUP);
//  pinMode(KEY2, INPUT_PULLUP);
//  pinMode(KEY3, INPUT_PULLUP);
//}
//
//void loop () {
//  unsigned long now = millis();
//  if (now >= old + tempo) {
//    old = now;
//    state = !state;
//    digitalWrite(LED1, state);
//  }
////  digitalWrite(LED_PIN, LOW);
////  delay(1000);
////  digitalWrite(LED_PIN, HIGH);
////  delay(1000);
//  int but1 = digitalRead(KEY1);
//  int but2 = digitalRead(KEY2);  
//
//  if (!but1) {
//    now1= millis();
//    tempo -= 10;
//    Serial.println(tempo);
//  }
//  else if (!but2) {
//    now2 = millis();
//    tempo += 10;
//    Serial.println(tempo);
//  }
//   unsigned long dif ;
//   if(now1>now2){
//    dif = now1-now2;
//   }
//   else{
//    dif = now2-now1;
//   }
//
//
//  if(dif<=500 && now1>0 && now2>0){
//    digitalWrite(LED1, HIGH);
//    while(1);
//  }
//
//}
