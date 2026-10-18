#include <Adafruit_NeoPixel.h>

#define LED_PIN  18
#define NUM_LEDS 36

Adafruit_NeoPixel strip(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

void setup() {
  strip.begin();
  strip.setBrightness(40);  // 0-255; keep low while on USB power
  strip.show();
}

void loop() {
  static uint16_t offset = 0;
  for (int i = 0; i < NUM_LEDS; i++) {
    uint16_t hue = offset + (i * 65536UL / NUM_LEDS);
    strip.setPixelColor(i, strip.gamma32(strip.ColorHSV(hue)));
  }
  strip.show();
  offset += 256;
  delay(20);
}