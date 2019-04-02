#include "pindefs.h"
byte state = HIGH;
volatile int counter = 0;
unsigned long now1,now2 =0;

volatile int buttonChanged = 0;

void timerSetup () {
   TIMSK2 = (TIMSK2 & B11111110) | 0x01;
   TCCR2B = (TCCR2B & B11111000) | 0x07;
}

void pciSetup (byte pin) {
    *digitalPinToPCMSK(pin) |= bit (digitalPinToPCMSKbit(pin));  // enable pin
    PCIFR  |= bit (digitalPinToPCICRbit(pin)); // clear any outstanding interruptjk
    PCICR  |= bit (digitalPinToPCICRbit(pin)); // enable interrupt for the group
}

void disable (byte pin) {
  *digitalPinToPCMSK(pin) &= ~bit (digitalPinToPCMSKbit(pin)); 
}


void setup() {
   Serial.begin(9600);
   pinMode(LED1, OUTPUT); digitalWrite(LED1, state);
   pinMode(LED2, OUTPUT); digitalWrite(LED2, state);
   pinMode(LED3, OUTPUT); digitalWrite(LED3, state);
   pinMode(LED4, OUTPUT); digitalWrite(LED4, state);
   pinMode(KEY1, INPUT_PULLUP);
   pinMode(KEY2, INPUT_PULLUP);
   pinMode(KEY3, INPUT_PULLUP);
   pciSetup(KEY1); pciSetup(KEY2); pciSetup(KEY3);
   timerSetup();
}
 
void loop() {
//  Serial.println(String(counter));
  if (counter>50) {
    state = !state;
    digitalWrite(LED1, state);
    counter = 0;
  }

  if(buttonChanged){
    int but1=digitalRead(KEY1);
    int but2=digitalRead(KEY2);
    if (!but1) {
      now1= millis();
    }
    else if (!but2) {
      now2 = millis();
    }
     unsigned long dif ;
     if(now1>now2){
      dif = now1-now2;
     }
     else{
      dif = now2-now1;
     }
  
    if(dif<=500 && now1>0 && now2>0){
      digitalWrite(LED1, HIGH);
      while(1);
    }
    buttonChanged =0;
  }
  
}
 
ISR(TIMER2_OVF_vect){
   counter++;
}

ISR (PCINT1_vect) { // handle pin change interrupt for A0 to A5 here
   buttonChanged=1;
 }  

