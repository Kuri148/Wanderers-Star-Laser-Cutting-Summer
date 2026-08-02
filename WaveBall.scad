// waveBall
// May 9
$fn = 30;
waveLeftmost = -8 * PI;
waveRightmost = 8 * PI;
waveResolution = .01;

arrayStart = -5;
arrayEnd = 5;

wavePoints = [
    for (i = [waveLeftmost : waveResolution : waveRightmost])
    
        [i, cos(i * 180/PI) + 2]
    ,
    for (i = [waveRightmost : -waveResolution : waveLeftmost])
    
        [i, cos(i * 180/PI) + 1.5]
    
];

module TopRowCircles()
{
    for (i = [0 : 4 : waveRightmost])
    {
        translate([i*.5*PI, 0, 0]) circle(r=1.5);
        translate([(-i*.5*PI), 0, 0]) circle(r=1.5);
    }
}

module BottomRowCircles()
{
    for (i = [1 : 4 : waveRightmost - PI])
    {
        translate([((1 + i) * .5 * PI), -3.5, 0]) circle(r=1.5);
        translate([-1 * (1 + i)*.5*PI, -3.5, 0]) circle(r=1.5);
    }
}

module CompositeRow()
{
    polygon(points = wavePoints);
    translate([PI, -3.5, 0])mirror([1,0,0]) polygon(points = wavePoints);
    BottomRowCircles();
    TopRowCircles();
}



module PatternArray()
{
    for (i = [arrayStart : 1 : arrayEnd])
    {
        translate([0, i*7, 0]) CompositeRow();
    }
}

//PatternArray();


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
        scale(5)PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}