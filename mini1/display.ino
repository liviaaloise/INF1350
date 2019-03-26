/* Define shift register pins used for seven segment display */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8
#include "pinDefs.h"
#include <GFButton.h>

GFButton but2(KEY2);

modes[7] = { CLOCK, ALARM_ON , ALARM, SET_CLOCK_H, SET_CLOCK_M, SET_ALARM_H, SET_ALARM_M } 

 
/* Segment byte maps for numbers 0 to 9 */
const byte SEGMENT_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90};
/* Byte maps to select digit 1 to 4 */
const byte SEGMENT_SELECT[] = {0xF1,0xF2,0xF4,0xF8};
 

void setup() {
  /* Set DIO pins to outputs */
  pinMode(LATCH_DIO,OUTPUT);
  pinMode(CLK_DIO,OUTPUT);
  pinMode(DATA_DIO,OUTPUT);
  pinMode(KEY1, INPUT);
  pinMode(KEY3, INPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);

  but2.button_pressed();
  but2.button_released();
}
 
/* Main program */
void loop() {
  but2.process();
  but1=digitalRead(KEY1);
  but3=digitalRead(KEY3);
  if(but1 && but3){
    mode = MODE_CLOCK;
  }
  if(but3){
    mode++;
  }
  
  switch(mode){
    case CLOCK:
      digitalWrite(LED1, LOW);
      show_time(clock_time);
      break;
    case ALARM_ON:
      digitalWrite(LED2, LOW);
      show_time(alarm_time);
      break;
    case ALARM:
      show_time(alarm_time);
      break;
    case SET_CLOCK_H:
      digitalWrite(LED3,LOW);
      set_time()
      break;
    case SET_CLOCK_M
      digitalWrite(LED4, LOW);
      set_time();
      break;
    case SET_ALARM_H:
      digitalWrite(LED3,LOW);
      set_time()
      break;
    case SET_ALARM_M
      digitalWrite(LED4, LOW);
      set_time();
      break;
    
  }
  WriteNumberToSegment(0 , 5);
  WriteNumberToSegment(1 , 6);
  WriteNumberToSegment(2 , 7);
  WriteNumberToSegment(3 , 8);
}

void but2_handler( GFButton &event){
  //Codigo 
}
 
/* Write a decimal number between 0 and 9 to one of the 4 digits of the display */
void WriteNumberToSegment(byte Segment, byte Value) {
  digitalWrite(LATCH_DIO,LOW);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[Value]);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[Segment] );
  digitalWrite(LATCH_DIO,HIGH);
}

