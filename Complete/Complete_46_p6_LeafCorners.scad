// p6 — 632

// ----------------------------------------------------------------------
// Weld amount. Each assembly step grows the 2D shape by EPS, unions, then
// shrinks back by EPS — fusing the hairline seams between assembled pieces
// without changing the outer silhouette.
//
//   Increase EPS if seams still show.
//   Decrease EPS if thin features of your cut shapes start to fill in
//     (closing fills any gap/notch narrower than ~2*EPS).
// ----------------------------------------------------------------------
EPS = 0.002;
module weld(eps = EPS) {
    offset(delta = -eps) offset(delta = eps) children();
}
module rotate_about(a, p) {
    translate(p) rotate(a) translate([-p[0], -p[1]]) children();
}

// Leaf silhouette traced from a photo (scikit/opencv contour trace,
// simplified to 44 points, normalized to a unit bounding box).
module LeafSilhouette()
{
    polygon(points = [
        [-0.04997, 0.44540],
        [-0.09762, 0.33951],
        [-0.13269, 0.32694],
        [-0.13997, 0.25414],
        [-0.18564, 0.25877],
        [-0.18498, -0.00927],
        [-0.29749, 0.06420],
        [-0.36433, 0.04236],
        [-0.50000, 0.07478],
        [-0.44639, -0.07081],
        [-0.45433, -0.12376],
        [-0.40602, -0.18134],
        [-0.30741, -0.24156],
        [-0.43845, -0.30973],
        [-0.46625, -0.34811],
        [-0.39477, -0.39775],
        [-0.34249, -0.40304],
        [-0.34116, -0.43216],
        [-0.31138, -0.44341],
        [-0.21277, -0.43415],
        [-0.03872, -0.35606],
        [0.17704, -0.44540],
        [0.29484, -0.43614],
        [0.28954, -0.39576],
        [0.37492, -0.37856],
        [0.41992, -0.33620],
        [0.34580, -0.26737],
        [0.25182, -0.23759],
        [0.42985, -0.12641],
        [0.44507, -0.08802],
        [0.42058, -0.06486],
        [0.46823, -0.01522],
        [0.50000, 0.09993],
        [0.35970, 0.08670],
        [0.29550, 0.04434],
        [0.26969, 0.08008],
        [0.24189, 0.07809],
        [0.12277, -0.01456],
        [0.14924, 0.12244],
        [0.14328, 0.25678],
        [0.07313, 0.23825],
        [0.06320, 0.34216],
        [0.02019, 0.35672],
        [-0.00033, 0.40702],
    ]);
}

// Fundamental domain corners -- a leaf inset from each one.
vertexA = [.25, sqrt(3)/12];
vertexB = [-.25, sqrt(3)/4];
vertexC = [.75, sqrt(3)/4];
centroid = (vertexA + vertexB + vertexC) / 3;
insetFrac = 0.4;
leafScale = 0.18;

module shapesToCut()
{
    translate(vertexA + insetFrac*(centroid - vertexA)) scale(leafScale) LeafSilhouette();
    translate(vertexB + insetFrac*(centroid - vertexB)) scale(leafScale) LeafSilhouette();
    translate(vertexC + insetFrac*(centroid - vertexC)) scale(leafScale) LeafSilhouette();
}
module fundamentalDomain()
{
    polygon(points = [vertexA, vertexB, vertexC]);
}
module cutFundamental()
{
    difference()
    {
        fundamentalDomain();
        shapesToCut();
    }
}
module equilateralTriangle()
{
    weld() {
        for (i = [0:1:2])
        {
            rotate_about(120*i, [.25,sqrt(3)/12]) cutFundamental();
        }
    }
}
// Step 3: the triangle plus its 180-degree copy -> parallelogram tile.
module parallelogram()
{
    weld() {
        equilateralTriangle();
        rotate(180) equilateralTriangle();
    }
}

module PatternArray()
{
    weld()
    {
        for (y = [-10:1:10])
            for (x = [-10:1:10])
                translate([x, y*(sqrt(3)/2), 0]) parallelogram();
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
    difference()
    {
        offset(delta = -12) GoldenTriangle();
        render() translate([0, 100, 0]) scale(50) PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)]) circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)]) circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2]) circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10, 7], [10, 11], [-10, 11]]);
}
