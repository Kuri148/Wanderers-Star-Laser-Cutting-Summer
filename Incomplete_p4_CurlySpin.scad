// p4 — 442

epsilon = 0.0001;
gap = 0.1;

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
    polygon(points = [
        [0, 0],                     // A
        [0.5 - gap, 0],              // B
        [0.5 - gap, 0.5 - gap],      // C
        [gap*2, 0.5 - gap],          // D
        [gap*2, 0.5 - gap*2],        // E
        [0.5 - gap*2, 0.5 - gap*2],  // F
        [0.5 - gap*2, gap],          // G
        [gap, gap],                  // H
        [gap, 0.5],                  // I
        [0, 0.5]                     // J
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
