// p31m — 3*3

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
module reflect_line(theta, p) {
    translate(p) rotate(theta) mirror([0,1,0]) rotate(-theta) translate([-p[0], -p[1]]) children();
}

// Simple chunky pointing-hand silhouette (fist + one extended finger),
// redrawn thick so it has no hairline knuckle notches and cuts cleanly
// at panel scale. Fingertip is at the local origin (0,0); points +X.
module HandSilhouette()
{
    polygon(points = [
        [ 0.00000,  0.00000],   // fingertip
        [-0.34000,  0.08000],   // finger, top edge
        [-0.40000,  0.22000],   // knuckle rise to fist
        [-0.70000,  0.23000],   // back of fist, top
        [-0.74000, -0.02000],   // back of fist
        [-0.62000, -0.17000],   // thumb tip
        [-0.70000, -0.30000],   // heel of hand
        [-0.40000, -0.27000],   // bottom of fist
        [-0.35000, -0.08000],   // finger, bottom edge
    ]);
}

// Fundamental domain corners -- A is the shared 3-fold pivot ("central
// corner"); the hand's tip sits just inside A, pointing at it.
vertexA = [.25, sqrt(3)/12];
vertexB = [-.25, sqrt(3)/4];
vertexC = [.75, sqrt(3)/4];
centroid = (vertexA + vertexB + vertexC) / 3;
tipTarget = vertexA + 0.62*(centroid - vertexA);
handScale = 0.20;

targetB = vertexB + 0.40*(centroid - vertexB);
targetC = vertexC + 0.40*(centroid - vertexC);
questionMarkSize = 0.16;
questionMarkFatten = 0.012;   // widen the glyph strokes so they cut cleanly

module ChunkyQ()
{
    offset(delta = questionMarkFatten)
        text("?", size = questionMarkSize, font = "Liberation Sans:style=Bold",
             halign = "center", valign = "center", $fn = 32);
}

module shapesToCut()
{
    translate(tipTarget) rotate(-90) scale(handScale) HandSilhouette();
    translate(targetB) ChunkyQ();
    translate(targetC) ChunkyQ();
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

// Step 1: mirror the cut domain across the vertical edge -> isosceles half.
module isocelesTriangle()
{
    weld() {
        cutFundamental();
    }
}

// Step 2: three 120-degree copies about the apex -> equilateral triangle.
module equilateralTriangle()
{
    weld() {
        for (i = [0:1:2])
        {
            rotate_about(120*i, [.25,sqrt(3)/12]) isocelesTriangle();
        }
    }
}

// Step 3: the triangle plus its mirrored copy -> parallelogram tile.
module parallelogram()
{
    weld() {
        equilateralTriangle();
        mirror([sqrt(3)/2,1/2,0]) equilateralTriangle();
    }
}

module PatternArray()
{
    ax = 1;       ay = 0;
    bx = 0.5;     by = sqrt(3)/2;

    weld()
    for (i = [-10:1:10])
        for (j = [-10:1:10])
            translate([i*ax + j*bx, i*ay + j*by, 0])
                parallelogram();
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
        render() translate([0, 108, 0]) scale(40) PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)]) circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)]) circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2]) circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10, 7], [10, 11], [-10, 11]]);
}
