cross = 0.15;
dagger = 0.48;
tile_scale = 10;

module EightStar(crossMultiplier=0, daggerMultiplier=0)
{
    polygon(points = [
        [0,                          cross + crossMultiplier],
        [dagger + daggerMultiplier,  dagger + daggerMultiplier],
        [cross + crossMultiplier,    0],
        [dagger + daggerMultiplier, -dagger - daggerMultiplier],
        [0,                         -cross - crossMultiplier],
        [-dagger - daggerMultiplier,-dagger - daggerMultiplier],
        [-cross - crossMultiplier,   0],
        [-dagger - daggerMultiplier , dagger + daggerMultiplier]
    ]);
}

module PatternArray()
{
    for (i = [-10:1:10])
    {
        for (j = [-10:1:10])
        {
            d = sqrt(j*j + i*i);

            translate([j * tile_scale, i * tile_scale])
                scale(tile_scale)
                    EightStar(d * 0.035, -d * 0.025);
        }
    }
}

module rounded_rect_by_hull(w, h, r, $fn=64)
{
    hull()
    {
        translate([-w/2 + r, -h/2 + r]) circle(r=r, $fn=$fn);
        translate([ w/2 - r, -h/2 + r]) circle(r=r, $fn=$fn);
        translate([ w/2 - r,  h/2 - r]) circle(r=r, $fn=$fn);
        translate([-w/2 + r,  h/2 - r]) circle(r=r, $fn=$fn);
    }
}


union()
{
    intersection()
    {
        PatternArray();
        rounded_rect_by_hull(150, 150, 30, $fn=64);
        
    }
    difference()
    {
        rounded_rect_by_hull(160, 160, 30, $fn=64);
        rounded_rect_by_hull(155, 155, 30, $fn=64);
    }
        
}