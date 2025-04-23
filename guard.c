#define rd 5
#define rq 6
#define ak 7
#define D  8

#include "PW.h"
// #define debug

boolean done;

void setup() {
    pinMode(rd, OUTPUT);
    pinMode(rq, INPUT);
    pinMode(ak, OUTPUT);
    pinMode(D, INPUT);

    digitalWrite(rd, LOW);
    digitalWrite(rq, LOW);
    digitalWrite(ak, LOW);
    digitalWrite(D, LOW);

    done = false;

#ifdef debug
    Serial.begin(9600);
#endif
}

void loop() {
    if (!done)
        layer3();
}

byte layer1(void) {
    int din;

    while (digitalRead(rq) != HIGH)
        continue;

#ifdef debug
    delay(10);
#endif

    digitalWrite(ak, HIGH);
    din = digitalRead(D);
    digitalWrite(ak, LOW);

    while (digitalRead(rq) == HIGH)
        continue;

#ifdef debug
    delay(10);
#endif

    return (din == HIGH ? 1 : 0);
}

unsigned int layer2(void) {
    unsigned int din = 0;

    digitalWrite(rd, HIGH);

    for (int i = 0; i < 16; i++) {
        din = (din << 1) & 0xFFFE | layer1();
    }

#ifdef debug
    Serial.println(din);
#endif

    digitalWrite(rd, LOW);
    return din;
}

void layer3(void) {
    unsigned int din;
    din = layer2();

    if (din == PW)
        done = true;
}
