module PositiveTile()
{
    for (i = [0:1:2])
    {
        translate([-.5, -.5, 0])

        polygon(points = [
            [1 - i * 1/3, 1 - i * 1/3],
            [0, 1 - i * 1/3],
            [0, 5/6 - i * 1/3],
            [5/6 - i * 1/3, 5/6 - i * 1/3],
            [5/6 - i * 1/3, 0],
            [1 - i * 1/3, 0]
        ]);
    }
}

module PatternArray()
{
    for (i = [0:1:20])
    {
        for (j = [-7:1:7])
        {
            translate([j, i, 0])
                PositiveTile();
        }
    }
}

//PositiveTile();
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
    difference()
    {
        offset(delta = -12) GoldenTriangle();
        scale(15)PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}