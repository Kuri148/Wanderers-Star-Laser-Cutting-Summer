girth = 0.02;
dip = 0.1;
gap = .025;
scale = 35;
connection = .03;

module Arrows()
{
// Top left shape
polygon(points = [
    [0, 0+ connection],
    [0, 0.5],
    [-.25/2 + girth, 0.5 - dip - connection],
    [-.25/2 + girth, 0 - dip]
]);

// Left vertical
polygon(points = [
    [-.25, 0.5],
    [-.25, 0 + connection],
    [-.25/2 - girth, 0 - dip],
    [-.25/2 - girth, 0.5 - dip - connection]
]);

// Top horizontal //center slot
polygon(points = [
    [-.25/2 - girth, 0.5],
    [-.25/2 - girth, 0.5 - dip + gap],
    [-.25/2 + girth, 0.5 - dip + gap],
    [-.25/2 + girth, 0.5]
]);

// Bottom horizontal //center slot
polygon(points = [
    [-.25/2 - girth, 0 - dip - gap],
    [-.25/2 - girth, -0.5],
    [-.25/2 + girth, -0.5],
    [-.25/2 + girth, 0 - dip - gap]
]);

// Bottom left
polygon(points = [
    [0, 0 - .001],
    [0, -0.5 + connection - .001],
    [.25/2 - girth, -0.5 + connection],
    [.25/2 - girth, 0 - dip - connection]
]);

// Bottom right
polygon(points = [
    [.25, -0.5 + connection -.001],
    [.25, 0 - .001],
    [.25/2 + girth, 0 - dip - connection],
    [.25/2 + girth, -0.5 + connection]
]);

// Top center
polygon(points = [
    [0, 0.5 + connection],
    [.25/2 - girth, 0.5 + connection],
    [.25/2 - girth, 0.5 - dip]
]);

polygon (points = [
    [.25, .5 + connection],
    [.25/2 + girth, 0.5 + connection],
    [.25/2 + girth, 0.5 - dip]
]);


// Right vertical
polygon(points = [
    [.25/2 - girth, 0.5 - dip - gap],
    [.25/2 - girth, 0 - dip + gap],
    [.25/2 + girth, 0 - dip + gap],
    [.25/2 + girth, 0.5 - dip - gap]
]);
}
module PatternArray()
{
for (i = [-5:1:6])
{
    for (j = [-5:1:6])
    {
        translate([j*scale*.5, i*scale])scale(scale)Arrows();
    }
}
}
//Arrows();


union()
{
    intersection()
    {
        PatternArray();
        circle(r = 50, $fn = 250);
    }
    difference()
    {
    circle(r = 54, $fn = 250);
    circle(r = 53, $fn = 250);
    }
        
}