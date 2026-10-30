#include <Adafruit_NeoPixel.h>

#define LED_PIN  18
#define NUM_LEDS 36
#define HALF_PERIOD_MS 10   // time to go from off to full, or full to off

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

const uint8_t poleList[][2] PROGMEM = {
  {0,11},{1,9},{2,10},{3,6},{4,7},
  {5,8}
};


const uint8_t EDGE_COUNT = sizeof(edgeList) / sizeof(edgeList[0]);
const uint8_t POLE_COUNT = sizeof(poleList) / sizeof(poleList[0]);

uint8_t neighborTable[NODE_COUNT][MAX_NEIGHBORS];
uint8_t neighborCount[NODE_COUNT] = {};

uint8_t poleTable[NODE_COUNT][MAX_NEIGHBORS];
uint8_t poleCount[NODE_COUNT] = {};

void setup() {
  Serial.begin(9600);
    strip.begin();
  strip.setBrightness(80);
  strip.show();
  // Build the neighbor table from the edge list
  for (uint8_t edgeIndex = 0; edgeIndex < EDGE_COUNT; edgeIndex++) {
    uint8_t nodeA = pgm_read_byte(&edgeList[edgeIndex][0]);
    uint8_t nodeB = pgm_read_byte(&edgeList[edgeIndex][1]);

    neighborTable[nodeA][neighborCount[nodeA]] = nodeB;
    neighborCount[nodeA] = neighborCount[nodeA] + 1;

    neighborTable[nodeB][neighborCount[nodeB]] = nodeA;
    neighborCount[nodeB] = neighborCount[nodeB] + 1;
  }

    for (uint8_t poleIndex = 0; poleIndex < POLE_COUNT; poleIndex++) {
    uint8_t nodeA = pgm_read_byte(&poleList[poleIndex][0]);
    uint8_t nodeB = pgm_read_byte(&poleList[poleIndex][1]);

    poleTable[nodeA][poleCount[nodeA]] = nodeB;
    poleCount[nodeA] = poleCount[nodeA] + 1;

    poleTable[nodeB][poleCount[nodeB]] = nodeA;
    poleCount[nodeB] = poleCount[nodeB] + 1;
  }

  /*for (uint8_t nodeIndex = 0; nodeIndex < NODE_COUNT; nodeIndex++) {
    Serial.print(nodeIndex);
    Serial.print(": ");
    for (uint8_t neighborSlot = 0; neighborSlot < neighborCount[nodeIndex]; neighborSlot++) {
      Serial.print(neighborTable[nodeIndex][neighborSlot]);
      Serial.print(' ');
    }
    Serial.println();
  }*/
}

uint8_t colorTracker = 255;   // starts out of range so the first color is picked right away
uint16_t hue = 12000;
uint16_t hueTwo = hue - 3000;
uint16_t hueThree = hue - 6000;
uint16_t hueFour = hue -9000;

uint8_t centerNode = 1;

void loop()
{
  unsigned long cycleLength = 2UL * HALF_PERIOD_MS;
  unsigned long phase = millis() % cycleLength;
  uint8_t cycleCount = (millis() / cycleLength) % NODE_COUNT;

  // New random color each time the center node changes (LEDs are off at that moment)
  if (colorTracker != cycleCount)
  {
    hue = (hue+50)%65535;
    hueTwo = (hue-3000)%65535;
    hueThree = (hue-6000)%65535;
    hueFour = (hue-9000)%65535;
    colorTracker = cycleCount;
  }

  uint8_t level =255;
  /*if (phase < HALF_PERIOD_MS) {
    level = map(phase, 0, HALF_PERIOD_MS, 0, 255);               // grow
  } else {
    level = map(phase, HALF_PERIOD_MS, cycleLength, 255, 0);     // dim
  }*/

  uint32_t color = strip.gamma32(strip.ColorHSV(hue, 255, level));
  uint32_t colorTwo = strip.gamma32(strip.ColorHSV(hueTwo, 255, level));
  uint32_t colorThree = strip.gamma32(strip.ColorHSV(hueThree, 255, level));
  uint32_t colorFour = strip.gamma32(strip.ColorHSV(hueFour, 255, level));

  /*for (uint8_t nodeIndex = 0; nodeIndex < NODE_COUNT; nodeIndex++) {
    setGroup(groups[nodeIndex], off);
  }*/

  setGroup(groups[centerNode], color);
  for (uint8_t slot = 0; slot < neighborCount[centerNode]; slot++) {
    setGroup(groups[neighborTable[centerNode][slot]], colorTwo);
  }
  setGroup(groups[poleTable[centerNode][0]], colorFour);
  for (uint8_t slot = 0; slot < neighborCount[poleTable[centerNode][0]]; slot++) {
    setGroup(groups[neighborTable[poleTable[centerNode][0]][slot]], colorThree);
  }


  strip.show();
}