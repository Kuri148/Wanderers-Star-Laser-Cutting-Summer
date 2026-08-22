offsetValue = -0.04;

s = 1 / (1 + sqrt(3));
h = sqrt(3) / (2 * (1 + sqrt(3)));
c = sqrt((s / 2)^2 + h^2);
q = s/2 + h - c;


squarePoints = [
    [s/2, s/2],
    [-s/2, s/2],
    [-s/2, -s/2],
    [s/2, -s/2]
];

hexagonPoints = [
    [s/2, s/2],
    [s/2 + h, c],
    [s/2 + 2*h, s/2],
    [s/2 + 2*h, -s/2],
    [s/2 + h, -c],
    [s/2, -s/2]
];

starPoints = [
    [s/2, s/2],
    [s/2 + h, s/2 + h - q],
    [s/2 + 2*h, s/2],
    [s/2 + h + q, s/2 + h],
    [s/2 + 2*h, s/2 + 2*h],
    [s/2 + h, s/2 + h + q],
    [s/2, s/2 + 2*h],
    [s/2 + h - q, s/2 + h]
];

module CompositeTile()
{
    offset(offsetValue)
        polygon(points = squarePoints);

    for (i = [0:1:3])
    {
        offset(delta = offsetValue)
            rotate(i * 90)
                polygon(points = hexagonPoints);

        offset(delta = offsetValue)
            rotate(i * 90)
                polygon(points = starPoints);
    }
}

module PatternArray()
{
    for (i = [0:1:10])
    {
        for (j = [-5:1:5])
        {
            translate([j, i, 0])
                CompositeTile();
        }
    }
}

//polygon(points = squarePoints);
//polygon(points = hexagonPoints);
//polygon(points = starPoints);
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
        scale(20)PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}