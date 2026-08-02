// ----- Triangle -----
base = 150;
phi = (1 + sqrt(5)) / 2;
side = phi * base;
height = sqrt(side*side - (base/2)*(base/2));
holeGap = 8;

leftBase = [-base/2, 0];
rightBase = [base/2, 0];
apex = [0, height];

// ----- Tiling range -----
tilingColStart = -5;
tilingColEnd   = 5;
tilingRowStart = 0;
tilingRowEnd   = 11;

// ----- Controls -----
safeScale = 25;
extension = 1 / 15;
tileSize  = 0.94;

// ----- Core points -----
p1 = [0,   1/2];
p2 = [1/2, 1/2];
p3 = [1/2, 1/3];

// ----- Direction offsets -----
downLeft  = [-extension, -extension];
upLeft    = [-extension,  extension];
upRight   = [ extension,  extension];
downRight = [ extension, -extension];

// ----- Helper -----
function vAdd(a, b) = [a[0] + b[0], a[1] + b[1]];

// ----- One expanded shape -----
module ExpandedPolyomino()
{
    polygon(points = [
        vAdd(p1, downLeft),
        vAdd(p1, upLeft),
        vAdd(p2, upRight),
        vAdd(p3, downRight),
        vAdd(p3, downLeft),
        vAdd(p2, downLeft)
    ]);
}

// ----- Ring of 4 rotated copies -----
module PolyominoRing()
{
    for (i = [0:3])
    {
        rotate(i * 90)
            rotate(-45)
                ExpandedPolyomino();
    }
}

// ----- Tiling array -----
module PatternArray()
{
    scale([safeScale, safeScale])
    {
        for (col = [tilingColStart : tilingColEnd])
        {
            for (row = [tilingRowStart : tilingRowEnd])
            {
                translate([col * tileSize, row * tileSize])
                    PolyominoRing();
            }
        }
    }
}

module GoldenTriangle()
{
    polygon(points = [leftBase, rightBase, apex]);
}

difference()
{
    GoldenTriangle();

    intersection()
    {
        offset(delta = -12)
            GoldenTriangle();

        PatternArray();
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