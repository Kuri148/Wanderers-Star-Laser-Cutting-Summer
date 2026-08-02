function RotateAroundOrigin(point, rotationAngle) = [sqrt(point[0]^2 + point[1]^2) * cos(atan(point[1]/point[0]) + rotationAngle), sqrt(point[0]^2 + point[1]^2) * sin(atan(point[1]/point[0]) + rotationAngle)];

a = 1/4;      // apothem
c = sqrt(3)/6; // circumradius
s = c;        // side
hs = s/2;     // half-side

dv = -0.03;


shapePoints = [ 
for (i = [0:1:6])
    RotateAroundOrigin([c, 0], i * 60)];

module HexagonShape()
{
offset(-.05 )rotate(30)polygon(points = shapePoints);
}


qp = [
    [1/4, -sqrt(3)/12],
    [1/2, 0],
    [1/2, sqrt(3)/6],
    [1/4, sqrt(3)/4]
];

module CompositeTile()
{
    offset(delta = 0)HexagonShape();

    for (i = [0:1:5])
    {
        rotate(i * 60)
            offset(delta = dv)
                polygon(points = qp);
    }
}

module PatternArray()
{
    for (i = [-10:1:10])
    {
        for (j = [-10:1:10])
        {
            bump = i % 2 == 0 ? 0 : 1/2;

            translate([j + bump, i * sqrt(3) / 2, 0])
                CompositeTile();
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
        render()translate([0,100,0])scale(25 )PatternArray();

    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}