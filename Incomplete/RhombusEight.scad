rhombusOffset = -.03;
rhombusRowArrayStart = -5;
rhombusRowArrayEnd = 5;
rhombusColArrayStart = -5;
rhombusColArrayEnd = 5;

diamondA = [0, 0];
diamondB = [.5, .5 * tan(22.5)];
diamondC = [1, 0]; 
diamondD = [.5, -.5 * tan(22.5 )];

module RhombusSingle()
{
polygon(points = [diamondA, diamondB, diamondC, diamondD]);
}

module RhombusStar()
{
    for (i = [0:1:7])
    {
        rotate(i * 45)offset(rhombusOffset)RhombusSingle();
    }
}

module RhombusArray()
{
    for (i = [rhombusRowArrayStart:1:rhombusRowArrayEnd])
    {
        for (j = [rhombusColArrayStart:1:rhombusColArrayEnd])
        {
            translate([j * 2, i * 2])rotate(0 )RhombusStar();
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
        render() translate([0,100,0]) scale(6) RhombusArray();
    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
}