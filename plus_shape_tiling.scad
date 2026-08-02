module BaseArm() {
    points = [
        [0, 0],      // A
        [1/2, 0],    // B
        [1/2, 1/6],  // C
        [1/6, 1/6],  // D
        [1/6, 1/2],  // E
        [0, 1/2]     // F
    ];
    polygon(points);
}

module PlusShape() {
    union() {
        for (a = [0, 90, 180, 270])
            rotate([0, 0, a])
                BaseArm();
    }
}


module PatternArray()
{
for (i = [-10:10]) {
    for (j = [-10:10]) {
        tx = i*(2/3) + j;
        ty = i*(4/3) + j*(1/3);
        translate([tx, ty, 0])
            scale(.925)PlusShape();
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
        render()translate([0,100,0])scale(20)rotate(35)PatternArray();

    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}