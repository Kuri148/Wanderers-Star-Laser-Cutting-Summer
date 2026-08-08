// pmm — *2222

rectL = 10;
rectH = 15;
epsilon = 0.01;

module weld() {
    offset(delta = epsilon)
        children();
}

module fundamentalDomain() {
    polygon(points = [
        [0, 0], [rectL, 0], [rectL, rectH], [0, rectH]
    ]);
}

function curve_pts(t0, t1, steps, f) =
    [ for (i = [0:steps])
        let(t = t0 + (t1-t0)*i/steps)
        f(t)
    ];

module fundamentalCut() {
    // sine-wave edge, a tight spiral hook, and a cusp — mixed curvature
    sine_edge = curve_pts(0, 1, 40, function(t)
        [ rectL*(0.5 + 0.4*t),
          rectH*(0.85 + 0.08*sin(t*720)) ]
    );

    spiral_hook = curve_pts(0, 1, 60, function(t)
        let(r = rectL*0.18*(1-t) + 0.005, a = t*540)
        [ rectL*0.7 + r*cos(a), rectH*0.55 + r*sin(a) ]
    );

    cusp = curve_pts(0, 1, 30, function(t)
        [ rectL*(0.7 + 0.25*sin(t*180)),
          rectH*(0.55 - 0.5*t*t) ]  // sharp point, zero-slope-to-cusp transition
    );

    polygon(points = concat(
        [[rectL*0.5, rectH]],
        sine_edge,
        spiral_hook,
        cusp,
        [[rectL, rectH*0.05], [rectL, rectH]]
    ));
}

module fundamentalRemains() {
    difference() {
        fundamentalDomain();
        fundamentalCut();
    }
}

module CompiledTile() {
    union() {
        weld() fundamentalRemains();
        weld() mirror([1, 0, 0]) fundamentalRemains();
        weld() mirror([0, 1, 0]) fundamentalRemains();
        weld() mirror([1, 0, 0]) mirror([0, 1, 0]) fundamentalRemains();
    }
}

module PatternArray() {
    for (i = [-10:1:10])
        for (j = [-10:1:10])
            translate([rectL*2*j, rectH*2*i, 0])
                render() CompiledTile();
}

PatternArray();