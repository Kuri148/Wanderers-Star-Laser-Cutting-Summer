// p4g — 4*2

rectX = 0.5;
rectY = 0.5;
epsilon = 0.0001;
$fn = 32;

module weld() {
    offset(delta = epsilon)
        children();
}

module FundamentalDomain() {
    polygon(points = [[0,0], [rectX,0], [0,rectY]]);
}

module FundamentalCut() {
    translate([.25,0,0]) circle(.1);
    translate([0,.25,0]) circle(.1);
    polygon(points = [[0,.15],[0,.35],[.25,.25]]);
}

module FundamentalRemains()
{
    difference(){FundamentalDomain();FundamentalCut();}
}

module SecondaryDomain() {
    union() {
        weld() FundamentalRemains();
        weld() mirror([1,1,0])
            translate([-rectX, -rectY, 0])
                FundamentalRemains();
    }
}

module CompiledTile() {
    render()
    union() {
        for (i = [0:1:3])
            weld() rotate(i*90) SecondaryDomain();
    }
}

module PatternArray() {
    render()
    union() {
        for (i = [-10:1:10])
            for (j = [-10:1:10])
                translate([i, j, 0])
                    CompiledTile();
    }
}

//PatternArray();
//color("green")CompiledTile();

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
