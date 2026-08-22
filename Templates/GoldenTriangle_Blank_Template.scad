base = 150;
phi = (1 + sqrt(5)) / 2;
holeGap = 5;

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
    offset(delta = -10) GoldenTriangle();
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 5);
}