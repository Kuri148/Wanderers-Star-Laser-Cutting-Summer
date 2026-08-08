rhombusHeight = 0.25;
$fn=32;

module fundamentalDomain() {
    polygon(points = [[-.5, 0], [.5, 0], [0, rhombusHeight]]);
}

module fundamentalCut()
{
    translate([.05, 0, 0])circle(r=.1);
}

module fundamentalRemains()
{
    difference()
    {
        fundamentalDomain();
        fundamentalCut();
    }
}

module composedTile() {
    fundamentalRemains();
    rotate(180) fundamentalRemains();
}

module patternArray() {
    for (i = [-10 : 10]) {
        for (j = [-10 : 10]) {
            translate([j + (1/2 * (i % 2)), i * rhombusHeight, 0])
                scale(.98)composedTile();
        }
    }
}

patternArray();