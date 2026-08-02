// ----- Global Controls -----
$fn = 60;

safeScale = 24.4;

// ----- Rhombus Setup -----
rhombusLength = 1;
rhombusHalfLength = rhombusLength * 0.5;
rhombusHalfHeight = rhombusHalfLength * tan(30);
shrinkValue = -0.02;

// ----- Rhombus Points -----
rhombusPointsAtOrigin = [
    [ rhombusHalfLength, 0 ],
    [ 0, rhombusHalfHeight ],
    [ -rhombusHalfLength, 0 ],
    [ 0, -rhombusHalfHeight ]
];

// ----- Top Rhombus -----
module TopRhombus()
{
    translate([0, rhombusHalfHeight, 0])
        offset(delta = shrinkValue)
            polygon(points = rhombusPointsAtOrigin);
}

// ----- Left Rhombus -----
module LeftRhombus()
{
    intersection()
    {
        rotate(120)
            TopRhombus();

        rotate(25)Shading();
    }
}

// ----- Rhombus Set -----
module RhombiSet()
{
    TopRhombus();
    LeftRhombus();
}

// ----- Shading Controls -----
height = 1;
width = height;
halfHeight = height * 0.5;
halfWidth = halfHeight;

stripCount = 15;
stripWidth = width / stripCount;

// ----- Shading -----
module Shading()
{
    for (i = [0 : ceil(stripCount / 2)])
    {
        polygon(points = [
            [ -halfWidth + i * stripWidth * 2,  halfHeight ],
            [ -halfWidth + i * stripWidth * 2, -halfHeight ],
            [ -halfWidth + i * stripWidth * 2 + stripWidth, -halfHeight ],
            [ -halfWidth + i * stripWidth * 2 + stripWidth,  halfHeight ]
        ]);
    }
}

// ----- Pattern Array Controls -----
rowStart = -3;
rowEnd   = 8;
colStart = -4;
colEnd   = 4;

// ----- Pattern Array -----
module PatternArray()
{
    for (i = [rowStart : 1 : rowEnd])
    {
        for (j = [colStart : 1 : colEnd])
        {
            translate([
                j + (i % 2) * rhombusHalfLength,
                i * 3 * rhombusHalfHeight,
                0
            ])
            RhombiSet();
        }
    }
}

// ----- Golden Triangle Setup -----
base = 150;
phi = (1 + sqrt(5)) / 2;
holeGap = 8;

leftBase = [-base / 2, 0];
rightBase = [base / 2, 0];

side = phi * base;
triangleHeight = sqrt(side * side - (base / 2) * (base / 2));
apex = [0, triangleHeight];

module GoldenTriangle()
{
    polygon(points = [
        leftBase,
        rightBase,
        apex
    ]);
}

// ----- Final Cut Piece -----
render(convexity = 10)
difference()
{
    GoldenTriangle();

    intersection()
    {
        offset(delta = -12)
            GoldenTriangle();

        translate([0, 35, 0])
            scale([safeScale, safeScale, 1])
                PatternArray();
    }

    translate([
        (-base / 2) + holeGap * cos(36),
        holeGap * sin(36)
    ])
    circle(r = 2);

    translate([
        (base / 2) - holeGap * cos(36),
        holeGap * sin(36)
    ])
    circle(r = 2);

    translate([
        0,
        triangleHeight - holeGap * 2
    ])
    circle(r = 2);

    polygon(points = [
        [-10, 7],
        [10, 7],
        [10, 11],
        [-10, 11]
    ]);
}