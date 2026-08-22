offsetValue = -.1;
pit = 1/6;
arm = 1 - pit;

tristarPoints = [
  for (i = [0:1:2]) each [
    [ arm * cos(120*i), arm * sin(120*i) ],
    [ pit * cos(60+120*i), pit * sin(60+120*i) ]
  ]
];

equilateralTrianglePoints = [
  [ pit * cos(300), pit * sin(300) ],
  [ arm * cos(240), arm * sin(240) ],
  [ 1/3, -sqrt(3)/2 ]
];
  
//secondEquilateralTrianglePoints =

module CompositeTile() {
  offset(delta = offsetValue*.2)polygon(points = tristarPoints);

  for (i = [0:1:2]) {
    offset(delta = offsetValue) rotate(i*120) polygon(points = equilateralTrianglePoints);
      
    offset(delta = offsetValue) rotate(i*120) mirror ([0,1,0])polygon(points = equilateralTrianglePoints);
  }
}

module PatternArray() {
  for (i = [0-5:1:30]) {
    for (j = [-12:1:15]) {
      translate([j + i*.5, i*(sqrt(3)/2), 0]) CompositeTile();
    }
  }
}


// --- Golden Triangle ---
base    = 150;
phi     = (1 + sqrt(5)) / 2;
holeGap = 8;

leftBase  = [-base/2, 0];
rightBase = [ base/2, 0];
side      = phi * base;
height    = sqrt(side*side - (base/2)*(base/2));
apex      = [0, height];

module GoldenTriangle() {
    polygon(points = [leftBase, rightBase, apex]);
}

// --- Final output ---
difference() {
    GoldenTriangle();

    intersection() {
        offset(delta = -12) GoldenTriangle();
        render()rotate(30)scale(16) PatternArray();
    }

    translate([(-base/2) + holeGap*cos(36),  holeGap*sin(36)]) circle(r=2, $fn=100);
    translate([( base/2) - holeGap*cos(36),  holeGap*sin(36)]) circle(r=2, $fn=100);
    translate([0, height - holeGap*2])                          circle(r=2, $fn=100);

    polygon(points = [[-10,7], [10,7], [10,11], [-10,11]]);
}

