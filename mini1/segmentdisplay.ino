/* Define shift register pins used for seven segment display */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8
 
/* Segment byte maps for numbers 0 to 9 */
const byte SEGMENT_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90};
/* Byte maps to select digit 1 to 4 */
const byte SEGMENT_SELECT[] = {0xF1,0xF2,0xF4,0xF8};

int state = 1;
int tempo = 1000;

int h1 = 1;
int h0 = 8;

int m1 = 2;
int m0 = 7;

unsigned long timeNow;
unsigned long timerStart;
unsigned long timerDuration;

void timer_set(int ms) {
  timerStart = millis();
  timerDuration = (long)(unsigned)ms;
}

void update_time() {
  m0 += 1;
  if (m0 >= 10) {
    m0 = 0;
    m1 += 1;
  }
  if (m1 >= 6) {
    m1 = 0;
    h0 += 1;
  }
  if (h1 == 2 && h0 >= 4) {
    h0 =0;
    h1 = 0;
  }
  else if (h0 >= 10) {
    h0 = 0;
    h1 += 1;
  }
}

void exibe(){
  WriteNumberToSegment(0 , h1);
  WriteNumberToSegment(1 , h0);
  WriteNumberToSegment(2 , m1);
  WriteNumberToSegment(3 , m0);
}


/* Write a decimal number between 0 and 9 to one of the 4 digits of the display */
void WriteNumberToSegment(byte Segment, byte Value) {
  digitalWrite(LATCH_DIO,LOW);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[Value]);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[Segment] );
  digitalWrite(LATCH_DIO,HIGH);
}

void setup() {
  Serial.begin(9600);
  /* Set DIO pins to outputs */
  pinMode(LATCH_DIO,OUTPUT);
  pinMode(CLK_DIO,OUTPUT);
  pinMode(DATA_DIO,OUTPUT);
  timer_set(tempo);
}
 
/* Main program */
void loop() {
//  Serial.println(String(curr_time));
  
  timeNow=millis();
  if(timeNow-timerStart>= timerDuration) {
    update_time();
    timer_set(tempo); 
  }
  exibe();
  
}

