// pm wallpaper group — horizontal mirrors, no glide
// Transcribed from notebook sketch

$fn=32;
rectangleLength = PI;
rectangleHeight = 3;

// Fundamental domain: top half of the rectangle (above the mirror line)
module FundamentalDomain(){
    polygon(points=[
        [-rectangleLength, 0],
        [-rectangleLength, rectangleHeight],
        [rectangleLength, rectangleHeight],
        [rectangleLength, 0]
    ]);
}

// Test cut — empty for now, fill in to check mirror alignment
module FundamentalCut(){
for (x = [-2*PI:PI/8:2*PI])
{
    translate([x, cos(60*x)+(.5*rectangleHeight),0])circle(r = 0.3 - 0.05*abs(x));
}

}

module FundamentalRemains(){
    difference(){
        FundamentalDomain();
        FundamentalCut();
    }
}

// Full rectangle tile = top half + its mirror image (bottom half)
module CompiledTile(){
    FundamentalRemains();
    mirror([0, 1, 0]) FundamentalRemains();
}

// Tile the plane — plain grid, no per-row offset.
// This is what makes it pm instead of cm: rows stack directly,
// no glide reflection falls out of the translation.
module PatternArray(){
    for (i = [-1:1:1]){
        for (j = [-1:1:1]){
            translate([2*rectangleLength*j, 2*rectangleHeight*i, 0])
                scale(1)CompiledTile();
        }
    }
}

PatternArray();
