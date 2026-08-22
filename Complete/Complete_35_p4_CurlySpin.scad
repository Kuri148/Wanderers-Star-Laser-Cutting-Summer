// p4 — 442

epsilon = 0.0001;
gap = 0.1;

module weld() {
    offset(delta = epsilon)
        children();
}

module FundamentalDomain()
{
    polygon(points = [[0,0],[0,0.5],[0.5,0.5],[0.5,0]]);
}

module FundamentalCut()
{
    polygon(points = [
        [0, 0],                     // A
        [0.5 - gap, 0],              // B
        [0.5 - gap, 0.5 - gap],      // C
        [gap*2, 0.5 - gap],          // D
        [gap*2, 0.5 - gap*2],        // E
        [0.5 - gap*2, 0.5 - gap*2],  // F
        [0.5 - gap*2, gap],          // G
        [gap, gap],                  // H
        [gap, 0.5],                  // I
        [0, 0.5]                     // J
    ]);
}

module FundamentalRemains()
{
    difference(){FundamentalDomain();FundamentalCut();}
}

module CompiledTile()
{
    union()
    {
        weld() FundamentalRemains();
        weld() rotate(90) FundamentalRemains();
        weld() rotate(180) FundamentalRemains();
        weld() rotate(270) FundamentalRemains();
    }
}

module PatternArray()
{
    for (i = [-10:1:10])
        for (j = [-10:1:10])
            translate([i, j, 0])
                render() CompiledTile();
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
        render() translate([0,100,0]) scale(30) PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
}
