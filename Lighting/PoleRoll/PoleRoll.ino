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

const uint8_t poleList[][2] PROGMEM = {
  {0,11},{1,9},{2,10},{3,6},{4,7},
  {5,8}
};

const uint8_t POLE_COUNT = sizeof(poleList) / sizeof(poleList[0]);

// One color per pole pair: red, yellow, green, cyan, blue, magenta
const uint16_t poleHues[POLE_COUNT] = {0, 10923, 21845, 32768, 43690, 54613};

#define BRIGHTNESS  80
#define STEP_MS     2500    // time between rolls, including the move itself
#define MOVE_MS     800     // how long each roll takes to slide colors onto their new spikes
#define ROLL_POLE   0       // which poleList pair it rolls around (0 = spikes 0 and 11)
#define ROLL_DIRECTION 1    // 1 or -1 to roll the other way

// Where each spike points, as a unit vector. 0 is the top, 1-5 the upper ring,
// 6-10 the lower ring (each sitting between two upper spikes), 11 the bottom.
float spikeDir[NODE_COUNT][3];

uint32_t poleColor[POLE_COUNT];

uint8_t colorOf[NODE_COUNT];       // which pole color each spike shows now
uint8_t prevColorOf[NODE_COUNT];   // and what it showed before the latest roll
unsigned long lastStep = 0;

// Spike closest to a direction
uint8_t nearestSpike(float x, float y, float z) {
  uint8_t best = 0;
  float bestDot = -2;
  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    float dot = spikeDir[n][0] * x + spikeDir[n][1] * y + spikeDir[n][2] * z;
    if (dot > bestDot) {
      bestDot = dot;
      best = n;
    }
  }
  return best;
}

// Turn the whole color pattern one notch (a fifth of a turn) around the ROLL_POLE pair.
// The two spikes on that pole keep their color; every other color moves to a neighboring spike.
void roll() {
  uint8_t axisNode = pgm_read_byte(&poleList[ROLL_POLE][0]);
  float ax = spikeDir[axisNode][0], ay = spikeDir[axisNode][1], az = spikeDir[axisNode][2];
  float angle = ROLL_DIRECTION * 2.0 * PI / 5.0;
  float c = cos(angle), s = sin(angle);

  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    prevColorOf[n] = colorOf[n];
  }

  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    // Rotate this spike's direction around the pole axis to see where its color lands
    float vx = spikeDir[n][0], vy = spikeDir[n][1], vz = spikeDir[n][2];
    float along = ax * vx + ay * vy + az * vz;
    float cx = ay * vz - az * vy, cy = az * vx - ax * vz, cz = ax * vy - ay * vx;
    float rx = vx * c + cx * s + ax * along * (1 - c);
    float ry = vy * c + cy * s + ay * along * (1 - c);
    float rz = vz * c + cz * s + az * along * (1 - c);

    colorOf[nearestSpike(rx, ry, rz)] = prevColorOf[n];
  }
}

// share 0 = all of colorA, 1 = all of colorB
uint32_t blendColors(uint32_t colorA, uint32_t colorB, float share) {
  uint8_t r = ((colorA >> 16) & 0xFF) * (1 - share) + ((colorB >> 16) & 0xFF) * share;
  uint8_t g = ((colorA >> 8) & 0xFF) * (1 - share) + ((colorB >> 8) & 0xFF) * share;
  uint8_t b = (colorA & 0xFF) * (1 - share) + (colorB & 0xFF) * share;
  return strip.Color(r, g, b);
}

void setup() {
  Serial.begin(9600);
  strip.begin();
  strip.setBrightness(BRIGHTNESS);
  strip.show();
  randomSeed(esp_random());

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

  // Both spikes of a pole pair start with that pair's color
  for (uint8_t poleIndex = 0; poleIndex < POLE_COUNT; poleIndex++) {
    poleColor[poleIndex] = strip.gamma32(strip.ColorHSV(poleHues[poleIndex], 255, 255));
    colorOf[pgm_read_byte(&poleList[poleIndex][0])] = poleIndex;
    colorOf[pgm_read_byte(&poleList[poleIndex][1])] = poleIndex;
  }
  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    prevColorOf[n] = colorOf[n];
  }
}

void loop()
{
  unsigned long now = millis();

  if (now - lastStep >= STEP_MS) {
    roll();
    lastStep = now;
  }

  // Slide from the old colors to the new ones along an S-curve, then hold until the next roll
  float x = min(now - lastStep, (unsigned long)MOVE_MS) / (float)MOVE_MS;
  float share = (1.0 - cos(x * PI)) / 2.0;

  for (uint8_t nodeIndex = 0; nodeIndex < NODE_COUNT; nodeIndex++) {
    setGroup(groups[nodeIndex], blendColors(poleColor[prevColorOf[nodeIndex]],
                                            poleColor[colorOf[nodeIndex]], share));
  }

  strip.show();
}
