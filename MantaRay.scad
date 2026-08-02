points = [
    [0, 0],        // A
    [-0.25, 0.25], // B
    [0, 1],        // C
    [0.75, 1.25],  // D
    [1, 1],        // E
    [0.75, 0.75],  // F
    [1, 0],        // G
    [0.25, 0.25]   // H
];

module MantaRayTile()
{
offset(delta = -.1)polygon(points = points);
}

module MantaRaySquareTiling()
{
for (i = [0:1:3])
{
    rotate(i * 90)MantaRayTile();
}
}

MantaRaySquareTiling();

module PatternArray()
{
    for (i = [-10:1:10])
    {
        for (j = [-10:1:10])
        {
            translate([j * 2, i * 2, 0])MantaRaySquareTiling();
        }
    }
}

//PatternArray();

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
        scale(10)PatternArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}