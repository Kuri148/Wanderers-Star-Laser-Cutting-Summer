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
        render() translate([0,65,0])scale(1.2) PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
}