 g = 0.02;
scale = 20;
module MapleLeaf()
{
polygon(points = [
    [0 + g,      0 + g],
    [1/6,        0 + g],
    [1/6,       -1/6 + g],
    [1/3,        0 + g],
    [1/2 - g,    0 + g],
    [1/2 - g,    1/6],
    [2/3 - g,    1/3],
    [1/2 - g,    1/3],
    [1/2 - g,    1/2 - g],
    [1/3,        1/2 - g],
    [1/3,        1/3 - g],
    [1/6,        1/2 - g],
    [0 + g,      1/2 - g],
    [0 + g,      1/3],
    [1/6 + g,    1/6],
    [0 + g,      1/6]
]);
}

module MapleLeafCutter()
{
translate([-1/4, -1/6])
polygon(points = [
    [0 + g,      0 + g],
    [1/6,        0 + g],
    [1/6,       -1/6 + g],
    [1/3,        0 + g],
    [1/2 - g,    0 + g],
    [1/2 - g,    1/6],
    [2/3 - g,    1/3],
    [1/2 - g,    1/3],
    [1/2 - g,    1/2 - g],
    [1/3,        1/2 - g],
    [1/3,        1/3 - g],
    [1/6,        1/2 - g],
    [0 + g,      1/2 - g],
    [0 + g,      1/3],
    [1/6 + g,    1/6],
    [0 + g,      1/6]
]);
}

module MapleLeafTile()
{
    MapleLeaf();
    rotate(180)MapleLeaf();
}

module PatternArray()
{
for (i = [-5:1:6])
{
    for (j = [-5:1:6])
    {
        translate([j*scale, i*scale])scale(scale)MapleLeafTile();
    }
}
}

module rounded_rect_by_hull(w, h, r, $fn=64)
{
    hull()
    {
        translate([-w/2 + r, -h/2 + r]) circle(r=r, $fn=$fn);
        translate([ w/2 - r, -h/2 + r]) circle(r=r, $fn=$fn);
        translate([ w/2 - r,  h/2 - r]) circle(r=r, $fn=$fn);
        translate([-w/2 + r,  h/2 - r]) circle(r=r, $fn=$fn);
    }
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
        render() translate([0,100,0]) PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
}