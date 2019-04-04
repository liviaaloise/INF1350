/* Define shift register pins used for seven segment display */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8

#define BUT1 A1
#define BUT2 A2
#define BUT3 A3

#include "pinDefs.h"
//#include <GFButton.h>
//#include <ShiftDisplay.h>

//GFButton but2(KEY2);
//GFButton but3(KEY3);


// ------------------------------------------------ TODO add display funcs
// Clock time (initialized as 14:09h)
int clk_h1 = 1;
int clk_h0 = 4;
int clk_m1 = 0;
int clk_m0 = 9;

// Alarm time (initialized as 23:58h)
int alm_h1 = 2;
int alm_h0 = 3;
int alm_m1 = 5;
int alm_m0 = 8;

unsigned long timeNow;
unsigned long timerStart;
unsigned long timerDuration;

void timer_set(int ms) {
  timerStart = millis();
  timerDuration = (long)(unsigned)ms;
}
// ------------------------------------------------ TODO add display funcs


//ShiftDisplay display(4, 7, 8, COMMON_ANODE, 4, true);
int modes[7] = { CLOCK, ALARM_ON , ALARM, SET_CLOCK_H, SET_CLOCK_M, SET_ALARM_H, SET_ALARM_M }; 
int modeIndex = 21;
int aux = 0;


// -------------------- TODO add display funcs
void update_time() {
  clk_m0 += 1;
  if (clk_m0 >= 10) {
    clk_m0 = 0;
    clk_m1 += 1;
  }
  if (clk_m1 >= 6) {
    clk_m1 = 0;
    clk_h0 += 1;
  }
  if (clk_h1 == 2 && clk_h0 >= 4) {
    clk_h0 =0;
    clk_h1 = 0;
  }
  else if (clk_h0 >= 10) {
    clk_h0 = 0;
    clk_h1 += 1;
  }
}

void show_time(int h1, int h0, int m1, int m0) {
  WriteNumberToSegment(0 , h1);
  WriteNumberToSegment(1 , h0);
  WriteNumberToSegment(2 , m1);
  WriteNumberToSegment(3 , m0);
}
// -------------------- TODO add display funcs

/* Segment byte maps for numbers 0 to 9 */
const byte SEGMENT_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90};
/* Byte maps to select digit 1 to 4 */
const byte SEGMENT_SELECT[] = {0xF1,0xF2,0xF4,0xF8};

//void but2Handler(GFButton& event){
//  //Codigo 
//  aux+=1;
//} 

//void but3Handler (GFButton& botaoDoEvento) {
//  leds_off();
//  Serial.println(String(modeIndex));
//   modeIndex+=1;
//  if(modeIndex == 28){
//    modeIndex = 21;
//  }
//}

void setup() {
  /* Set DIO pins to outputs */
  Serial.begin(9600);
  pinMode(LATCH_DIO,OUTPUT);
  pinMode(CLK_DIO,OUTPUT);
  pinMode(DATA_DIO,OUTPUT);
  pinMode(KEY1, INPUT);
//  pinMode(KEY3, INPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);
  pinMode(BUZZ, OUTPUT);
  leds_off();
  digitalWrite(BUZZ,HIGH);

  pinMode(BUT1, INPUT_PULLUP);
  pinMode(BUT2, INPUT_PULLUP);
  pinMode(BUT3, INPUT_PULLUP);
//  but2.setPressHandler(but2Handler);
//  but3.setPressHandler(but3Handler);

//  ------------------------------------ TODO changed
  // 1000 = 1seg
  int tempo = 1000; // 1min = 60000
  timer_set(tempo);  
}
//  ------------------------------------ TODO changed

 
/* Main program */
void loop() {
  int but1 = digitalRead(BUT1);
  int but2 = digitalRead(BUT2);
  int but3 = digitalRead(BUT3);

  timeNow=millis();
  if(timeNow-timerStart>= timerDuration) {
    update_time();
    int tempo = 1000;
    timer_set(tempo); 
  }

//  // Teste: Botao 1 mostra as horas e botao 2 mostra o horario do alarme
//  if (!but1) {
//    Serial.println("but 1");
//    modeIndex = modes[0];
//  }
//
//  else if (!but2) {
//    Serial.println("but \t\t 2");
//    modeIndex = modes[2];
//  }
//  // TODO: Apagar teste
  
  switch(modeIndex){
    case CLOCK:
      digitalWrite(LED1, LOW);
//      show_time(clock_time);
      show_time(clk_h1, clk_h0, clk_m1, clk_m0);
      break;
    case ALARM_ON:
      digitalWrite(LED2, LOW);
//      show_time(alarm_time);
      break;
    case ALARM:
      digitalWrite(LED1, LOW);
      digitalWrite(LED2, LOW);
//      show_time(alarm_time);
      show_time(alm_h1, alm_h0, alm_m1, alm_m0);
      break;
    case SET_CLOCK_H:
      digitalWrite(LED1, LOW);
      digitalWrite(LED3,LOW);
//      set_time()
      break;
    case SET_CLOCK_M:
      digitalWrite(LED1, LOW);
      digitalWrite(LED4, LOW);
//      set_time();
      break;
    case SET_ALARM_H:
      digitalWrite(LED2, LOW);
      digitalWrite(LED3,LOW);
//      set_time()
      break;
    case SET_ALARM_M:
      digitalWrite(LED2, LOW);
      digitalWrite(LED4, LOW);
//      set_time();
      break;
    
  }

}
 
/* Write a decimal number between 0 and 9 to one of the 4 digits of the display */
void WriteNumberToSegment(byte Segment, byte Value) {
  digitalWrite(LATCH_DIO,LOW);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[Value]);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[Segment] );
  digitalWrite(LATCH_DIO,HIGH);
}

void leds_off(){
  for(int i=10;i<14;i++){
    digitalWrite(i,HIGH);
  }
}

void mode (){
//  if (modeIndex===CLOCK){
//    digitalWrite(LED1, LOW);
//  }
//  else if(modeIndex==ALARM_ON){
//    digitalWrite(LED2, LOW);
////      show_time(alarm_time);
//  }
//  else if(modeIndex==ALARM){
////    show_time(alarm_time);
//  }
//  else if(modeIndex==SET_CLOCK_H){
//  }
}
