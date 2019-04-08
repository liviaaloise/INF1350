void timer_set(int ms);
void update_time(void);
void show_time(int h1, int h0, int m1, int m0);
void WriteNumberToSegment(byte Segment, byte Value);
void leds_off(void);
void mode(void);
void play_alarm_song(void);
void goto_next_mode(void);

// TODO: make one function (same as timer_set)
void buzzer_set(int ms);
//void but2Handler(GFButton& event);
//void but3Handler (GFButton& botaoDoEvento);
