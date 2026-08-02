// Base shape
module base_shape() {
    polygon(points=[
        [0, 0],      // A
        [0, 0.5],    // B
        [0.5, 0.5],  // C
        [0.5, 0.1],  // D
        [0.25, 0.1], // E
        [0.25, 0.2], // F
        [0.4, 0.2],  // G
        [0.4, 0.4],  // H
        [0.05, 0.4],  // I
        [0.05, 0]     // J
    ]);
}

// Base shape + its mirror over the x-axis (flip y)
module mirrored_x() {
    base_shape();
    mirror([0, 1, 0])
        base_shape();
}

// mirrored_x shape + its mirror over the y-axis (flip x)
module final_shape() {
    mirrored_x();
    mirror([1, 0, 0])
        mirrored_x();
}

// Tile final_shape on a 1-unit grid, shape scaled to 0.9 (small gaps between tiles)
spacing = 1;      // grid pitch — one shape per unit cell
shape_scale = 0.85; // shape size within each cell
rows = 10;
cols = 10;

module PatternArray()
{
for (i = [-10 : cols - 1]) {
    for (j = [-10 : rows - 1]) {
        translate([i * spacing, j * spacing, 0])
            scale([shape_scale, shape_scale, 1])
                rotate([0, 0, ((i + j) % 2 == 1) ? 90 : 0])
                    final_shape();
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
        scale(20)PatternArray();

    }
    translate([(-base/2)+holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([(base/2)-holeGap*cos(36), holeGap*sin(36)])circle(r = 2, $fn = 100);
    translate([0, height - holeGap * 2 ])circle(r = 2, $fn = 100);
    polygon(points = [[-10, 7], [10,7], [10, 11], [-10,11]]);
    
}