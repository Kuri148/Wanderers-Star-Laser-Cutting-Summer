// pmg — *2222

RectH = .5;
RectL = .5;
epsilon = 0.01;

module weld() {
    offset(delta = epsilon)
        children();
}

module FundamentalDomain() {
    polygon(points = [[0,0], [0,RectH], [RectL,RectH], [RectL,0]]);
}


module FundamentalCut() {
polygon(points=[[.1,.3],[.2,.4],[.3,.2],[.4,.2],[.3,.1]]);
}

module FundamentalRemains() {
    difference() {
        FundamentalDomain();
        FundamentalCut();
    }
}

module CompiledTile() {
    union() {
        weld() FundamentalRemains();
        weld() translate([0, RectH, 0]) rotate(180) FundamentalRemains();
        weld() translate([0, -RectH, 0]) mirror([-1, 0, 0]) FundamentalRemains();
        weld() mirror([0, -1, 0]) FundamentalRemains();
    }
}

module PatternArray() {
    for (i = [-1:1:1])
        for (j = [-1:1:1])
            translate([RectL*2*i, RectH*2*j, 0])
                CompiledTile();
}

PatternArray();

color("red")CompiledTile();