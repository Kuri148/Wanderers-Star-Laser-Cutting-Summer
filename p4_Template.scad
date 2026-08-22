// p4 — 442

epsilon = 0.0001;

module weld() {
    offset(delta = epsilon)
        children();
}

module FundamentalDomain()
{
    polygon(points = [[0,0],[0,0.5],[0.5,0.5],[0.5,0]]);
}

module FundamentalCut()
{
    // placeholder test-cut — asymmetric arrow so rotations are
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
        weld() FundamentalRemains();
        weld() rotate(90) FundamentalRemains();
        weld() rotate(180) FundamentalRemains();
        weld() rotate(270) FundamentalRemains();
    }
}

module PatternArray()
{
    for (i = [-10:1:10])
        for (j = [-10:1:10])
            translate([i, j, 0])
                render() CompiledTile();
}

PatternArray();
