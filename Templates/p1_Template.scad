// p1 — o

// tileType: "oblique" | "square" | "rhombic" | "rectangular" | "hexagonal"
tileType = "hexagonal";

x = 1;            // oblique/square/rectangular: v1 length
y = 0.6;          // rectangular: v2 length
shift = 0.2;      // oblique: v2's horizontal (slant) component
sideLength = 1;   // hexagonal: lattice side length
rhombicCos = 0.5; // rhombic: cos(angle) between v1,v2 -- must be strictly between -1 and 1

epsilon = 0.0001;

module weld() {
    offset(delta = epsilon)
        children();
}

function v1() =
    tileType == "hexagonal"   ? [sideLength, 0] :
    tileType == "rhombic"     ? [1, 0] :
    [x, 0];

function v2() =
    tileType == "square"      ? [0, x] :
    tileType == "rectangular" ? [0, y] :
    tileType == "rhombic"     ? [rhombicCos, sin(acos(rhombicCos))] :
    tileType == "hexagonal"   ? [sideLength/2, sideLength*tan(60)/2] :
    [shift, y]; // oblique

module FundamentalDomain()
{
    polygon(points = [[0,0], v1(), v1()+v2(), v2()]);
}

module FundamentalCut()
{
    // placeholder test-cut; swap in the real motif
    // p1 has no rotation/reflection symmetry so this can be any shape
    polygon(points = [
        [0.15, 0.10],
        [0.35, 0.15],
        [0.20, 0.30],
        [0.22, 0.18]
    ]);
}

module FundamentalRemains()
{
    difference(){FundamentalDomain();FundamentalCut();}
}

function center() = (v1() + v2()) / 2;

module PatternArray()
{
    translate(-center())
    for (i = [-10:1:10])
        for (j = [-10:1:10])
            translate(i*v1() + j*v2())
                weld() scale(.9)FundamentalRemains();
}

PatternArray();
