base = 150;
phi = (1 + sqrt(5)) / 2;
side = phi * base;
height = sqrt(side*side - (base/2)*(base/2));
holeGap = 8;

leftBase = [-base/2, 0];
rightBase = [base/2, 0];
apex = [0, height];

tilingRowStart = -8;
tilingRowEnd = 12;
tilingColumnStart = -15;
tilingColumnEnd = 17;

x = 1/2;
y = (1/2) * tan(30);
hyp = sqrt(x*x + y*y);

thirtyRadius = 0.24;
sixtyRadius = 0.08;
ninetyRadius = 0.16;

eps = 0.001;
patternScale = 25;

module Petal()
{
    polygon(points = [
        [0, 0],
        [x, 0],
        [x, y]
    ]);
}

module Mark()
{
    difference()
    {
        Petal();
        circle(thirtyRadius, $fn = 100);
        translate([x, 0])
            circle(ninetyRadius, $fn = 100);
        translate([x, y])
            circle(sixtyRadius, $fn = 100);
    }
}

module Flower()
{
    union()
    {
        for (i = [0:5])
        {
            rotate(i * 60)
                Mark();

            mirror([0, 1, 0])
                rotate(i * 60)
                    Mark();
        }
    }
}

module PatternArray()
{
    for (col = [tilingColumnStart : 1 : tilingColumnEnd])
    {
        for (row = [tilingRowStart : 1 : tilingRowEnd])
        {
            xOffset = (row % 2 == 0) ? x : 0;

            translate([
                col * (2 * x) + xOffset,
                row * (hyp + y)
            ])
                Flower();
        }
    }
}

module Clean2D()
{
    offset(delta = -eps)
        offset(delta = eps)
            union()
                PatternArray();
}

module ScaledPattern()
{
    scale([patternScale, patternScale])
        Clean2D();
}

module GoldenTriangle()
{
    polygon(points = [leftBase, rightBase, apex]);
}

difference()
{
    GoldenTriangle();

    difference()
    {
        offset(delta = -12)
            GoldenTriangle();

        ScaledPattern();
    }

    translate([(-base/2) + holeGap*cos(36), holeGap*sin(36)])
        circle(r = 2, $fn = 100);

    translate([(base/2) - holeGap*cos(36), holeGap*sin(36)])
        circle(r = 2, $fn = 100);

    translate([0, height - holeGap * 2])
        circle(r = 2, $fn = 100);

    polygon(points = [
        [-10, 7],
        [ 10, 7],
        [ 10, 11],
        [-10, 11]
    ]);
}