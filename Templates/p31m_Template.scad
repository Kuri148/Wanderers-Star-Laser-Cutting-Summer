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

module shapesToCut()
{
    // Polygon 1, closed (4 points)
    polygon(points = [
        [0.62277, 0.43301],
        [0.36754, 0.32933],
        [0.44023, 0.39718],
        [0.48385, 0.40202]
    ]);
    // Polygon 2, closed (3 points)
    polygon(points = [
        [0.25, 0.24533],
        [0.38106, 0.22],
        [0.25, 0.14434]
    ]);
    // Polygon 3, closed (3 points)
    polygon(points = [
        [0.48335, 0.27906],
        [0.35785, 0.29541],
        [0.41426, 0.23917]
    ]);
    // Polygon 4, closed (3 points)
    polygon(points = [
        [0.30292, 0.37456],
        [0.29646, 0.32287],
        [0.35623, 0.37941]
    ]);
}

module fundamentalDomain()
{
    polygon(points = [[.25,sqrt(3)/12], [-.25, sqrt(3)/4], [.75, sqrt(3)/4]]);
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

// Step 3: the triangle plus its 180-degree copy -> parallelogram tile.
module parallelogram()
{
    weld() {
        equilateralTriangle();
        mirror([sqrt(3)/2,1/2,0]) equilateralTriangle();
    }
}

parallelogram();
module PatternArray()
{
    ax = 1;       ay = 0;
    bx = 0.5;     by = sqrt(3)/2;

    for (i = [-10:1:10])
        for (j = [-10:1:10])
            translate([i*ax + j*bx, i*ay + j*by, 0])
                parallelogram();
}

weld()PatternArray();
color("green")cutFundamental();