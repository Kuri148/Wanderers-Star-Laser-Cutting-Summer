module random_tile() {
    tx = rands(-0.4, 0.4, 1)[0];
    bx = rands(-0.4, 0.4, 1)[0];
    ry = rands(-0.4, 0.4, 1)[0];
    ly = rands(-0.4, 0.4, 1)[0];

    difference() {
        polygon([[0.5,0.5], [-0.5,0.5], [-0.5,-0.5], [0.5,-0.5]]);

        polygon([[tx+0.05, 0.5], [tx-0.05, 0.5],
                 [bx-0.05, -0.5], [bx+0.05, -0.5]]);

        polygon([[0.5, ry+0.05], [0.5, ry-0.05],
                 [-0.5, ly-0.05], [-0.5, ly+0.05]]);
    }
}

module PatternArray()
{
rows = 5;
cols = 5;

for (i = [-cols:cols])
    for (j = [-rows:rows])
        translate([i, j, 0])
        scale(.9)random_tile();
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
    intersection()
    {
        offset(delta = -12) GoldenTriangle();
        render()translate([0,100,0])scale(25)PatternArray();

    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}