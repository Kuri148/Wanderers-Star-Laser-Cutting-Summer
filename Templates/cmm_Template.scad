//rectX=(1/sqrt(2));
rectX=.6;
rectY=sin(acos(rectX));

echo(rectX);
echo(rectY);

$fn=16;

module FundamentalDomain()
{
    polygon(points=[[0,0],[rectX,0],[0, rectY]]);
}

module FundamentalCut()
{
    translate([.2,.2,0])circle(r=.1);
    translate([.1,.3,0])circle(r=.05);
    translate([.05,.2,0])circle(r=.025);
    translate([.5,0,0])circle(r=.25);
}

module FundamentalRemains()
{
    difference()
    {
        FundamentalDomain();
        FundamentalCut();
    }
}

FundamentalRemains();

module CompiledTile()
{
    for(h=[0:1:1])
    {
        rotate(180*h)union()
    for(i=[0:1:1])
    {
        rotate(180*i)mirror([0,-1*i,0])FundamentalRemains();
    }
}
}

module PatternArray()
{
    for(i=[-10:1:10])
    {
        for(j=[-10:1:10])
        {
            translate([j*rectX*2+(rectX*(i%2)), i*rectY, 0])CompiledTile();
        }
    }
}

module weld(eps = 0.001) {
    offset(delta = -eps) offset(delta = eps) children();
}
weld()PatternArray();
color("green")FundamentalRemains();