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
const uint8_t MAX_NEIGHBORS = 5;


const uint8_t edgeList[][2] PROGMEM = {
  {0,1},{0,2},{0,3},{0,4},{0,5},
  {1,2},{2,3},{3,4},{4,5},{5,1},
  {6,7},{7,8},{8,9},{9,10},{10,6},
  {11,6},{11,7},{11,8},{11,9},{11,10},
  {1,6},{2,7},{3,8},{4,9},{5,10},
  {1,7},{2,8},{3,9},{4,10},{5,6}
};

const uint8_t EDGE_COUNT = sizeof(edgeList) / sizeof(edgeList[0]);

uint8_t neighborTable[NODE_COUNT][MAX_NEIGHBORS];
uint8_t neighborCount[NODE_COUNT] = {};

#define STEP_MS      1500    // time each light spends on a spike; both move together
#define TAIL_LENGTH  5
#define FADE_ON_MS   750     // how long a light takes to swell up on a new spike
#define PURPLE_RED   160     // how much red goes into the purple when the heads collide

#define RED_LIGHT  0
#define BLUE_LIGHT 1

struct Light {
  uint8_t headNode;
  uint8_t tail[TAIL_LENGTH];   // spikes it has left, newest first
  uint8_t tailLen;
};

Light lights[2] = {
  {0},    // red starts at the top
  {11}    // blue starts at the bottom
};

unsigned long nextStep = 0;

// Position of a spike in a light's tail, or -1 if it isn't in it
int8_t tailIndexOf(uint8_t index, uint8_t node) {
  Light &l = lights[index];
  for (uint8_t t = 0; t < l.tailLen; t++) {
    if (l.tail[t] == node) {
      return t;
    }
  }
  return -1;
}

void stepLight(uint8_t index) {
  Light &l = lights[index];

  // Prefer spikes its own tail isn't on; if they're all taken, go to the oldest tail spike
  uint8_t freeChoices[MAX_NEIGHBORS];
  uint8_t freeCount = 0;
  uint8_t oldestNode = neighborTable[l.headNode][0];
  int8_t oldestIndex = -1;

  for (uint8_t slot = 0; slot < neighborCount[l.headNode]; slot++) {
    uint8_t neighbor = neighborTable[l.headNode][slot];
    int8_t tailIndex = tailIndexOf(index, neighbor);
    if (tailIndex < 0) {
      freeChoices[freeCount++] = neighbor;
    } else if (tailIndex > oldestIndex) {
      oldestIndex = tailIndex;
      oldestNode = neighbor;
    }
  }

  uint8_t choice = freeCount > 0 ? freeChoices[random(freeCount)] : oldestNode;

  // The head is moving onto part of its own tail, so the tail ends just before it
  int8_t hit = tailIndexOf(index, choice);
  if (hit >= 0) {
    l.tailLen = hit;
  }

  // Drop the spike it's leaving onto the front of the tail
  for (uint8_t t = TAIL_LENGTH - 1; t > 0; t--) {
    l.tail[t] = l.tail[t - 1];
  }
  l.tail[0] = l.headNode;
  if (l.tailLen < TAIL_LENGTH) {
    l.tailLen++;
  }

  l.headNode = choice;
}

void setup() {
  Serial.begin(9600);
  strip.begin();
  strip.setBrightness(80);
  strip.show();
  randomSeed(esp_random());

  // Build the neighbor table from the edge list
  for (uint8_t edgeIndex = 0; edgeIndex < EDGE_COUNT; edgeIndex++) {
    uint8_t nodeA = pgm_read_byte(&edgeList[edgeIndex][0]);
    uint8_t nodeB = pgm_read_byte(&edgeList[edgeIndex][1]);

    neighborTable[nodeA][neighborCount[nodeA]] = nodeB;
    neighborCount[nodeA] = neighborCount[nodeA] + 1;

    neighborTable[nodeB][neighborCount[nodeB]] = nodeA;
    neighborCount[nodeB] = neighborCount[nodeB] + 1;
  }
}

void loop()
{
  unsigned long now = millis();

  if (now >= nextStep) {
    stepLight(RED_LIGHT);
    stepLight(BLUE_LIGHT);
    nextStep = now + STEP_MS;
  }

  // Brightness of each color on each spike
  uint8_t levels[2][NODE_COUNT] = {};

  // Each tail spike fades smoothly from the moment the head leaves it,
  // reaching zero just as it would drop off the end of the tail
  unsigned long phase = STEP_MS - (nextStep - now);
  unsigned long fadeTime = (unsigned long)TAIL_LENGTH * STEP_MS;
  for (uint8_t i = 0; i < 2; i++) {
    for (uint8_t t = 0; t < lights[i].tailLen; t++) {
      unsigned long age = t * STEP_MS + phase;
      uint8_t level = map(min(age, fadeTime), 0, fadeTime, 255, 0);
      uint8_t node = lights[i].tail[t];
      levels[i][node] = max(levels[i][node], level);
    }
  }

  // The heads swell up on their new spikes along an S-curve: slow start, quick middle, soft landing
  float x = min(phase, (unsigned long)FADE_ON_MS) / (float)FADE_ON_MS;
  uint8_t headLevel = (1.0 - cos(x * PI)) / 2.0 * 255;
  // A head crossing the other color's tail mixes with it rather than covering it
  for (uint8_t i = 0; i < 2; i++) {
    levels[i][lights[i].headNode] = headLevel;
  }

  for (uint8_t nodeIndex = 0; nodeIndex < NODE_COUNT; nodeIndex++) {
    uint8_t red = levels[RED_LIGHT][nodeIndex];
    uint8_t blue = levels[BLUE_LIGHT][nodeIndex];
    if (red > 0 && blue > 0) {
      red = (uint16_t)red * PURPLE_RED / 255;   // both colors here, so tone the red down into purple
    }
    setGroup(groups[nodeIndex], strip.Color(strip.gamma8(red), 0, strip.gamma8(blue)));
  }

  strip.show();
}
