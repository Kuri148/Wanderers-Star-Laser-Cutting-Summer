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
//PatternArray();