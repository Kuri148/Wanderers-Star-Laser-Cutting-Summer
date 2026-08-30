// Sticker Pile — a jumbled heap of overlapping shape outlines (circle, star,
// pentagon, triangle, heart, square), each drawn as a thin ring and knocked
// back by every sticker stacked on top of it, giving a layered "stained glass"
// look.
//
// The scatter is seeded so the cut is reproducible (bare rands() would
// regenerate a different pile on every open).
//
// The ring outlines form one connected web, so the golden triangle frame uses
// the nested difference() formula: the web stays as connective material and the
// gaps between/inside the stickers become the holes.

$fn = 64;

seed = 42;
N = 200;

randomCoords = [for (i = [0:1:N])                        rands(-5,   5,   3, seed*1000 + i)];
shapeTypes   = [for (i = [0:1:len(randomCoords) - 1]) round(rands( 1,   5,   1, seed*2000 + i)[0])];
rotations    = [for (i = [0:1:len(randomCoords) - 1])      rands( 0, 360,   1, seed*3000 + i)[0]];

triangle_pts = [[0, 1], [-0.866, -0.5], [0.866, -0.5]];
square_pts = [[0, 1], [-1, 0], [0, -1], [1, 0]];
pentagon_pts = [
    [0, 1],
    [-0.9511, 0.3090],
    [-0.5878, -0.8090],
    [0.5878, -0.8090],
    [0.9511, 0.3090]
];
star_pts = [
    [0, 1],
    [0.2939, 0.4045],
    [0.9511, 0.3090],
    [0.4755, -0.1545],
    [0.5878, -0.8090],
    [0, -0.5],
    [-0.5878, -0.8090],
    [-0.4755, -0.1545],
    [-0.9511, 0.3090],
    [-0.2939, 0.4045]
];
heart_pts = [
    [0, 0.257],
    [0.257, 0.686],
    [0.600, 0.772],
    [0.857, 0.514],
    [0.772, 0.086],
    [0.429, -0.429],
    [0, -0.943],
    [-0.429, -0.429],
    [-0.772, 0.086],
    [-0.857, 0.514],
    [-0.600, 0.772],
    [-0.257, 0.686]
];

module shape(type, pos, rot) {
    translate(pos) rotate(rot) {
        if (type == 1) circle(r=1);
        else if (type == 2) polygon(star_pts);
        else if (type == 3) polygon(pentagon_pts);
        else if (type == 4) polygon(triangle_pts);
        else if (type == 5) polygon(heart_pts);
        else polygon(square_pts);
    }
}

module ring(type, pos, rot) {
    difference() {
        shape(type, pos, rot);
        translate(pos) rotate(rot) scale(.8) shape(type, [0,0], 0);
    }
}

module rings(coords, types, rots, i = 0) {
    if (i < len(coords)) {
        difference() {
            ring(types[i], coords[i], rots[i]);
            union() {
                if (i < len(coords)-1)
                    for (j = [i+1 : len(coords)-1])
                        shape(types[j], coords[j], rots[j]);
            }
        }
        rings(coords, types, rots, i + 1);
    }
}

module PatternArray() {
    rings(randomCoords, shapeTypes, rotations);
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
    difference()
    {
        offset(delta = -12) GoldenTriangle();
        render() translate([0, 95, 0]) scale(15) PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)]) circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)]) circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2]) circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10, 7], [10, 11], [-10, 11]]);
}
