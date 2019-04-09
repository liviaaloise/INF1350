///* Define shift register pins used for seven segment display */
//#define LATCH_DIO 4
//#define CLK_DIO 7
//#define DATA_DIO 8
//
//#include "pinDefs.h"
//#include <ShiftDisplay.h>
//
//
////ShiftDisplay display(4, 7, 8, COMMON_ANODE, 4, true);
//int modes[7] = { CLOCK, ALARM_ON , ALARM, SET_CLOCK_H, SET_CLOCK_M, SET_ALARM_H, SET_ALARM_M };
//int modeIndex = 21;
//int aux = 0;
//int butStates[3] = {HIGH, HIGH, HIGH};
//int currentStates[3];
//unsigned long buttonTime[3] = {0, 0, 0};
//unsigned long debounceTime;
//int buttons[3] = {KEY1, KEY2, KEY3};
//
//
///* Segment byte maps for numbers 0 to 9 */
//const byte SEGMENT_MAP[] = {0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0X80, 0X90};
///* Byte maps to select digit 1 to 4 */
//const byte SEGMENT_SELECT[] = {0xF1, 0xF2, 0xF4, 0xF8};
//
//
//void setup() {
//  /* Set DIO pins to outputs */
//  Serial.begin(9600);
//  pinMode(LATCH_DIO, OUTPUT);
//  pinMode(CLK_DIO, OUTPUT);
//  pinMode(DATA_DIO, OUTPUT);
//  pinMode(KEY1, INPUT);
//  pinMode(KEY2, INPUT);
//  pinMode(KEY3, INPUT);
//  pinMode(LED1, OUTPUT);
//  pinMode(LED2, OUTPUT);
//  pinMode(LED3, OUTPUT);
//  pinMode(LED4, OUTPUT);
//  pinMode(BUZZ, OUTPUT);
//  leds_off();
//  digitalWrite(BUZZ, HIGH);
//}
//
///* Main program */
//void loop() {
//
//  int but1 = digitalRead(KEY1);
//  int but2 = digitalRead(KEY2);
//  int but3 = digitalRead(KEY3);
//
//  for (int i = 0; i < 3; i++) {
//    if (digitalRead(buttons[i]) != butStates[i]) {
//      if (buttonTime[i] == 0) {
//        butStates[i]=!butStates[i];
//        buttonTime[i] = millis();
//        buttonChanged();
//      }
//      else {
//        if (millis() - buttonTime[i] > debounceTime) {
//          buttonTime[i]=0;
//        }
//      }
//    }
//
//  }
//
//
//  if (but1 && but3) {
//    modeIndex = CLOCK;
//  }
//
//
//  //  if(but3.isPressed()){
//  //    modeIndex++;
//  //  }
//
//
//
//
//  switch (modeIndex) {
//    case CLOCK:
//      digitalWrite(LED1, LOW);
//      //      show_time(clock_time);
//      break;
//    case ALARM_ON:
//      digitalWrite(LED2, LOW);
//      //      show_time(alarm_time);
//      break;
//    case ALARM:
//      digitalWrite(LED1, LOW);
//      digitalWrite(LED2, LOW);
//      //      show_time(alarm_time);
//      break;
//    case SET_CLOCK_H:
//      digitalWrite(LED1, LOW);
//      digitalWrite(LED3, LOW);
//      //      set_time()
//      break;
//    case SET_CLOCK_M:
//      digitalWrite(LED1, LOW);
//      digitalWrite(LED4, LOW);
//      //      set_time();
//      break;
//    case SET_ALARM_H:
//      digitalWrite(LED2, LOW);
//      digitalWrite(LED3, LOW);
//      //      set_time()
//      break;
//    case SET_ALARM_M:
//      digitalWrite(LED2, LOW);
//      digitalWrite(LED4, LOW);
//      //      set_time();
//      break;
//
//  }
//  WriteNumberToSegment(0 , 5);
//  WriteNumberToSegment(1 , 6);
//  WriteNumberToSegment(2 , 7);
//  WriteNumberToSegment(3 , 8);
//}
//
///* Write a decimal number between 0 and 9 to one of the 4 digits of the display */
//void WriteNumberToSegment(byte Segment, byte Value) {
//  digitalWrite(LATCH_DIO, LOW);
//  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[Value]);
//  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[Segment] );
//  digitalWrite(LATCH_DIO, HIGH);
//}
//
//void leds_off() {
//  for (int i = 10; i < 14; i++) {
//    digitalWrite(i, HIGH);
//  }
//}
//
//void mode () {
//  //  if (modeIndex===CLOCK){
//  //    digitalWrite(LED1, LOW);
//  //  }
//  //  else if(modeIndex==ALARM_ON){
//  //    digitalWrite(LED2, LOW);
//  ////      show_time(alarm_time);
//  //  }
//  //  else if(modeIndex==ALARM){
//  ////    show_time(alarm_time);
//  //  }
//  //  else if(modeIndex==SET_CLOCK_H){
//  //  }
//}
