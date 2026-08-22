fieldStart = -3;
fieldEnd = 3;
$fn=32;

module pointer()
{
    scale(.7)translate([-.125, 0, 0])rotate(-90)polygon(points = [[0,.5],[.25,-.25],[0,0],[-.25,-.25]]);
}

module line(point1, point2, thickness=.1)
{
    hull()
    {
        translate(point1)circle(d=thickness);
        translate(point2)circle(d=thickness);
    }
}

module PatternArray()
{
    for (x=[fieldStart:.5:fieldEnd])
    {
        for (y=[fieldStart:.5:fieldEnd])
        {
            if (x == 0 && y == 0)
            {
                translate([x,y,0])circle(.15,center=true, $fn = 32);
            }
            else
            {
                translate([x,y,0])rotate(atan((y+x)/(x-y)))pointer();
            }
        }
    }
}

//PatternArray();
/*
// generate the row of points as a function
for (x=[-5:.1:4
    ])
{
    for (y=[-3:1:3])
    {
        line([x,x^2+y,0],[x+1,y+(x+1)^2,0],.1);
    }

}*/

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
        render() translate([0,100,0]) scale(40) PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
}
