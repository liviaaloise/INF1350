/* Define shift register pins used for seven segment display */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8

#include "pinDefs.h"
#include "app.h"

// Music Notes for alarm
#define doh 261
#define reh 294
#define mih 329
#define fah 349
#define sol 392
#define lah 440
#define sih 493

int music[30] = {mih, mih, fah, sol, sol, fah, mih, reh, doh, doh, reh, mih, mih, reh, reh,
                 mih, mih, fah, sol, sol, fah, mih, reh, doh, doh, reh, mih, reh, doh, doh};
int music_note = 0;
int size_of_music = sizeof(music) - 1;

// Clock time (initialized as 19:57h)
int clk_h1 = 1;
int clk_h0 = 9;
int clk_m1 = 5;
int clk_m0 = 7;

// Alarm time (initialized as 20:03h)
int alm_h1 = 2;
int alm_h0 = 0;
int alm_m1 = 0;
int alm_m0 = 3;

unsigned long timeNow;
unsigned long timerStart;
unsigned long timerDuration;

unsigned long buzz_ts; //buzzer timer start
unsigned long buzz_td; //buzzer timer duration
bool turn_on_buzzer = false;
int led_state = LOW;

void timer_set(int ms) {
  timerStart = millis();
  timerDuration = (long)(unsigned)ms;
}

// ------------------------------ DEBOUNCE HANDLER VARS
int butStates[3] = {HIGH, HIGH, HIGH};
int currentStates[3];
int buttons[3] = {KEY1, KEY2, KEY3};
int butLastStates[3] = {HIGH, HIGH, HIGH};
unsigned long buttonTime[3] = {0, 0, 0};
unsigned long debounceTime;
unsigned long timer_b1_b3 = 950;  // time limit between but3 press and but1 press to go back to first state
unsigned long debounceDelay = 50;    // the debounce time = 50ms
unsigned long lastDebounceTime = 0;
unsigned long but1_time_pressed = 0;
unsigned long but3_time_pressed = 0;
// ------------------------------ DEBOUNCE HANDLER VARS

int modes[7] = { CLOCK, ALARM_ON , ALARM, SET_CLOCK_H, SET_CLOCK_M, SET_ALARM_H, SET_ALARM_M };
int modeIndex = 21;
int lastMode = 28; //initial value = 28 (invalid mode)
int counter = 0; //count how many seconds the program has been in the same state
int count_minutes = 0; //count every 60seconds
unsigned long last_pressed_time = 0;
int aux = 0;
int current_mode = 0;

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
    clk_h0 = 0;
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

void play_alarm_song(){
  tone(BUZZ, music[music_note], 500);
  // digitalWrite(BUZZ, HIGH);
  music_note += 1;
  if (music_note > size_of_music) {
    turn_on_buzzer = false;
    music_note = 0;
  }
}

/* Segment byte maps for numbers 0 to 9 */
const byte SEGMENT_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90};
/* Byte maps to select digit 1 to 4 */
const byte SEGMENT_SELECT[] = {0xF1,0xF2,0xF4,0xF8};

void setup() {
  /* Set DIO pins to outputs */
  Serial.begin(9600);
  pinMode(LATCH_DIO, OUTPUT);
  pinMode(CLK_DIO, OUTPUT);
  pinMode(DATA_DIO, OUTPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);
  pinMode(BUZZ, OUTPUT);
  leds_off();
  digitalWrite(BUZZ, HIGH); //turn of buzzer when HIGH

  pinMode(KEY1, INPUT_PULLUP);
  pinMode(KEY2, INPUT_PULLUP);
  pinMode(KEY3, INPUT_PULLUP);
  buzz_td = sizeof(music)*1000;
  buzz_ts = 0;
  int tempo = 1000;
  timer_set(tempo);
}
// END OF SETUP

/* Main program */
void loop() {
  digitalWrite(BUZZ, HIGH);
  int but1 = digitalRead(KEY1);
  int but2 = digitalRead(KEY2);
  int but3 = digitalRead(KEY3);

  if((timeNow - buzz_ts >= buzz_td)) {
    turn_on_buzzer = false;
    digitalWrite(BUZZ, HIGH);
     music_note = 0;
  }

  //  Debounce Handler
  for (int i = 0; i < 3; i++) {
    butStates[i] = digitalRead(buttons[i]);
    if ((butStates[i] == LOW) && (butLastStates[i] == HIGH)) {
      currentStates[i] = LOW;
      buttonTime[i] = millis();
    }
  }
  timeNow = millis();
  //BUT1
  if ((timeNow - buttonTime[0]) > debounceDelay) {
    if (butStates[0] != currentStates[0]) {
      currentStates[0] = butStates[0];
      if (currentStates[0] == HIGH) {
        but1_time_pressed = millis();
        counter = 0;
        Serial.println("PRESSED BUT ONE!");
      }
    }
  }
  //BUT2
  if ((timeNow - buttonTime[1]) > debounceDelay) {
    if (butStates[1] != currentStates[1]) {
      currentStates[1] = butStates[1];
      if (currentStates[1] == HIGH) {
        counter = 0;
        if(modeIndex==SET_CLOCK_H) {
          leds_off();
          update_clk_hour();
        }
        else if(modeIndex==SET_CLOCK_M) {
          leds_off();
          update_clk_min();
        }
        else if(modeIndex==SET_ALARM_H) {
          leds_off();
          update_alm_hour();
        }
        else if(modeIndex==SET_ALARM_M) {
          leds_off();
          update_alm_min();
        }
        Serial.println("\t\t\tPRESSED BUT TWO!");
      }
    }
  }
  //BUT3
  if ((buttonTime[2] != 0)&&((timeNow - buttonTime[2]) > debounceDelay)) {
    if (butStates[2] != currentStates[2]) {
      currentStates[2] = butStates[2];
      if (currentStates[2] == HIGH) {
        but3_time_pressed = millis();
        Serial.println("\t\t\t\t\t\tPRESSED BUT THREE!");
        counter = 0;
        lastMode = modeIndex; //save last mode before going to next mode
        goto_next_mode();
      }
    }
  }
  //BUT1+3
  if ((but1_time_pressed!=0) && (but3_time_pressed!=0)) {
    if (abs(but1_time_pressed - but3_time_pressed) <= timer_b1_b3) {
      leds_off();
      modeIndex = 21; //reset mode to first state
    }
  }
  butLastStates[0] = but1;
  butLastStates[1] = but2;
  butLastStates[2] = but3;
  // end of Debounce

  timeNow = millis();
  if(timeNow - timerStart > timerDuration) {
    count_minutes += 1;
    if (count_minutes >= 60) {
      count_minutes = 0;
      update_time();
    }
    int tempo = 1000;
    timer_set(tempo);

    // Se 10seg se passarem e nada for pressionado estado volta para inicio
    if(modeIndex==SET_CLOCK_H || modeIndex==SET_CLOCK_M || modeIndex==SET_ALARM_H || modeIndex==SET_ALARM_M) {
      led_state = !led_state;
      counter += 1;
      if (counter > 10) {
        counter = 0;
        leds_off();
        modeIndex = CLOCK;
      }
    }

    if (modeIndex == ALARM_ON || modeIndex == ALARM) {
      if (turn_on_buzzer == true){
          // digitalWrite(BUZZ, HIGH);
          // TODO: Change buzzer ring
          //play_alarm_song();
          tone(BUZZ, 291, 500);
      }
      if (clk_h1 == alm_h1) {
        if (clk_h0 == alm_h0) {
          if (clk_m1 == alm_m1) {
            if (clk_m0 == alm_m0) {
              if (turn_on_buzzer == false) {
                buzz_ts = millis();
                turn_on_buzzer = true;
                music_note = 0;
                // TODO: Change buzzer ring;
                //play_alarm_song();
                tone(BUZZ, 342, 500);
              }
            }
          }
        }
      }
    }
    else {
      turn_on_buzzer = false;
    }
    digitalWrite(BUZZ,HIGH);
  }

  switch(modeIndex){
    case CLOCK: //mostrar horario com alarme desligado
      digitalWrite(LED1, LOW);
      show_time(clk_h1, clk_h0, clk_m1, clk_m0);
      break;
    case ALARM_ON: // mostrar horario com alarme ligado
      digitalWrite(LED2, LOW);
      show_time(clk_h1, clk_h0, clk_m1, clk_m0);
      break;
    case ALARM: //mostrar horario do alarme
      digitalWrite(LED1, LOW);
      digitalWrite(LED2, LOW);
      show_time(alm_h1, alm_h0, alm_m1, alm_m0);
      break;
    case SET_CLOCK_H:
      digitalWrite(LED1, led_state);
      digitalWrite(LED3, led_state);
      show_time(clk_h1, clk_h0, clk_m1, clk_m0);
      break;
    case SET_CLOCK_M:
      digitalWrite(LED1, led_state);
      digitalWrite(LED4, led_state);
      show_time(clk_h1, clk_h0, clk_m1, clk_m0);
      break;
    case SET_ALARM_H:
      digitalWrite(LED2, led_state);
      digitalWrite(LED3, led_state);
      show_time(alm_h1, alm_h0, alm_m1, alm_m0);
      break;
    case SET_ALARM_M:
      digitalWrite(LED2, led_state);
      digitalWrite(LED4, led_state);
      show_time(alm_h1, alm_h0, alm_m1, alm_m0);
      break;
  }
  digitalWrite(BUZZ,HIGH);
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

void goto_next_mode() {
  leds_off();
  modeIndex = modeIndex + 1;
  if ((modeIndex < 21) || (modeIndex > 27)) {
    modeIndex = 21;
  }
}

void update_clk_min() {
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
    clk_h0 = 0;
    clk_h1 = 0;
  }
  else if (clk_h0 >= 10) {
    clk_h0 = 0;
    clk_h1 += 1;
  }
}

void update_clk_hour() {
  clk_h0 += 1;
  if (clk_h1 == 2 && clk_h0 >= 4) {
    clk_h0 = 0;
    clk_h1 = 0;
  }
  else if (clk_h0 >= 10) {
    clk_h0 = 0;
    clk_h1 += 1;
  }
}

void update_alm_min() {
  alm_m0 += 1;
  if (alm_m0 >= 10) {
    alm_m0 = 0;
    alm_m1 += 1;
  }
  if (alm_m1 >= 6) {
    alm_m1 = 0;
    alm_h0 += 1;
  }
  if (alm_h1 == 2 && alm_h0 >= 4) {
    alm_h0 = 0;
    alm_h1 = 0;
  }
  else if (alm_h0 >= 10) {
    alm_h0 = 0;
    alm_h1 += 1;
  }
}

void update_alm_hour() {
  alm_h0 += 1;
  if (alm_h1 == 2 && alm_h0 >= 4) {
    alm_h0 = 0;
    alm_h1 = 0;
  }
  else if (alm_h0 >= 10) {
    alm_h0 = 0;
    alm_h1 += 1;
  }
}
