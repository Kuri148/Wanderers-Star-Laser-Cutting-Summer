// p4m — *442

epsilon = 0.0001;

module weld() {
    offset(delta = epsilon)
        children();
}

module FundamentalDomain()
{
    polygon(points = [[0,0],[0.5,0],[0.5,0.5]]);
}

octagon=.1;
fourStarPit=.1;
fourStarPoint=.2;
$fn=32;
module FundamentalCut()
{
    circle(r=.2);
    polygon(points = [
        [0.5, 0],
        [.5, fourStarPit],
        [0.5-fourStarPoint, 0+fourStarPoint],
        [0.5-fourStarPit, 0]
    ]);
    polygon(points=[[.5,.5],[.5-octagon,.5-octagon],[.5,.5-2*octagon]]);
}

module FundamentalRemains()
{
    difference(){FundamentalDomain();FundamentalCut();}
}

module CompiledTile()
{
    union()
    {
        for (i = [0:1:3])
        {
            weld() rotate(i*90) union()
            {
                weld() FundamentalRemains();
                weld() mirror([0,-1,0]) FundamentalRemains();
            }
        }
    }
}

module PatternArray()
{
    for (i = [-10:1:10])
        for (j = [-10:1:10])
            translate([j, i, 0])
                CompiledTile();
}

//PatternArray();
//color("green")FundamentalRemains();

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
        render() translate([0,100,0]) scale(30) PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
}
