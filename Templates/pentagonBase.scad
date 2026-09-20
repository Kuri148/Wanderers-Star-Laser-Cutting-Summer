base = 150;
phi = (1 + sqrt(5)) / 2;
side = phi * base;
height = sqrt(side*side - (base/2)*(base/2));
apex = [0, height];

notchTop = 11;

notchTopBase = base - 2 * (notchTop/tan(72));
halfNotchTopBase = .5 * notchTopBase;

circumradius = halfNotchTopBase/cos(54);
apotheum = halfNotchTopBase * tan(54);

rectHalfW = 9;
rectHalfH = 4;

notchHome = pentR * cos(36) + rectHalfH;

leftBase = [-base/2, 0];
rightBase = [base/2, 0];

module PentagonBase()
{
rotate(90)
    circle(r = circumradius, $fn = 5);
for(i = [0: 1: 4])
{
rotate(72 * i)translate([0, -apotheum, 0])
    polygon(points = [
        [-rectHalfW, -rectHalfH],
        [ rectHalfW, -rectHalfH],
        [ rectHalfW,  rectHalfH],
        [-rectHalfW,  rectHalfH]
    ]);
}
}

difference()
{
    PentagonBase();
    translate([-5,40,0])square(10);
    translate([-5,-50,0])square(10);
}

echo(base);

/* Check against example triangle
module GoldenTriangle()
{
    polygon(points = [leftBase, rightBase, apex]);
}

color([1, 0.8, 0, 0.5])translate([0,-109,0])difference()
{
    GoldenTriangle();
    intersection()
    {
        offset(delta = -12) GoldenTriangle();
        PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}

//Pattern Code Starts Below

 g = 0.01;
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
for (i = [-10:1:10])
{
    for (j = [-5:1:6])
    {
        translate([j*scale, i*scale])scale(scale)MapleLeafTile();
    }
}
}

*/
