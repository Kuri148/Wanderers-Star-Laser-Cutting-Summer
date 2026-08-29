# Wanderers Star Laser Cutting

OpenSCAD source files for laser-cut golden-triangle panels, organized into three folders:

- **`Complete/`** — finished panels (`Complete_NN_Name.scad`), each framed in the golden-triangle border and ready to cut.
- **`Incomplete/`** — work-in-progress drafts (`Incomplete_Name.scad`).
- **`Templates/`** — one blank reference template per wallpaper symmetry group (`p1`, `p2`, `pm`, `pg`, `cm`, `pmm`, `pmg`, `pgg`, `cmm`, `p3`, `p3m1`, `p31m`, `p4`, `p4m`, `p4g`, `p6`, `p6m`), plus `GoldenTriangle_Blank_Template.scad` for the frame itself.

`index.html` at the repo root is a browser-based wallpaper-pattern editor: pick a symmetry group, draw or drag cutout shapes (polygons, Bézier curves, circles) inside the fundamental domain, and it outputs either the raw cut shapes or a complete, ready-to-render `.scad` panel (framed in the golden triangle) that can be saved directly as a new `Complete_NN`. Served via GitHub Pages from this branch's root.

## Completed patterns

![Overview of all completed panel patterns](overview.png)
