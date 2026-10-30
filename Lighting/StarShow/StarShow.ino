#include <Adafruit_NeoPixel.h>

// ============================================================================
//  StarShow -- a light show that cycles through a set of patterns,
//  crossfading from each one into the next.
//
//  To watch just one pattern, set SOLO to its number in the show list at
//  the bottom of this file (0 = first). -1 plays the whole show.
// ============================================================================

#define SOLO -1

#define LED_PIN  18
#define NUM_LEDS 36
#define BRIGHTNESS    90
#define CROSSFADE_MS  2000   // how long one pattern takes to melt into the next

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

uint8_t poleOf[NODE_COUNT];                 // which poleList pair each spike belongs to
uint8_t hops[NODE_COUNT][NODE_COUNT];       // fewest spike-to-spike steps between any two spikes

// Where each spike points, as a unit vector. 0 is the top, 1-5 the upper ring,
// 6-10 the lower ring (each sitting between two upper spikes), 11 the bottom.
float spikeDir[NODE_COUNT][3];


// ============================================================================
//  Drawing helpers. Patterns paint into `canvas`; the director at the bottom
//  points it at one of two buffers so it can blend two patterns together.
// ============================================================================

uint32_t bufferA[NODE_COUNT];
uint32_t bufferB[NODE_COUNT];
uint32_t *canvas = bufferA;

uint32_t hsv(uint16_t hue, uint8_t sat, uint8_t val) {
  return strip.gamma32(strip.ColorHSV(hue, sat, val));
}

void paint(uint8_t node, uint32_t color) {
  canvas[node] = color;
}

uint32_t addColors(uint32_t colorA, uint32_t colorB) {
  uint16_t r = ((colorA >> 16) & 0xFF) + ((colorB >> 16) & 0xFF);
  uint16_t g = ((colorA >> 8) & 0xFF) + ((colorB >> 8) & 0xFF);
  uint16_t b = (colorA & 0xFF) + (colorB & 0xFF);
  return strip.Color(min(r, (uint16_t)255), min(g, (uint16_t)255), min(b, (uint16_t)255));
}

// Light added on top of whatever is already on the spike
void addPaint(uint8_t node, uint32_t color) {
  canvas[node] = addColors(canvas[node], color);
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

// S-curve from 0 to 1: slow start, quick middle, soft landing
float ease(float x) {
  x = constrain(x, 0.0, 1.0);
  return (1.0 - cos(x * PI)) / 2.0;
}

// How directly a spike points along a direction (1 = straight at it, -1 = straight away)
float facing(uint8_t node, float x, float y, float z) {
  return spikeDir[node][0] * x + spikeDir[node][1] * y + spikeDir[node][2] * z;
}


// ============================================================================
//  Comets: a head that hops spike to spike with a fading tail behind it.
//  Shared by the comet patterns; each pattern uses its own comet slots.
// ============================================================================

#define TAIL_MAX 8

struct Comet {
  uint8_t head;
  uint8_t tail[TAIL_MAX];   // spikes it has left, newest first
  uint8_t tailLen;
  unsigned long nextStep;
};

Comet comets[4];

void cometStart(uint8_t index, uint8_t node) {
  comets[index].head = node;
  comets[index].tailLen = 0;
  comets[index].nextStep = 0;
}

// Position of a spike in a comet's tail, or -1 if it isn't in it
int8_t tailIndexOf(uint8_t index, uint8_t node) {
  Comet &c = comets[index];
  for (uint8_t t = 0; t < c.tailLen; t++) {
    if (c.tail[t] == node) {
      return t;
    }
  }
  return -1;
}

void cometStep(uint8_t index, uint8_t maxTail) {
  Comet &c = comets[index];

  // Prefer spikes its tail isn't on; if they're all taken, go to the oldest tail spike
  uint8_t freeChoices[MAX_NEIGHBORS];
  uint8_t freeCount = 0;
  uint8_t oldestNode = neighborTable[c.head][0];
  int8_t oldestIndex = -1;

  for (uint8_t slot = 0; slot < neighborCount[c.head]; slot++) {
    uint8_t neighbor = neighborTable[c.head][slot];
    int8_t tailIndex = tailIndexOf(index, neighbor);
    if (tailIndex < 0) {
      freeChoices[freeCount++] = neighbor;
    } else if (tailIndex > oldestIndex) {
      oldestIndex = tailIndex;
      oldestNode = neighbor;
    }
  }

  uint8_t choice = freeCount > 0 ? freeChoices[random(freeCount)] : oldestNode;

  // Moving onto its own tail, so the tail ends just before it
  int8_t hit = tailIndexOf(index, choice);
  if (hit >= 0) {
    c.tailLen = hit;
  }

  for (uint8_t t = TAIL_MAX - 1; t > 0; t--) {
    c.tail[t] = c.tail[t - 1];
  }
  c.tail[0] = c.head;
  if (c.tailLen < maxTail) {
    c.tailLen++;
  }

  c.head = choice;
}

// Moves the comet along if it's time, then adds it onto the canvas.
// hueStep shifts the color a little for each spike back along the tail.
void drawComet(uint8_t index, unsigned long t, unsigned long stepMs, uint8_t maxTail,
               uint16_t hue, int16_t hueStep) {
  Comet &c = comets[index];
  while (t >= c.nextStep) {
    cometStep(index, maxTail);
    c.nextStep += stepMs;
  }

  unsigned long phase = t - (c.nextStep - stepMs);
  unsigned long fadeTime = (unsigned long)maxTail * stepMs;
  for (uint8_t k = 0; k < c.tailLen; k++) {
    unsigned long age = k * stepMs + phase;
    uint8_t level = map(min(age, fadeTime), 0, fadeTime, 255, 0);
    addPaint(c.tail[k], hsv(hue - (k + 1) * hueStep, 255, level));
  }

  uint8_t headLevel = 255 * ease(phase / (stepMs / 2.0));
  addPaint(c.head, hsv(hue, 255, headLevel));
}


// ============================================================================
//  The patterns. Each has a start function (resets its state) and a render
//  function that gets the milliseconds since it started.
// ============================================================================

// ---- Rainbow Swirl: a rainbow wrapped around the star, spinning and tumbling

void swirlStart() {}

void swirlRender(unsigned long t) {
  float tumble = t / 9000.0;
  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    float x = spikeDir[n][0];
    float y = spikeDir[n][1] * cos(tumble) - spikeDir[n][2] * sin(tumble);
    float z = spikeDir[n][1] * sin(tumble) + spikeDir[n][2] * cos(tumble);
    float angle = atan2(y, x);
    uint16_t hue = (long)(angle / (2 * PI) * 65536.0 + z * 16000) + t * 8;
    paint(n, hsv(hue, 255, 255));
  }
}

// ---- Half Roll: orange half and purple half rolling around the ball

void halfRollStart() {}

void halfRollRender(unsigned long t) {
  float spin = (t % 8000) * 2.0 * PI / 8000;
  float tilt = 1.2 * sin((t % 19000) * 2.0 * PI / 19000);
  float fx = cos(spin) * cos(tilt), fy = sin(spin) * cos(tilt), fz = sin(tilt);

  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    float f = facing(n, fx, fy, fz);
    uint8_t level = 40 + 215 * fabs(f);
    uint32_t front = hsv(5500, 255, level);
    uint32_t back = scaleColor(hsv(49000, 255, level), 0.8);
    float frontShare = constrain((f + 0.12) / 0.24, 0.0, 1.0);
    paint(n, blendColors(back, front, frontShare));
  }
}

// ---- Rainbow Comet: one comet with a tail that runs back through the rainbow

void cometPatternStart() {
  cometStart(3, 0);
}

void cometPatternRender(unsigned long t) {
  drawComet(3, t, 380, 7, t * 6, 2500);
}

// ---- Twinkle: a calm deep-sea glow with white sparkles popping and fading

#define SPARK_MS 700

long sparkAt[NODE_COUNT];
unsigned long nextSpark;

void twinkleStart() {
  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    sparkAt[n] = -100000;
  }
  nextSpark = 0;
}

void twinkleRender(unsigned long t) {
  if (t >= nextSpark) {
    sparkAt[random(NODE_COUNT)] = t;
    nextSpark = t + random(90, 260);
  }

  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    uint16_t baseHue = 38000 + n * 700 + 3000 * sin(t / 3000.0 + n);
    uint32_t base = hsv(baseHue, 255, 70);
    long age = (long)t - sparkAt[n];
    float spark = age < SPARK_MS ? 1.0 - age / (float)SPARK_MS : 0.0;
    paint(n, blendColors(base, strip.Color(255, 255, 255), spark * spark));
  }
}

// ---- Pole Spin: the six pole-pair colors stepping around the 0-11 axis

#define SPIN_STEP_MS 1500
#define SPIN_MOVE_MS 600

void poleSpinStart() {}

// Which spike's color has rotated into this spike after a number of steps
uint8_t spunFrom(uint8_t node, long steps) {
  if (node == 0 || node == 11) {
    return node;
  }
  uint8_t ringStart = node <= 5 ? 1 : 6;
  long k = node - ringStart;
  return ringStart + (((k - steps) % 5) + 5) % 5;
}

void poleSpinRender(unsigned long t) {
  long steps = t / SPIN_STEP_MS;
  float share = ease((t % SPIN_STEP_MS) / (float)SPIN_MOVE_MS);
  uint16_t drift = t * 2;   // let the whole palette slowly drift too

  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    uint32_t before = hsv(poleOf[spunFrom(n, steps - 1)] * 10923 + drift, 255, 255);
    uint32_t after = hsv(poleOf[spunFrom(n, steps)] * 10923 + drift, 255, 255);
    paint(n, blendColors(before, after, share));
  }
}

// ---- Ripples: rings of color bursting out from random spikes and overlapping

#define RIPPLE_SLOTS   4
#define RIPPLE_RING_MS 330    // time for a ripple to spread one more spike outward
#define RIPPLE_LIFE_MS 3000

struct Ripple {
  uint8_t origin;
  long start;
  uint16_t hue;
};

Ripple ripples[RIPPLE_SLOTS];
unsigned long nextRipple;
uint8_t nextRippleSlot;

void rippleStart() {
  for (uint8_t i = 0; i < RIPPLE_SLOTS; i++) {
    ripples[i].start = -100000;
  }
  nextRipple = 0;
  nextRippleSlot = 0;
}

void rippleRender(unsigned long t) {
  if (t >= nextRipple) {
    ripples[nextRippleSlot].origin = random(NODE_COUNT);
    ripples[nextRippleSlot].start = t;
    ripples[nextRippleSlot].hue = random(65536);
    nextRippleSlot = (nextRippleSlot + 1) % RIPPLE_SLOTS;
    nextRipple = t + random(900, 1600);
  }

  for (uint8_t i = 0; i < RIPPLE_SLOTS; i++) {
    long age = (long)t - ripples[i].start;
    if (age >= RIPPLE_LIFE_MS) {
      continue;
    }
    float front = age / (float)RIPPLE_RING_MS;
    float life = 1.0 - age / (float)RIPPLE_LIFE_MS;

    for (uint8_t n = 0; n < NODE_COUNT; n++) {
      float behind = front - hops[ripples[i].origin][n];   // how long ago the ring passed this spike
      float glow;
      if (behind < -0.5) {
        glow = 0;                          // ring hasn't reached it yet
      } else if (behind < 0) {
        glow = 1.0 + behind * 2;           // ring arriving
      } else {
        glow = exp(-behind * 1.3);         // ring passed, glow dies away
      }
      addPaint(n, hsv(ripples[i].hue, 230, 255 * glow * life));
    }
  }
}

// ---- Plasma: liquid, ever-shifting color made from overlapping waves

void plasmaStart() {}

void plasmaRender(unsigned long t) {
  float s = t / 1000.0;
  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    float x = spikeDir[n][0], y = spikeDir[n][1], z = spikeDir[n][2];
    float v = sin(x * 2.5 + s * 1.1) + sin(y * 2.5 - s * 0.8)
            + sin(z * 3.0 + s * 1.4) + sin((x - y + z) * 2.0 + s * 0.6);
    uint16_t hue = (long)((v + 4) / 8.0 * 98304) + t * 3;
    uint8_t level = 150 + 105 * sin(v * 1.5 + s);
    paint(n, hsv(hue, 255, level));
  }
}

// ---- Color Chase: red, green and blue comets whose light adds where they cross
//      (red + green = yellow, red + blue = magenta, green + blue = cyan, all three = white)

void chaseStart() {
  cometStart(0, 0);
  cometStart(1, 8);
  cometStart(2, 4);
}

void chaseRender(unsigned long t) {
  drawComet(0, t, 600, 4, 0, 0);
  drawComet(1, t, 600, 4, 21845, 0);
  drawComet(2, t, 600, 4, 43690, 0);
}

// ---- Scanner: a band of light sweeping back and forth through the ball
//      while the direction it sweeps in slowly turns

void scannerStart() {}

void scannerRender(unsigned long t) {
  float turn = t / 7000.0;
  float lean = 0.7 * sin(t / 11000.0);
  float ax = cos(turn) * cos(lean), ay = sin(turn) * cos(lean), az = sin(lean);

  float band = 1.05 * sin(t * 2.0 * PI / 2200);
  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    float off = (facing(n, ax, ay, az) - band) / 0.35;
    float glow = exp(-off * off);
    uint32_t background = hsv(45000, 255, 35);
    paint(n, addColors(background, hsv(30000 - 6000 * glow, 200, 255 * glow)));
  }
}

// ---- Fire: heat bubbles up from the bottom spike and flickers out toward the top

float heat[NODE_COUNT];
unsigned long nextFireUpdate;

// Bottom first, so heat can climb up through the rings in a single pass
const uint8_t fireOrder[NODE_COUNT] = {11, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 0};

void fireStart() {
  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    heat[n] = 0;
  }
  nextFireUpdate = 0;
}

uint32_t heatColor(float h) {
  float h3 = constrain(h, 0.0, 1.0) * 3;
  if (h3 < 1) {
    return strip.Color(255 * h3, 0, 0);                        // black to red
  } else if (h3 < 2) {
    return strip.Color(255, 140 * (h3 - 1), 0);                // red to orange
  } else {
    return strip.Color(255, 140 + 100 * (h3 - 2), 60 * (h3 - 2));   // orange to yellow-white
  }
}

void fireRender(unsigned long t) {
  while (t >= nextFireUpdate) {
    nextFireUpdate += 45;

    for (uint8_t i = 0; i < NODE_COUNT; i++) {
      uint8_t n = fireOrder[i];

      // Pull heat up from the neighbors below this spike
      float below = 0;
      uint8_t belowCount = 0;
      for (uint8_t slot = 0; slot < neighborCount[n]; slot++) {
        uint8_t neighbor = neighborTable[n][slot];
        if (spikeDir[neighbor][2] < spikeDir[n][2] - 0.1) {
          below += heat[neighbor];
          belowCount++;
        }
      }
      if (belowCount > 0) {
        heat[n] = heat[n] * 0.45 + (below / belowCount) * 0.55;
      }

      heat[n] -= random(0, 90) / 1000.0;   // cool off a little, more toward the top
      if (spikeDir[n][2] < 0 && random(100) < 30) {
        heat[n] += random(200, 700) / 1000.0;   // new flare-ups low down
      }
      heat[n] = constrain(heat[n], 0.0, 1.0);
    }
  }

  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    paint(n, strip.gamma32(heatColor(heat[n])));
  }
}

// ---- Heartbeat: the whole star thumps lub-dub in deep red

void heartbeatStart() {}

void heartbeatRender(unsigned long t) {
  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    // The beat starts at the top and washes down a moment later
    long p = ((long)t - (long)((1.0 - spikeDir[n][2]) * 45)) % 1000;
    float lub = (p - 0) / 70.0;
    float dub = (p - 260) / 85.0;
    float beat = exp(-lub * lub) + 0.7 * exp(-dub * dub);
    beat = constrain(beat, 0.0, 1.0);
    paint(n, hsv(0, 255 - 70 * beat, 25 + 230 * beat));
  }
}


// ============================================================================
//  The show: patterns in the order they play, and how long each one runs
// ============================================================================

typedef void (*StartFunction)();
typedef void (*RenderFunction)(unsigned long);

struct Act {
  const char *name;
  StartFunction start;
  RenderFunction render;
  unsigned long durationMs;
};

Act show[] = {
  {"Rainbow Swirl", swirlStart,        swirlRender,        20000},
  {"Half Roll",     halfRollStart,     halfRollRender,     20000},
  {"Rainbow Comet", cometPatternStart, cometPatternRender, 20000},
  {"Twinkle",       twinkleStart,      twinkleRender,      20000},
  {"Pole Spin",     poleSpinStart,     poleSpinRender,     20000},
  {"Ripples",       rippleStart,       rippleRender,       20000},
  {"Plasma",        plasmaStart,       plasmaRender,       20000},
  {"Color Chase",   chaseStart,        chaseRender,        25000},
  {"Scanner",       scannerStart,      scannerRender,      20000},
  {"Fire",          fireStart,         fireRender,         20000},
  {"Heartbeat",     heartbeatStart,    heartbeatRender,    15000}
};

const uint8_t ACT_COUNT = sizeof(show) / sizeof(show[0]);

uint8_t currentAct;
uint8_t nextAct;
unsigned long currentStart;
unsigned long nextStart;
bool crossfading = false;

void renderAct(uint8_t act, unsigned long t, uint32_t *buffer) {
  canvas = buffer;
  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    canvas[n] = off;
  }
  show[act].render(t);
}

void setup() {
  Serial.begin(9600);
  strip.begin();
  strip.setBrightness(BRIGHTNESS);
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

  for (uint8_t poleIndex = 0; poleIndex < POLE_COUNT; poleIndex++) {
    poleOf[pgm_read_byte(&poleList[poleIndex][0])] = poleIndex;
    poleOf[pgm_read_byte(&poleList[poleIndex][1])] = poleIndex;
  }

  // Count hops between every pair of spikes by spreading out from each one
  for (uint8_t from = 0; from < NODE_COUNT; from++) {
    for (uint8_t n = 0; n < NODE_COUNT; n++) {
      hops[from][n] = 255;
    }
    hops[from][from] = 0;
    for (uint8_t distance = 0; distance < NODE_COUNT; distance++) {
      for (uint8_t n = 0; n < NODE_COUNT; n++) {
        if (hops[from][n] != distance) {
          continue;
        }
        for (uint8_t slot = 0; slot < neighborCount[n]; slot++) {
          uint8_t neighbor = neighborTable[n][slot];
          if (hops[from][neighbor] == 255) {
            hops[from][neighbor] = distance + 1;
          }
        }
      }
    }
  }

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

  currentAct = SOLO >= 0 ? SOLO : 0;
  show[currentAct].start();
  currentStart = millis();
  Serial.println(show[currentAct].name);
}

void loop()
{
  unsigned long now = millis();

  // Near the end of an act, start the next one so the two can blend
  if (SOLO < 0 && !crossfading && now - currentStart >= show[currentAct].durationMs - CROSSFADE_MS) {
    nextAct = (currentAct + 1) % ACT_COUNT;
    show[nextAct].start();
    nextStart = now;
    crossfading = true;
    Serial.println(show[nextAct].name);
  }

  renderAct(currentAct, now - currentStart, bufferA);

  if (crossfading) {
    renderAct(nextAct, now - nextStart, bufferB);
    float share = ease((now - nextStart) / (float)CROSSFADE_MS);
    for (uint8_t n = 0; n < NODE_COUNT; n++) {
      bufferA[n] = blendColors(bufferA[n], bufferB[n], share);
    }

    if (now - nextStart >= CROSSFADE_MS) {
      currentAct = nextAct;
      currentStart = nextStart;
      crossfading = false;
    }
  }

  for (uint8_t n = 0; n < NODE_COUNT; n++) {
    setGroup(groups[n], bufferA[n]);
  }

  strip.show();
}
