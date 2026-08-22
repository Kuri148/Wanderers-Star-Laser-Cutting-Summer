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

RhombusArray();