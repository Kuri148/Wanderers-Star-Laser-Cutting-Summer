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

PatternArray();
color("green")FundamentalRemains();