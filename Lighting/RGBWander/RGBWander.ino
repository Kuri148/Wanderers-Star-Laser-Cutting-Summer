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

// Each wanderer is one bit, so the bits on a spike say which colors are sharing it
const uint8_t RED    = 1;
const uint8_t YELLOW = 2;
const uint8_t BLUE   = 4;

// Color to show for every combination of wanderers on a spike (indexed by bit mask)
uint32_t mixTable[8] = {
  strip.Color(0, 0, 0),         // nobody
  strip.Color(255, 0, 0),       // red
  strip.Color(255, 170, 0),     // yellow
  strip.Color(255, 60, 0),      // red + yellow   = orange
  strip.Color(0, 0, 255),       // blue
  strip.Color(160, 0, 255),     // red + blue     = purple
  strip.Color(0, 255, 0),       // yellow + blue  = green
  strip.Color(255, 255, 255)    // all three      = white
};

#define TRAIL_LENGTH 3

// Trail brightness, newest spike first
const uint8_t trailLevels[TRAIL_LENGTH] = {45, 30, 15};

struct Wanderer {
  uint8_t bit;
  uint8_t node;
  uint8_t prevNode;
  unsigned long stepMs;     // time spent on each spike
  unsigned long nextStep;
  uint8_t trail[TRAIL_LENGTH];   // spikes it just left, newest first
  uint8_t trailLen;
};

#define STEP_MS 3500   // time every wanderer spends on a spike; they all move together

Wanderer wanderers[3] = {
  {RED,    0,  0,  STEP_MS, 0},
  {YELLOW, 6,  6,  STEP_MS, 0},
  {BLUE,   11, 11, STEP_MS, 0}
};

#define MIN_LEVEL 50   // never fade below this, so a wanderer never fully disappears

// Grow on arrival, dim before leaving, staying between MIN_LEVEL and 255
uint8_t wandererLevel(uint8_t index, unsigned long now) {
  Wanderer &w = wanderers[index];
  unsigned long halfPeriod = w.stepMs / 2;
  unsigned long phase = now - (w.nextStep - w.stepMs);
  if (phase < halfPeriod) {
    return map(phase, 0, halfPeriod, MIN_LEVEL, 255);                // grow
  } else {
    return map(phase, halfPeriod, w.stepMs, 255, MIN_LEVEL);         // dim
  }
}

uint32_t scaleColor(uint32_t color, uint8_t level) {
  uint8_t r = ((color >> 16) & 0xFF) * level / 255;
  uint8_t g = ((color >> 8) & 0xFF) * level / 255;
  uint8_t b = (color & 0xFF) * level / 255;
  return strip.Color(r, g, b);
}

void stepWanderer(uint8_t index) {
  Wanderer &w = wanderers[index];
  // Pick a random neighbor, but don't double straight back unless there's no choice
  uint8_t choice;
  do {
    choice = neighborTable[w.node][random(neighborCount[w.node])];
  } while (choice == w.prevNode && neighborCount[w.node] > 1);

  // Drop the spike it's leaving onto the front of its trail
  for (uint8_t t = TRAIL_LENGTH - 1; t > 0; t--) {
    w.trail[t] = w.trail[t - 1];
  }
  w.trail[0] = w.node;
  if (w.trailLen < TRAIL_LENGTH) {
    w.trailLen++;
  }

  w.prevNode = w.node;
  w.node = choice;
}

bool trailContains(uint8_t index, uint8_t node) {
  Wanderer &w = wanderers[index];
  for (uint8_t t = 0; t < w.trailLen; t++) {
    if (w.trail[t] == node) {
      return true;
    }
  }
  return false;
}

// Cut a trail off at the given spike so it ends just before the spot that was stepped on
void cutTrailAt(uint8_t index, uint8_t node) {
  Wanderer &w = wanderers[index];
  for (uint8_t t = 0; t < w.trailLen; t++) {
    if (w.trail[t] == node) {
      w.trailLen = t;
      return;
    }
  }
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

  bool moved = false;
  for (uint8_t i = 0; i < 3; i++) {
    if (now >= wanderers[i].nextStep) {
      stepWanderer(i);
      wanderers[i].nextStep = now + wanderers[i].stepMs;
      moved = true;
    }
  }

  // A light landing on another color's trail wipes that whole trail out.
  // Landing on its own trail just trims it back so the spike isn't listed twice.
  if (moved) {
    for (uint8_t i = 0; i < 3; i++) {
      uint8_t node = wanderers[i].node;
      cutTrailAt(i, node);
      for (uint8_t j = 0; j < 3; j++) {
        if (j != i && trailContains(j, node)) {
          wanderers[j].trailLen = 0;
        }
      }
    }
  }

  // Draw trails first so the lights themselves paint over them
  uint8_t occupants[NODE_COUNT] = {};
  uint8_t levels[NODE_COUNT] = {};
  for (uint8_t i = 0; i < 3; i++) {
    for (uint8_t t = 0; t < wanderers[i].trailLen; t++) {
      uint8_t node = wanderers[i].trail[t];
      occupants[node] |= wanderers[i].bit;
      levels[node] = max(levels[node], trailLevels[t]);
    }
  }

  // Work out who is on each spike; a shared spike uses the brightest occupant's level
  bool lit[NODE_COUNT] = {};
  for (uint8_t i = 0; i < 3; i++) {
    uint8_t node = wanderers[i].node;
    if (!lit[node]) {
      occupants[node] = 0;
      levels[node] = 0;
      lit[node] = true;
    }
  }
  for (uint8_t i = 0; i < 3; i++) {
    uint8_t node = wanderers[i].node;
    occupants[node] |= wanderers[i].bit;
    levels[node] = max(levels[node], wandererLevel(i, now));
  }

  for (uint8_t nodeIndex = 0; nodeIndex < NODE_COUNT; nodeIndex++) {
    setGroup(groups[nodeIndex], scaleColor(mixTable[occupants[nodeIndex]], levels[nodeIndex]));
  }

  strip.show();
}
