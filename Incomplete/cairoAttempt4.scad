sqrt3 = sqrt(3);

scaleFactor = 10;
offsetValue = -0.009;


// --------------------
// Pentagon 1 points
// --------------------
pentagon1_pts = [
    [0, 0.5 * (1 + sqrt3)],
    [0.5 * (sqrt3 - 1) + cos(60), sin(60)],
    [0.5 * (sqrt3 - 1), 0],
    [-0.5 * (sqrt3 - 1), 0],
    [-0.5 * (sqrt3 - 1) - cos(60), sin(60)]
];

// --------------------
// Pentagon 2 points
// --------------------
pentagon2_pts = [
    [0.5 * (sqrt3 - 1), 0],
    [0.5 * (sqrt3 - 1) + cos(60), sin(60)],
    [sqrt3, 0.5 * (sqrt3 - 1)],
    [sqrt3, 0.5 * (-sqrt3 + 1)],
    [0.5 * (sqrt3 - 1) + cos(60), -sin(60)]
];


// --------------------
// Helper modules
// --------------------
module pentagon1() {
    polygon(points = pentagon1_pts);
}

module pentagon2() {
    polygon(points = pentagon2_pts);
}

module pentagon1_offset() {
    offset(delta = offsetValue * scaleFactor)
        pentagon1();
}

module pentagon2_offset() {
    offset(delta = offsetValue * scaleFactor)
        pentagon2();
}

module pentagon1_pair() {
    pentagon1_offset();
    mirror([0, 1, 0])
        pentagon1_offset();
}

module pentagon2_pair() {
    pentagon2_offset();
    mirror([1, 0, 0])
        pentagon2_offset();
}


// --------------------
// Main module
// --------------------
module pentagon_pattern() {
    pentagon1_pair();
    pentagon2_pair();
}

module tile_array() {
    for (i = [-10:1:10]) {
        for (j = [-10:1:10]) {

            stagger = (i % 2) * sqrt3;

            translate([
                i * sqrt3 * scaleFactor,
                (j * 2 * sqrt3 + stagger) * scaleFactor
            ])
            scale(scaleFactor)
                pentagon_pattern();
        }
    }
}

// --------------------
// Render
// --------------------


base = 150;
phi = (1 + sqrt(5)) / 2;
holeGap = 8;

leftBase = [-base/2, 0];
rightBase = [base/2, 0];
side = phi * base;
height = sqrt(side*side - (base/2)*(base/2));
apex = [0, height];

module GoldenTriangle()
{
    polygon(points = [leftBase, rightBase, apex]);
}

difference()
{
    GoldenTriangle();
    intersection()
    {
        offset(delta = -12) GoldenTriangle();
        tile_array();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}