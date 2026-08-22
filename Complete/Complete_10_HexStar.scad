c = 1/6;
s = c;
a = sqrt(3) / 12;

dv = -0.03;

tp = [
    [c, 0],
    [1/4, sqrt(3) / 12],
    [1/12, sqrt(3) / 12]
];

function RotateAroundOrigin(point, rotationAngle) =
    [
        sqrt(point[0]^2 + point[1]^2) * cos(atan2(point[1], point[0]) + rotationAngle),
        sqrt(point[0]^2 + point[1]^2) * sin(atan2(point[1], point[0]) + rotationAngle)
    ];

hp = [
    for (i = [0:1:5])
        RotateAroundOrigin([c, 0], i * 60)
];

module HexStar() {
    polygon(points = hp);

    for (i = [0:1:5]) {
        rotate(60 * i)
            polygon(points = tp);
    }
}

module CompositeTile() {
    offset(delta = dv)
        HexStar();

    for (i = [0:1:5]) {
        offset(delta = dv)
            rotate(i * 60)
                translate([1/3, 0, 0])
                    polygon(points = hp);
    }
}

module PatternArray() {
    for (i = [0:1:40]) {
        for (j = [-10:1:10]) {
            jump = i % 2 == 0 ? 0 : 1/2;

            translate([j + jump, i * 2 * a, 0])
                CompositeTile();
        }
    }
}


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
        scale(30)PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}