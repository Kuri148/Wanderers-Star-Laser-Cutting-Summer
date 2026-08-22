// p3 — 333

// Base shape AFCE
A = [-0.25, sqrt(3)/4];
B = [0.75, sqrt(3)/4];
F = [0.25, sqrt(3)/12];
C = [0.25, -sqrt(3)/4];
D = [-0.75, -sqrt(3)/4];
E = [-0.25, -sqrt(3)/12];
$fn=32;

// Weld: grow by eps, union, shrink back by eps.
// Fuses hairline seams between assembled pieces without changing
// the outer silhouette. Increase eps if seams still show; decrease
// it if thin cut features start filling in.
module weld(eps = 0.001) {
    offset(delta = -eps) offset(delta = eps) children();
}

module afce() {
    difference()
    {
        polygon(points=[A, F, C, E]);
        shape_to_cut();
    }
}
module abcd_boundary() {
    polygon(points=[A, B, C, D]);
}
module shape_to_cut()
{
    polygon(points=[[-.25,.1],[-.05,.1],[-.05,-.1],[-.25,-.1]]);
    polygon(points=[[.25,.1],[.05,.1],[.05,-.1],[.25,-.1]]);
}
// Rotate a 2D shape by angle degrees around an arbitrary pivot point
module rotate_around(pivot, angle) {
    translate(pivot)
        rotate([0, 0, angle])
            translate(-pivot)
                children();
}
// Everything clipped to the ABCD boundary
module bounded_shape()
{
    intersection() {
        weld() {
            // Three copies rotated 120 degrees apart around F
            for (a = [0, 120, 240])
                rotate_around(F, a) afce();
            // Three copies rotated 120 degrees apart around E
            for (a = [0, 120, 240])
                rotate_around(E, a) afce();
        }
        abcd_boundary();
    }
}
module PatternArray()
{
    weld() {
        for (i = [-10:1:10])
        {
            for (j = [-10:1:10])
            {
                translate([j*1-i*.5,i*(sqrt(3)/2),0])scale(1)bounded_shape();
            }
        }
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
        render() translate([0,100,0]) scale(30) PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
}
