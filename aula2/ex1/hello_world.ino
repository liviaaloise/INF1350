#include "event_driven.h"
#include "app.h"
#include "pindefs.h"


void appinit() {
  button_listen(KEY1);
  pinMode(LED1,OUTPUT);
  digitalWrite(LED1, HIGH);
}


void button_changed (int pin, int v) {
  digitalWrite(LED1, v);
}


void timer_expired () {
}
