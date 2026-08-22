// p6m — *632

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
    // placeholder test-cut — asymmetric arrow so rotations/mirrors are
    // visually distinguishable; swap in the real motif
    polygon(points = [
        [0.28, 0.40],
        [0.45, 0.42],
        [0.28, 0.30],
        [0.33, 0.35]
    ]);
}

module fundamentalDomain()
{
    polygon(points = [[.25,sqrt(3)/12], [.25, sqrt(3)/4], [.75, sqrt(3)/4]]);
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
        reflect_line(90, [.25,sqrt(3)/12]) cutFundamental();
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
        rotate(180) equilateralTriangle();
    }
}

gridStart = -5;
gridEnd = -gridStart;

module PatternArray()
{
    weld()
    {
        for (y = [gridStart:1:gridEnd])
        {
            for (x = [gridStart:1:gridEnd])
            {
                translate([x, y*(sqrt(3)/2), 0]) parallelogram();
            }
        }
    }
}

PatternArray();
color("green")cutFundamental();
