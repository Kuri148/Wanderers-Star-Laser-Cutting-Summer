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

module afe() {
    difference()
    {
        polygon(points=[A, F, E]);
        shape_to_cut();
    }
}

module afce()
{
    afe();
    mirror([-1/4, sqrt(3)/4, 0])afe();
}

module abcd_boundary() {
    polygon(points=[A, B, C, D]);
}
module shape_to_cut()
{
    translate([-.05,.1,0])circle(r=.1);
    /*
 polygon(points=[[-.25,.1],[-.05,.1],[-.05,-.1],[-.25,-.1]]);
    polygon(points=[[.25,.1],[.05,.1],[.05,-.1],[.25,-.1]]);
    */
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
                translate([j*1-i*.5,i*(sqrt(3)/2),0])scale(.99)bounded_shape();
            }
        }
    }
}
PatternArray();

color("red")afe();