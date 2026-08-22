rhombusHeight = 0.25;
$fn=32;

module fundamentalDomain() {
    polygon(points = [[-.5, 0], [.5, 0], [0, rhombusHeight]]);
}

module fundamentalCut()
{
polygon(points = [
        [0.45308, 0],
        [0.37862, 0.03853],
        [0.30629, 0.0708],
        [0.23608, 0.09679],
        [0.16798, 0.11652],
        [0.10201, 0.12998],
        [0.03815, 0.13717],
        [-0.02358, 0.1381],
        [-0.0832, 0.13275],
        [-0.14069, 0.12114],
        [-0.19607, 0.10326],
        [-0.24932, 0.07911],
        [-0.30046, 0.04869],
        [-0.2525, 0.06438],
        [-0.20879, 0.07649],
        [-0.16931, 0.085],
        [-0.13407, 0.08991],
        [-0.10307, 0.09124],
        [-0.07631, 0.08898],
        [-0.05379, 0.08313],
        [-0.0355, 0.07368],
        [-0.02146, 0.06065],
        [-0.01166, 0.04402],
        [-0.00609, 0.02381],
        [-0.00477, 0]
]);
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
                scale(1)composedTile();
        }
    }
}

//----------------------------

base = 150;
phi = (1 + sqrt(5)) / 2;
holeGap = 8;

leftBase = [-base/2, 0];
rightBase = [base/2, 0];
side = phi * base;
height = sqrt(side*side - (base/2)*(base/2));
apex = [0, height];

module GoldenTriangle()
{
    polygon(points = [leftBase, rightBase, apex]);
}

difference()
{
    GoldenTriangle();
    difference()
    {
        offset(delta = -12) GoldenTriangle();
        render() translate([0,100,0]) scale(50) patternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
}