// p4 — 442

epsilon = 0.0001;
gap = 0.1;
$fn=24;

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
    difference()
    {
        translate([.04,-.04,0])polygon(points=[[0,0],[.3,0],[.43,.43]]);
        translate([.25,.25,0])circle(r=.1);

    }
    difference()
    {
        translate([.25,.25,0])circle(r=.09);
        translate([-.01, .01])polygon(points=[[0,0],[.25,0],[.5,.5]]);
    }

    difference()
    {
       translate([-.04,.04,0])polygon(points=[[0,.0],[.0,.3],[.43,.43]]);
       translate([.25,.25,0])scale(1.3)circle(r=.1);
        
    }
    
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