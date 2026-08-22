cross = .42;
dagger = .32;
scale = 10;

module EightStar()
{
    polygon(points = [
        [0, cross],
        [dagger, dagger],
        [cross, 0],
        [dagger, -dagger],
        [0, -cross],
        [-dagger, -dagger],
        [-cross, 0],
        [-dagger, dagger]
    ]);
}


module PatternArray()
{
for (i = [-5:1:6])
{
    for (j = [-5:1:6])
    {
        translate([j*scale, i*scale])scale(scale)EightStar();
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