// p4g — 4*2

rectX = 0.5;
rectY = 0.5;
epsilon = 0.0001;

module weld() {
    offset(delta = epsilon)
        children();
}

module FundamentalDomain() {
    polygon(points = [[0,0], [rectX,0], [0,rectY]]);
}

module FundamentalCut() {
    polygon(points = [
        [rectX*0.55, rectY*0.05],
        [rectX*0.20, rectY*0.45],
        [rectX*0.35, rectY*0.45],
        [rectX*0.10, rectY*0.75],
        [rectX*0.45, rectY*0.35],
        [rectX*0.30, rectY*0.35],
    ]);
}

module FundamentalRemains()
{
    difference(){FundamentalDomain();FundamentalCut();}
}

module SecondaryDomain() {
    union() {
        weld() FundamentalRemains();
        weld() mirror([1,1,0])
            translate([-rectX, -rectY, 0])
                FundamentalRemains();
    }
}

module CompiledTile() {
    render()
    union() {
        for (i = [0:1:3])
            weld() rotate(i*90) SecondaryDomain();
    }
}

module PatternArray() {
    render()
    union() {
        for (i = [-10:1:10])
            for (j = [-10:1:10])
                translate([j, i, 0])
                    CompiledTile();
    }
}

PatternArray();
color("green")CompiledTile();