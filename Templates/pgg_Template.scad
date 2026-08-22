// pgg — 22x

rectX = 1;
rectY = 1;
epsilon = 0.0001;

module weld() {
    offset(delta = epsilon)
        children();
}

module FundamentalDomain()
{
    polygon(points = [[-rectX,0],[0,rectY],[rectX,0]]);
}

module FundamentalCut()
{
    // placeholder test-cut — asymmetric arrow so rotations/glides are
    // visually distinguishable; swap in the real motif
    polygon(points = [
        [-0.1, 0.05],
        [0.15, 0.15],
        [-0.1, 0.25],
        [-0.03, 0.15]
    ]);
}

module FundamentalRemains()
{
    difference(){FundamentalDomain();FundamentalCut();}
}

module CompiledTile()
{
    union()
    {
        weld() FundamentalRemains();
        weld() translate([rectX,-rectY,0]) mirror([1,0,0]) FundamentalRemains();
        weld() translate([-rectX,-rectY,0]) mirror([-1,0,0]) FundamentalRemains();
        weld() translate([-1,0,0]) mirror([1,0,0]) rotate(180) FundamentalRemains();
    }
}

module PatternArray()
{
    for (i = [-10:1:10])
        for (j = [-10:1:10])
            translate([j*rectX, i*rectY, 0])
                CompiledTile();
}

PatternArray();
