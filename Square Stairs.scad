function RotateAroundOrigin(point, rotationAngle) = [sqrt(point[0]^2 + point[1]^2) * cos(atan(point[1]/point[0]) + rotationAngle), sqrt(point[0]^2 + point[1]^2) * sin(atan(point[1]/point[0]) + rotationAngle)];



startingPoint = [.7071, 0];

shapePoints = [ 
for (i = [0:1:3])
    RotateAroundOrigin(startingPoint, i * 90)];

module SquareShape()
{
offset(-.05)rotate(45)polygon(points = shapePoints);
}
echo(shapePoints);

module PatternArray()
{
for (i = [-10:1:10])
{
    for (j = [-10:1:10])
    {
        translate([j - i * .5, i + (j * .5), 0])SquareShape();
    }
}
}

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
        translate([0,50,0])scale(10)PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}