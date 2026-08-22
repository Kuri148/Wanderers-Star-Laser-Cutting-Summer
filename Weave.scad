// ----- Tiling range -----
tilingColStart = -5;
tilingColEnd   = 5;
tilingRowStart = -5;
tilingRowEnd   = 5;

// ----- Controls -----
safeScale = 200;      // Use 1 for normal OpenSCAD units, 200 for large DXF/mm export
extension = 1 / 15 ;
tileSize  = 0.94;     // spacing that works for this pattern

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

// ----- Run -----
PatternArray();