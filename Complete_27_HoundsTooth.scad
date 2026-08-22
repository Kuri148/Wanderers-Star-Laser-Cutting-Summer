scale = 10;
gap = .1;

module PatternBlock()
{
    polygon(points = [[0, .5], [-.25, .5], [-.5, .25], [-.5, 0+gap], [-0.5+gap, 0+gap]]);

    polygon(points = [[0.5, 0], [.5, -.25], [.25, -.5], [0+gap, -.5], [0+gap, -.5+gap]]);

    polygon(points = [[.25, 0], [0, 0], [0, .25], [-.25, 0], [-.5, 0], [-.5, -.5], [0, -.5], [0, -.25]]);
}

module PatternArray()
{
for (i = [-5:1:6])
{
    for (j = [-5:1:6])
    {
        translate([j*scale, i*scale])scale(scale)PatternBlock();
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
    intersection()
    {
        offset(delta = -12) GoldenTriangle();
        render() translate([0,100,0]) scale(2)PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
}
