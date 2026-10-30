#include <Adafruit_NeoPixel.h>

#define LED_PIN  18
#define NUM_LEDS 36

Adafruit_NeoPixel strip(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

struct Group {
  uint16_t start;
  uint16_t count;
};

Group groups[12] = {
  {0, 3},  {3, 3},  {6, 3},  {9, 3},
  {12, 3}, {15, 3}, {18, 3}, {21, 3},
  {24, 3}, {27, 3}, {30, 3}, {33, 3}
};

void setGroup(Group g, uint32_t color) {
  strip.fill(color, g.start, g.count);
}

void setup() {
  strip.begin();
  strip.setBrightness(40);
}

uint8_t stem = 0;

void loop() {

delay(9000);

uint32_t orange = strip.Color(255, 80, 0);
uint32_t green  = strip.Color(0, 255, 0);
uint32_t off = strip.Color(0, 0, 0);

for (uint8_t i = 0; i < 12; i++)
{
  if (i == stem) setGroup(groups[i], green);
  else setGroup(groups[i], off);
}
  strip.show();

stem++;
if (stem > 11) stem = 0;
}