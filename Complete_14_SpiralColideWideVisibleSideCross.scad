innerStartingRadius = 1;
outerStartingRadius = 4;
gapGrowth = 0.02;
degreesOfRevolution = 10000;
resolution = 1;

function spiralFunc(theta, radiusFromOrigin, gap) =
    let (r = radiusFromOrigin + gap * theta)
    [r * cos(theta), r * sin(theta)];

spiralPoints = [
    for (i = [0:resolution:degreesOfRevolution])
        spiralFunc(i, innerStartingRadius, gapGrowth),

    for (i = [degreesOfRevolution:-resolution:0])
        spiralFunc(i, outerStartingRadius, gapGrowth)
];

module SpiralDraw() {
    polygon(points = spiralPoints);
}

//----------------------------

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
    difference()
    {
        offset(delta = -12) GoldenTriangle();
        translate([-95, 70, 0])SpiralDraw();
        translate([95, 70,0])mirror([0,1,0])SpiralDraw();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}