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

int music[15] = {mih, mih, fah, sol, sol, fah, mih, reh, doh, doh, reh, mih, mih, reh, reh};
int music_note = 0;

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

void timer_set(int ms) {
  timerStart = millis();
  timerDuration = (long)(unsigned)ms;
}
// ------------------------------ TODO: DEBOUNCE HANDLER
int butStates[3] = {HIGH, HIGH, HIGH};
int currentStates[3];
unsigned long buttonTime[3] = {0, 0, 0};
unsigned long debounceTime;
int buttons[3] = {KEY1, KEY2, KEY3};
// ------ TODO: DEBOUNCE HANDLER ----- Button 3
int but3_CurrState = HIGH; //current state
int but3_LastState = LOW; //last state TODO CHECK MAYBE ITS HIGH
unsigned long lastDebounceTime = 0;  // the last time the output pin was toggled
unsigned long debounceDelay = 50;    // the debounce time; increase if the output flickers
// ------------------------------ TODO: DEBOUNCE HANDLER


int modes[7] = { CLOCK, ALARM_ON , ALARM, SET_CLOCK_H, SET_CLOCK_M, SET_ALARM_H, SET_ALARM_M };
int modeIndex = 21;
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

void play_alarm_song() {
  if (music_note > sizeof(music) - 1) {
    music_note = 0;
  }
  tone(BUZZ, music[music_note], 910);
  digitalWrite(BUZZ, HIGH);
  music_note += 1;
}

/* Segment byte maps for numbers 0 to 9 */
const byte SEGMENT_MAP[] = {0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0X80, 0X90};
/* Byte maps to select digit 1 to 4 */
const byte SEGMENT_SELECT[] = {0xF1, 0xF2, 0xF4, 0xF8};

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
  int tempo = 1000; // TODO: multiplicar por 60 para fazer relogio contar 24 horas ao inves de 24min
  buzz_td = sizeof(music) * 1000;
  buzz_ts = 0;
  timer_set(tempo);
}
// END OF SETUP

/* Main program */
void loop() {
  digitalWrite(BUZZ, HIGH);

  //TODO: Fix debounce for all keys using an array
  int but1 = digitalRead(KEY1);
  int but2 = digitalRead(KEY2);
  int but3 = digitalRead(KEY3);
  int read_buttons[2] = {but1, but2}; //TODO: Fix debounce for all buttons


  if ((buzz_ts != 0) && (timeNow - buzz_ts >= buzz_td)) {
    turn_on_buzzer = false;
    digitalWrite(BUZZ, HIGH);
    music_note = 0;
  }

  for (int i = 0; i < 3; i++) {
    currentStates[i] = digitalRead(buttons[i]);
    if ((currentStates[i] == LOW) && (butStates[i] == HIGH)) {
      butStates[i] = LOW;
      buttonTime[i] = millis();
    }

    timeNow = millis();

    if ((timeNow - lastDebounceTime) > debounceDelay){
    //BUT 3
    int but3 = digitalRead(KEY3);
      if (but3 != currentStates[2]) {
        currentStates[2] = but3;
        if (but3 == HIGH) {
          goto_next_mode();
        }
      }
      //BUT1+3
      int but1 = digitalRead(KEY1);
      if (but3 && but1) {
        leds_off();
        modeIndex = 21;
      }

    }

  }

  
  //TODO: Fix debounce for all keys using an array

  timeNow = millis();
  if (timeNow - timerStart >= timerDuration) {
    if (turn_on_buzzer == true) {
      digitalWrite(BUZZ, HIGH);
      play_alarm_song();
      digitalWrite(BUZZ, HIGH);
    }
    update_time();
    int tempo = 1000;
    timer_set(tempo);

    // TODO: adicionar ifs para ver horas quando fizer versao final do relogio contando 24horas ao inves de 24min
    if (modeIndex == ALARM_ON || modeIndex == ALARM) {
      if (clk_m1 == alm_m1) {
        if (clk_m0 == alm_m0) {
          buzz_ts = millis();
          turn_on_buzzer = true;
          play_alarm_song();
        }
      }
    }
    else {
      turn_on_buzzer = false;
      digitalWrite(BUZZ, HIGH);
      music_note = 0;
    }
  }

  modeIndex = modes[current_mode];

  switch (modeIndex) {
    case CLOCK: //mostrar horario com alarme desligado
      digitalWrite(LED1, LOW);
      show_time(clk_h1, clk_h0, clk_m1, clk_m0);
      Serial.println(modeIndex); //delete
      break;
    case ALARM_ON: // mostrar horario com alarme ligado
      digitalWrite(LED2, LOW);
      show_time(clk_h1, clk_h0, clk_m1, clk_m0);
      Serial.println(modeIndex); //delete
      break;
    case ALARM: //mostrar horario do alarme
      digitalWrite(LED1, LOW);
      digitalWrite(LED2, LOW);
      show_time(alm_h1, alm_h0, alm_m1, alm_m0);
      Serial.println(modeIndex); //delete
      break;
    case SET_CLOCK_H:
      digitalWrite(LED1, LOW);
      digitalWrite(LED3, LOW);
      show_stateN(3);
      Serial.println(modeIndex); //delete
      break;
    case SET_CLOCK_M:
      digitalWrite(LED1, LOW);
      digitalWrite(LED4, LOW);
      show_stateN(4);
      Serial.println(modeIndex); //delete
      break;
    case SET_ALARM_H:
      digitalWrite(LED2, LOW);
      digitalWrite(LED3, LOW);
      show_stateN(5);
      Serial.println(modeIndex); //delete
      break;
    case SET_ALARM_M:
      digitalWrite(LED2, LOW);
      digitalWrite(LED4, LOW);
      show_stateN(6);
      Serial.println(modeIndex); //delete
      break;
  }
  digitalWrite(BUZZ, HIGH);
}

/* Write a decimal number between 0 and 9 to one of the 4 digits of the display */
void WriteNumberToSegment(byte Segment, byte Value) {
  digitalWrite(LATCH_DIO, LOW);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[Value]);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[Segment] );
  digitalWrite(LATCH_DIO, HIGH);
}

void leds_off() {
  for (int i = 10; i < 14; i++) {
    digitalWrite(i, HIGH);
  }
}

void goto_next_mode() {
  leds_off();
  current_mode += 1;
  if (current_mode > sizeof(modes) - 1) {
    current_mode = 0;
  }
  modeIndex = modes[current_mode];
}

void show_stateN(int n) {
  WriteNumberToSegment(0 , 0);
  WriteNumberToSegment(1 , 0);
  WriteNumberToSegment(2 , 0);
  WriteNumberToSegment(3 , n);
}
