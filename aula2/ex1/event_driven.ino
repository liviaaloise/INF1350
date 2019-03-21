#include "event_driven.h"
#include "app.h"
#include "pindefs.h"

int pinStates[3] = {-1, -1, -1};
int pinDef[3] = {KEY1, KEY2, KEY3};
unsigned long timerStart;
unsigned long timerDuration;
unsigned long timeNow;

int getPin(int pin) {
  switch (pin) {
    case KEY1:
      return 0;
    case KEY2:
      return 1;
    case KEY3:
      return 2;
  }
}

void button_listen(int pin) {
  Serial.println(" button listen");
  pinMode(pin, INPUT_PULLUP);
  pinStates[getPin(pin)]=digitalRead(pin);
}

void timer_set(int ms) {
  timerStart = millis();
  timerDuration = (long)(unsigned)ms;
}




void setup() {
  Serial.begin(9600);
  appinit();
}


void loop() {
  for(int i =0;i<3;i++){
    int prevState = pinStates[i];
    if(prevState!=-1){
      int pin = pinDef[i];
      int currentState = digitalRead(pin);
      if (prevState != currentState){
        pinStates[i] = currentState;
        button_changed(pin, currentState);
      }
    }
  }

  timeNow=millis();
  if(timeNow-timerStart>= timerDuration){
    timer_expired();  
  }
}
