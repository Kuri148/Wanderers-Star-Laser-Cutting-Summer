girth = 0.02;
dip = 0.1;
gap = .025;
scale = 35;
connection = .03;

module Arrows()
{
// Top left shape
polygon(points = [
    [0, 0+ connection],
    [0, 0.5],
    [-.25/2 + girth, 0.5 - dip - connection],
    [-.25/2 + girth, 0 - dip]
]);

// Left vertical
polygon(points = [
    [-.25, 0.5],
    [-.25, 0 + connection],
    [-.25/2 - girth, 0 - dip],
    [-.25/2 - girth, 0.5 - dip - connection]
]);

// Top horizontal //center slot
polygon(points = [
    [-.25/2 - girth, 0.5],
    [-.25/2 - girth, 0.5 - dip + gap],
    [-.25/2 + girth, 0.5 - dip + gap],
    [-.25/2 + girth, 0.5]
]);

// Bottom horizontal //center slot
polygon(points = [
    [-.25/2 - girth, 0 - dip - gap],
    [-.25/2 - girth, -0.5],
    [-.25/2 + girth, -0.5],
    [-.25/2 + girth, 0 - dip - gap]
]);

// Bottom left
polygon(points = [
    [0, 0 - .001],
    [0, -0.5 + connection - .001],
    [.25/2 - girth, -0.5 + connection],
    [.25/2 - girth, 0 - dip - connection]
]);

// Bottom right
polygon(points = [
    [.25, -0.5 + connection -.001],
    [.25, 0 - .001],
    [.25/2 + girth, 0 - dip - connection],
    [.25/2 + girth, -0.5 + connection]
]);

// Top center
polygon(points = [
    [0, 0.5 + connection],
    [.25/2 - girth, 0.5 + connection],
    [.25/2 - girth, 0.5 - dip]
]);

polygon (points = [
    [.25, .5 + connection],
    [.25/2 + girth, 0.5 + connection],
    [.25/2 + girth, 0.5 - dip]
]);


// Right vertical
polygon(points = [
    [.25/2 - girth, 0.5 - dip - gap],
    [.25/2 - girth, 0 - dip + gap],
    [.25/2 + girth, 0 - dip + gap],
    [.25/2 + girth, 0.5 - dip - gap]
]);
}
module PatternArray()
{
for (i = [-5:1:6])
{
    for (j = [-5:1:6])
    {
        translate([j*scale*.5, i*scale])scale(scale)Arrows();
    }
}
}
//Arrows();

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
    intersection()
    {
        offset(delta = -12) GoldenTriangle();
        render() translate([0,100,0]) scale(1.2) PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
}
