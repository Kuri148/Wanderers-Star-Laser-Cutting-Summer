triangleA = [0, 0];
triangleB = [.5, 0];
triangleC = [0, .5 * tan(30)];
triangleBranchOffset = -.03;

module triangularBranch()
{
    polygon(points = [triangleA, triangleB, triangleC]);
    mirror([1, 0, 0])polygon(points = [triangleA, triangleB, triangleC]);
}

module TriangleThirds()
{
    for (i = [0:1:2])
    {
    rotate(i * 120)offset(triangleBranchOffset)translate([0, -.5 * tan(30), 0])triangularBranch();
    }
}

//TriangleThirds();

module TriangleArray()
{
    for (i = [-5:1:5])
    {
        for (j = [-10:1:10])
        {
            if ((i + j)%2 == 0) 
            {translate([.5 * j, i * .5 * tan(60)+ .5 * tan(60)-tan(30), 0])rotate(180)TriangleThirds();}
            else
            {
                translate([.5 * j, .5 * tan(60) * i, 0])TriangleThirds();
            }
        }
    }
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
    intersection()
    {
        offset(delta = -12) GoldenTriangle();
        render() translate([0,100,0]) scale(25) translate([0, .5 * tan(60)-tan(30), 0]) scale(1.31s)TriangleArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
}