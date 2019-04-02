//#define LED_PIN 13
//#define BUT1 A1
//#define BUT2 A2
//#define BUT3 A3
//
//int state = 1;
//unsigned long old;
//int tempo = 1000;
//int led2 = 12;
//int led3 = 11;
//unsigned long now1,now2 =0;
//
//void setup () {
//  Serial.begin(9600);
//  pinMode(LED_PIN, OUTPUT); // Enable pin 13 for digital output
//  digitalWrite(LED_PIN, HIGH);
//  pinMode(BUT1, INPUT_PULLUP);
//  pinMode(BUT2, INPUT_PULLUP);
//  pinMode(BUT3, INPUT_PULLUP);
//}
//
//void loop () {
//  unsigned long now = millis();
//  if (now >= old + tempo) {
//    old = now;
//    state = !state;
//    digitalWrite(LED_PIN, state);
//  }
////  digitalWrite(LED_PIN, LOW);
////  delay(1000);
////  digitalWrite(LED_PIN, HIGH);
////  delay(1000);
//  int but1 = digitalRead(BUT1);
//  int but2 = digitalRead(BUT2);  
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
//    digitalWrite(LED_PIN, HIGH);
//    while(1);
//  }
//
//}

