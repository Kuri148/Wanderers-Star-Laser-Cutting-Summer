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
    polygon(points = [[-rectX/2,0],[0,rectY/2],[rectX/2,0]]);
}

module FundamentalCut()
{
    // placeholder test-cut — asymmetric arrow so rotations/glides are
    // visually distinguishable; swap in the real motif
    polygon(points = [
        [-0.05, 0.05],
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
        color("blue")weld()rotate(180)FundamentalRemains();
        
        color("green")weld()translate([-rectX/2,-rectY/2,0])mirror([1,0,0])FundamentalRemains();
        
        color("red")weld()translate([rectX/2,rectY/2,0])mirror([1,0,0])rotate(180)FundamentalRemains();
        
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
