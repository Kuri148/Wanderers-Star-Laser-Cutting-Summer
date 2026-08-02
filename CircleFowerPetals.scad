base = 150;
phi = (1 + sqrt(5)) / 2;
side = phi * base;
height = sqrt(side*side - (base/2)*(base/2));
holeGap = 8;

leftBase = [-base/2, 0];
rightBase = [base/2, 0];
apex = [0, height];

tilingRowStart = 0;
tilingRowEnd = 7;
tilingColumnStart = -3;
tilingColumnEnd = 3;

x = 1/2;
y = (1/2) * tan(30);
hyp = sqrt(x*x + y*y);

sixtyRadius = 0.08;

eps = 0.001;
patternScale = 30;

function HalfPetal_f(t) = -5 * t * t + 2.75 * t - 0.26;
petalPoints = [for (t = [.072 : .001 : .427]) [t, HalfPetal_f(t)]];

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

        polygon(points = petalPoints);

        translate([x, .5 * y])
            circle(sixtyRadius, $fn = 8);
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