#include <Adafruit_NeoPixel.h>

#define LED_PIN  18
#define NUM_LEDS 36

Adafruit_NeoPixel strip(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

uint32_t off = strip.Color(0, 0, 0);

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

const uint8_t NODE_COUNT = 12;

#define HUE          5500    // front half color (0 red, 4000 orange, 10923 yellow, 21845 green, 43690 blue)
#define BACK_HUE     49000   // back half color (49000 purple)
#define BRIGHTNESS   100     // overall strip brightness; the front half runs at this
#define BACK_SCALE   0.8     // back half runs at this share of it, so the front stands out
#define ROLL_MS      12000   // time for the front half to roll once around the middle
#define TUMBLE_MS    29000   // time for it to tip up over the top and down under the bottom
#define TILT_MAX     1.2     // how far it tips toward the top/bottom (radians, 1.57 = straight over)
#define EDGE         0.12    // spikes this close to the dividing line blend the two colors
#define MIN_LEVEL    40      // brightness of the dimmest spike at the edge of each half

// Where each spike points, as a unit vector. 0 is the top, 1-5 the upper ring,
// 6-10 the lower ring (each sitting between two upper spikes), 11 the bottom.
float spikeDir[NODE_COUNT][3];

void setup() {
  Serial.begin(9600);
  strip.begin();
  strip.setBrightness(BRIGHTNESS);
  strip.show();

  float ringZ = 1.0 / sqrt(5.0);       // icosahedron rings sit at this height
  float ringR = 2.0 / sqrt(5.0);       // and this distance from the center axis

  spikeDir[0][0] = 0;  spikeDir[0][1] = 0;  spikeDir[0][2] = 1;
  spikeDir[11][0] = 0; spikeDir[11][1] = 0; spikeDir[11][2] = -1;

  for (uint8_t k = 0; k < 5; k++) {
    float upperAngle = k * 2.0 * PI / 5.0;
    spikeDir[1 + k][0] = ringR * cos(upperAngle);
    spikeDir[1 + k][1] = ringR * sin(upperAngle);
    spikeDir[1 + k][2] = ringZ;

    float lowerAngle = upperAngle - PI / 5.0;
    spikeDir[6 + k][0] = ringR * cos(lowerAngle);
    spikeDir[6 + k][1] = ringR * sin(lowerAngle);
    spikeDir[6 + k][2] = -ringZ;
  }
}

uint32_t scaleColor(uint32_t color, float scale) {
  uint8_t r = ((color >> 16) & 0xFF) * scale;
  uint8_t g = ((color >> 8) & 0xFF) * scale;
  uint8_t b = (color & 0xFF) * scale;
  return strip.Color(r, g, b);
}

// share 0 = all of colorA, 1 = all of colorB
uint32_t blendColors(uint32_t colorA, uint32_t colorB, float share) {
  uint8_t r = ((colorA >> 16) & 0xFF) * (1 - share) + ((colorB >> 16) & 0xFF) * share;
  uint8_t g = ((colorA >> 8) & 0xFF) * (1 - share) + ((colorB >> 8) & 0xFF) * share;
  uint8_t b = (colorA & 0xFF) * (1 - share) + (colorB & 0xFF) * share;
  return strip.Color(r, g, b);
}

void loop()
{
  unsigned long now = millis();

  // The front half spins around the middle while slowly tipping up and down,
  // so over time it rolls across every part of the ball
  float spin = (now % ROLL_MS) * 2.0 * PI / ROLL_MS;
  float tilt = TILT_MAX * sin((now % TUMBLE_MS) * 2.0 * PI / TUMBLE_MS);
  float front[3] = {
    cos(spin) * cos(tilt),
    sin(spin) * cos(tilt),
    sin(tilt)
  };

  for (uint8_t nodeIndex = 0; nodeIndex < NODE_COUNT; nodeIndex++) {
    // 1 = pointing straight at the front, 0 = on the dividing line, -1 = straight at the back
    float facing = spikeDir[nodeIndex][0] * front[0]
                 + spikeDir[nodeIndex][1] * front[1]
                 + spikeDir[nodeIndex][2] * front[2];

    // Each half is brightest at its own center and dims toward the dividing line
    uint8_t level = MIN_LEVEL + (255 - MIN_LEVEL) * fabs(facing);
    uint32_t frontColor = strip.gamma32(strip.ColorHSV(HUE, 255, level));
    uint32_t backColor = scaleColor(strip.gamma32(strip.ColorHSV(BACK_HUE, 255, level)), BACK_SCALE);

    // Spikes right at the dividing line blend the two so they don't snap between colors
    float frontShare = constrain((facing + EDGE) / (2 * EDGE), 0.0, 1.0);
    setGroup(groups[nodeIndex], blendColors(backColor, frontColor, frontShare));
  }

  strip.show();
}
