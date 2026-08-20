// p4m — *442

epsilon = 0.0001;

module weld() {
    offset(delta = epsilon)
        children();
}

module FundamentalDomain()
{
    polygon(points = [[0,0],[0.5,0],[0.5,0.5]]);
}

module FundamentalCut()
{
    // placeholder test-cut — asymmetric arrow so rotations/mirrors are
    // visually distinguishable; swap in the real motif
    polygon(points = [
        [0.05, 0.05],
        [0.30, 0.10],
        [0.05, 0.15],
        [0.12, 0.10]
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
        for (i = [0:1:3])
        {
            weld() rotate(i*90) union()
            {
                weld() FundamentalRemains();
                weld() mirror([0,-1,0]) FundamentalRemains();
            }
        }
    }
}

module PatternArray()
{
    for (i = [-10:1:10])
        for (j = [-10:1:10])
            translate([j, i, 0])
                CompiledTile();
}

PatternArray();
