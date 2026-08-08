// cm wallpaper group — vertical mirrors + glide via row offset
// Transcribed from notebook sketch
$fn=20;
rhombusWidth = .4;

// Fundamental domain: half the rhombus, split by the vertical mirror line
// (the "F | F" sketch — one triangle is the fundamental domain,
//  its mirror image is the other half of the rhombus)
module FundamentalDomain(){
    polygon(points=[[rhombusWidth, 0], [0, .5], [0, -.5]]);
}

// A test cut to visually confirm mirror alignment (like the F/F asymmetry)
module FundamentalCut(){
    translate([.15, .15, 0]) circle(r=.1);
    translate([.15, .05,0])square(.1);
    
    translate([.15, -.15, 0]) circle(r=.1);
    translate([.05,-.15,0])square(.1);
    
    translate([rhombusWidth, 0, 0])circle(r=.1);
    translate([0, rhombusWidth - .05, 0])circle(r=.05);
    translate([0, -rhombusWidth + .05, 0])circle(r=.05);
}

module FundamentalRemains(){
    difference(){
        FundamentalDomain();
        FundamentalCut();
    }
}

// Full rhombus tile = fundamental domain + its mirror image
module CompiledTile(){
    FundamentalRemains();
    mirror([-1, 0, 0]) FundamentalRemains();
}

// Tile the plane. The i%2 offset on x is what turns the plain
// mirror repeat into a *glide* reflection between rows —
// this is the part that makes it cm instead of pm.
module PatternArray(){
    for (i = [-10:1:10]){
        for (j = [-10:1:10]){
            translate([2*j*rhombusWidth + (rhombusWidth*(i%2)), .5*i, 0])
                scale(.98)CompiledTile();
        }
    }
}

PatternArray();
