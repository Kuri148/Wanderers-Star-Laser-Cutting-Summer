 g = 0.02;
scale = 20;
module MapleLeaf()
{
polygon(points = [
    [0 + g,      0 + g],
    [1/6,        0 + g],
    [1/6,       -1/6 + g],
    [1/3,        0 + g],
    [1/2 - g,    0 + g],
    [1/2 - g,    1/6],
    [2/3 - g,    1/3],
    [1/2 - g,    1/3],
    [1/2 - g,    1/2 - g],
    [1/3,        1/2 - g],
    [1/3,        1/3 - g],
    [1/6,        1/2 - g],
    [0 + g,      1/2 - g],
    [0 + g,      1/3],
    [1/6 + g,    1/6],
    [0 + g,      1/6]
]);
}

module MapleLeafCutter()
{
translate([-1/4, -1/6])
polygon(points = [
    [0 + g,      0 + g],
    [1/6,        0 + g],
    [1/6,       -1/6 + g],
    [1/3,        0 + g],
    [1/2 - g,    0 + g],
    [1/2 - g,    1/6],
    [2/3 - g,    1/3],
    [1/2 - g,    1/3],
    [1/2 - g,    1/2 - g],
    [1/3,        1/2 - g],
    [1/3,        1/3 - g],
    [1/6,        1/2 - g],
    [0 + g,      1/2 - g],
    [0 + g,      1/3],
    [1/6 + g,    1/6],
    [0 + g,      1/6]
]);
}

module MapleLeafTile()
{
    MapleLeaf();
    rotate(180)MapleLeaf();
}

module PatternArray()
{
for (i = [-5:1:6])
{
    for (j = [-5:1:6])
    {
        translate([j*scale, i*scale])scale(scale)MapleLeafTile();
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
        rounded_rect_by_hull(200, 150, 30, $fn=64);
        
    }
    difference()
    {
        rounded_rect_by_hull(210, 160, 30, $fn=64);
        rounded_rect_by_hull(205, 155, 30, $fn=64);
    }
        
}