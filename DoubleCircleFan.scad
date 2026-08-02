$fn=32;

cutGap = .6;

module DoubleFan()
{
difference()
    {
        circle(.5);
        translate([0, cutGap, 0])circle(.5);
        translate([0, -cutGap, 0])circle(.5);
    }
}

module PatternArray()
{
for (i = [-10 : 10]) {
    for (j = [-10 : 10]) {
        translate([i*cutGap + .1, j*cutGap, 0])
            scale(.7 )
                rotate([0, 0, (abs((i + j)) % 2 == 1) ? 90 : 0])
                    DoubleFan();
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
    intersection()
    {
        offset(delta = -12) GoldenTriangle();
        render()translate([0,100,0])scale(20)PatternArray();

    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}