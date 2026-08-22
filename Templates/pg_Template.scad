// pg — ××

rectH = 0.5;
rectL = 0.15;

rotateAll = 0;

epsilon = 0.0001;

module weld() {
    offset(delta = epsilon)
        children();
}

module FundamentalDomain()
{
    polygon(points = [
        [0, rectH],
        [rectL, rectH],
        [rectL, -rectH],
        [0, -rectH]
    ]);
}

module FundamentalCut()
{
    // placeholder test-cut — asymmetric arrow so the glide flip is visible
    polygon(points = [
        [0.02, 0.10],
        [0.10, 0.20],
        [0.02, 0.30],
        [0.05, 0.20]
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
        weld() translate([rectL, 0, 0]) mirror([0,1,0]) FundamentalRemains();
    }
}

module PatternArray()
{
    for (i = [-10:1:10])
        for (j = [-10:1:10])
            translate([j*rectL*2, i*rectH*2, 0])
                CompiledTile();
}

rotate(90 * rotateAll)
    PatternArray();
