triangleA = [0, 0];
triangleB = [.5, 0];
triangleC = [0, .5 * tan(30)];
triangleBranchOffset = -.03;

module triangularBranch()
{
    polygon(points = [triangleA, triangleB, triangleC]);
    mirror([1, 0, 0])polygon(points = [triangleA, triangleB, triangleC]);
}

module TriangleThirds()
{
    for (i = [0:1:2])
    {
    rotate(i * 120)offset(triangleBranchOffset)translate([0, -.5 * tan(30), 0])triangularBranch();
    }
}

//TriangleThirds();

module TriangleArray()
{
    for (i = [-5:1:5])
    {
        for (j = [-10:1:10])
        {
            if ((i + j)%2 == 0) 
            {translate([.5 * j, i * .5 * tan(60)+ .5 * tan(60)-tan(30), 0])rotate(180)TriangleThirds();}
            else
            {
                translate([.5 * j, .5 * tan(60) * i, 0])TriangleThirds();
            }
        }
    }
}  

difference()
{
    circle(55, $fn=6);
    
    intersection()
    {
    circle(50, $fn = 6);
    scale(25)translate([0, .5 * tan(60)-tan(30), 0])TriangleArray();
    }
}

stickA =[4.5, 0];
stickB = [4.5, -50];
stickC = [0, -59];
stickD = [-4.5, -50];
stickE = [-4.5, 0];
translate([0, -45, 0])polygon(points=[stickA, stickB, stickC, stickD, stickE]);