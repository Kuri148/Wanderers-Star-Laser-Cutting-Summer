function RotateAroundOrigin(point, rotationAngle) = [sqrt(point[0]^2 + point[1]^2) * cos(atan(point[1]/point[0]) + rotationAngle), sqrt(point[0]^2 + point[1]^2) * sin(atan(point[1]/point[0]) + rotationAngle)];

side = 1 / (sqrt(3) + 1);
apothem = side * sqrt(3) / 2;
circumradius = side;

startingPoint = [circumradius, 0];

shapePoints = [ 
for (i = [0:1:6])
    RotateAroundOrigin(startingPoint, i * 60)];

module HexagonShape()
{
offset(-.05 )rotate(30)polygon(points = shapePoints);
}



triangleHeight = sqrt(3) / 2 * side;

triangleTilePoints = [
    [apothem, .5 * side],
    [apothem + side, .5 * side],
    [apothem + .5 * side, .5 * side + triangleHeight]
];

module TriangleTile()
{
    for (i = [0:5])
    {
        offset(-.05) rotate(i * 60)
            polygon(points = triangleTilePoints);
    }
}

squareTilePoints = [
    [apothem, .5 * side],
    [apothem + side, .5 * side],
    [apothem + side, -.5 * side],
    [apothem, -.5 * side]
];

module SquareTile()
{
    for (i = [0:5])
    {
        offset(-.05) rotate(i * 60)
            polygon(points = squareTilePoints);
    }
}

module CompositeTile()
{
    HexagonShape();
    TriangleTile();
    SquareTile();
}

module PatternArray()
{
    for (i = [-10:1:10])
    {
        for (j = [-10:1:10])
        {
            bump = i%2==0? 0: .5;
            translate([j + bump, i*sqrt(.75), 0])
                CompositeTile();
        }
    }
}


base = 150;
phi = (1 + sqrt(5)) / 2;
holeGap = 8;

leftBase = [-base/2, 0];
rightBase = [base/2, 0];
gt_side = phi * base;
height = sqrt(gt_side*gt_side - (base/2)*(base/2));
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
        scale(20)PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}