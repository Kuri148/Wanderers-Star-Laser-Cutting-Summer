fieldStart = -3;
fieldEnd = 3;
$fn=32;

module pointer()
{
    scale(.7)translate([-.125, 0, 0])rotate(-90)polygon(points = [[0,.5],[.25,-.25],[0,0],[-.25,-.25]]);
}

module line(point1, point2, thickness=.1)
{
    hull()
    {
        translate(point1)circle(d=thickness);
        translate(point2)circle(d=thickness);
    }
}

for (x=[fieldStart:.5:fieldEnd])
{
    for (y=[fieldStart:.5:fieldEnd])
    {
        if (x == 0 && y == 0)
        {
            translate([x,y,0])circle(.15,center=true, $fn = 32);
        }
        else
        {
        translate([x,y,0])rotate(atan((y+x)/(x-y)))pointer();
        }
    }
}
/*
// generate the row of points as a function
for (x=[-5:.1:4
    ])
{
    for (y=[-3:1:3])
    {
        line([x,x^2+y,0],[x+1,y+(x+1)^2,0],.1);
    }
    
}*/
