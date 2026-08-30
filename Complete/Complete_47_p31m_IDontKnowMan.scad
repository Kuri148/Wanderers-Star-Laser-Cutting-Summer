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

// Pointing-hand silhouette, traced from a photo. Fingertip is at
// the local origin (0,0); the hand points in +X by default.
module HandSilhouette()
{
    polygon(points = [
        [0.00000, 0.00000],
        [-0.04643, 0.03393],
        [-0.35536, 0.03750],
        [-0.38036, 0.12679],
        [-0.53750, 0.14821],
        [-0.61786, 0.14107],
        [-0.80893, 0.00179],
        [-0.87857, 0.00179],
        [-0.88036, 0.04821],
        [-1.00000, 0.04821],
        [-1.00000, -0.38929],
        [-0.88036, -0.38929],
        [-0.87857, -0.32321],
        [-0.55179, -0.37500],
        [-0.47143, -0.37321],
        [-0.43750, -0.34107],
        [-0.43571, -0.30000],
        [-0.39821, -0.29286],
        [-0.36786, -0.26071],
        [-0.36607, -0.19643],
        [-0.33929, -0.18571],
        [-0.31607, -0.15000],
        [-0.32143, -0.06429],
        [-0.03750, -0.05536],
        [-0.00357, -0.03571],
    ]);
}

// Fundamental domain corners -- A is the shared 3-fold pivot ("central
// corner"); the hand's tip sits just inside A, pointing at it.
vertexA = [.25, sqrt(3)/12];
vertexB = [-.25, sqrt(3)/4];
vertexC = [.75, sqrt(3)/4];
centroid = (vertexA + vertexB + vertexC) / 3;
tipTarget = vertexA + 0.45*(centroid - vertexA);
handScale = 0.16;

targetB = vertexB + 0.6*(centroid - vertexB);
targetC = vertexC + 0.6*(centroid - vertexC);
questionMarkSize = 0.08;

module shapesToCut()
{
    translate(tipTarget) rotate(-90) scale(handScale) HandSilhouette();
    translate(targetB) text("?", size=questionMarkSize, font="Arial:style=Bold", halign="center", valign="center");
    translate(targetC) text("?", size=questionMarkSize, font="Arial:style=Bold", halign="center", valign="center");
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
        render() translate([0, 100, 0]) scale(30) weld() PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)]) circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)]) circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2]) circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10, 7], [10, 11], [-10, 11]]);
}
