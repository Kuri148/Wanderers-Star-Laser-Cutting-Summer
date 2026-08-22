secondPoint = [8, -3];
base = .25;
lineWidth = .1;
tile_scale = 1;

function vertexSubtract(a, b) = [a[0] - b[0], a[1] - b[1]];
function vertexAdd(a, b) = [a[0] + b[0], a[1] + b[1]];

module DrawRectangle(pointA, pointB, width)
{
    halfWidth = width / 2;
    direction = vertexSubtract(pointB, pointA);
    angle = atan2(direction[1], direction[0]);

    offset = [halfWidth * cos(angle), halfWidth * sin(angle)];

    pointAOne = vertexAdd(pointA, [-offset[1],  offset[0]]);
    pointATwo = vertexAdd(pointA, [ offset[1], -offset[0]]);
    pointBOne = vertexAdd(pointB, [-offset[1],  offset[0]]);
    pointBTwo = vertexAdd(pointB, [ offset[1], -offset[0]]);

    polygon(points = [pointAOne, pointATwo, pointBTwo, pointBOne]);
}

module CairoSkeleton()
{
DrawRectangle([base, 0], [-base, 0], lineWidth);
DrawRectangle([.5, .5], [base, 0], lineWidth);
mirror([0, 1, 0])DrawRectangle([.5, .5], [base, 0], lineWidth);
mirror([1, 0, 0])DrawRectangle([.5, .5], [base, 0], lineWidth);
mirror([0, 1, 0])DrawRectangle([.5, .5], [base, 0], lineWidth);
rotate(180)DrawRectangle([.5, .5], [base, 0], lineWidth);
}

module CairoTile()
{
difference()
    {
        polygon(points = [[.5, .5], [-.5, .5], [-.5, -.5], [.5, -.5]] );
        CairoSkeleton();
    }
}
module PatternArray()
{
    for (i = [-10:1:10])
    {
        for (j = [-10:1:10])
        {

            translate([j * tile_scale, i * tile_scale])
                scale(tile_scale)
                    CairoTile();
        }
    }
}

//----------------------------

tbase = 150;
phi = (1 + sqrt(5)) / 2;
holeGap = 8;

leftBase = [-tbase/2, 0];
rightBase = [tbase/2, 0];
side = phi * tbase;
height = sqrt(side*side - (tbase/2)*(tbase/2));
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
        render()translate([0,100,0])scale(20)PatternArray();

    }
    translate([(-tbase/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(tbase/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}