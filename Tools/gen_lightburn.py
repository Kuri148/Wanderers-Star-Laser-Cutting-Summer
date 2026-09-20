#!/usr/bin/env python3
"""Convert Nested/Sheet_NN.scad layouts into LightBurn projects
(Nested/Sheet_NN.lbrn2) where every panel is its own Group.

OpenSCAD's DXF export is a soup of unconnected LINE entities. Here each
panel's DXF is read, its segments are chained end-to-end into closed paths
(what LightBurn calls Auto-Join), and all paths belonging to one panel are
wrapped in a single Group so the triangle moves/selects as one object.

Placement (translate / rotate 180) is read back out of the Sheet_NN.scad
files, so the layout stays the single source of truth.

Usage: python Tools/gen_lightburn.py
"""
import os, re, glob, math
from xml.sax.saxutils import quoteattr

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DXF_DIR = os.path.join(REPO, "DXF")
OUT_DIR = os.path.join(REPO, "Nested")

SHEET_H = 600.0   # LightBurn's Y axis points down; flip so it matches the preview PNGs
KEY_PREC = 3      # endpoint-matching tolerance = 10^-3 mm

PLACE_RE = re.compile(
    r'translate\(\[([-\d.]+),\s*([-\d.]+)\]\)\s*(rotate\(\[0,0,180\]\)\s*)?'
    r'import\("([^"]+)"\)')


def read_dxf_lines(path):
    """Return [(x1, y1, x2, y2)] for every LINE entity."""
    with open(path) as f:
        raw = [l.strip() for l in f]
    segs, i = [], 0
    while i < len(raw) - 1:
        if raw[i] == "0" and raw[i + 1] == "LINE":
            vals, i = {}, i + 2
            while i < len(raw) - 1 and raw[i] != "0":
                vals[raw[i]] = float(raw[i + 1])
                i += 2
            segs.append((vals["10"], vals["20"], vals["11"], vals["21"]))
        else:
            i += 1
    return segs


def key(x, y):
    return (round(x, KEY_PREC), round(y, KEY_PREC))


def chain(segs):
    """Join segments into polylines. Returns [(points, closed)]."""
    edges = [(key(a, b), key(c, d), (a, b), (c, d)) for a, b, c, d in segs]
    edges = [e for e in edges if e[0] != e[1]]
    at = {}
    for idx, (ka, kb, _, _) in enumerate(edges):
        at.setdefault(ka, []).append(idx)
        at.setdefault(kb, []).append(idx)
    used = [False] * len(edges)
    out = []

    def walk_from(idx, forward):
        """Consume a chain starting on edge idx; return list of points."""
        used[idx] = True
        ka, kb, pa, pb = edges[idx]
        if not forward:
            ka, kb, pa, pb = kb, ka, pb, pa
        pts, cur = [pa, pb], kb
        while True:
            nxt = next((j for j in at[cur] if not used[j]), None)
            if nxt is None:
                return pts
            used[nxt] = True
            ja, jb, qa, qb = edges[nxt]
            if ja == cur:
                pts.append(qb); cur = jb
            else:
                pts.append(qa); cur = ja

    # Start open chains at dangling ends first, then close remaining loops.
    for idx in range(len(edges)):
        if used[idx]:
            continue
        ka, kb = edges[idx][0], edges[idx][1]
        if len(at[ka]) == 1 or len(at[kb]) == 1:
            pts = walk_from(idx, len(at[ka]) == 1)
            out.append((pts, False))
    for idx in range(len(edges)):
        if used[idx]:
            continue
        pts = walk_from(idx, True)
        closed = key(*pts[0]) == key(*pts[-1])
        if closed:
            pts = pts[:-1]
        out.append((pts, closed))
    return out


def fmt(v):
    s = f"{v:.4f}".rstrip("0").rstrip(".")
    return "0" if s in ("-0", "") else s


def path_xml(pts, closed, indent):
    n = len(pts)
    verts = "".join(f"V{fmt(x)} {fmt(y)}" for x, y in pts)
    last = n if closed else n - 1
    prims = "".join(f"L{i} {(i + 1) % n}" for i in range(last))
    pad = " " * indent
    return (f'{pad}<Shape Type="Path" CutIndex="0" PowerScale="100">\n'
            f'{pad}    <XForm>1 0 0 1 0 0</XForm>\n'
            f'{pad}    <VertList>{verts}</VertList>\n'
            f'{pad}    <PrimList>{prims}</PrimList>\n'
            f'{pad}</Shape>\n')


def group_xml(paths, indent):
    pad = " " * indent
    body = "".join(path_xml(p, c, indent + 8) for p, c in paths)
    return (f'{pad}<Shape Type="Group" CutIndex="0">\n'
            f'{pad}    <XForm>1 0 0 1 0 0</XForm>\n'
            f'{pad}    <Children>\n{body}{pad}    </Children>\n'
            f'{pad}</Shape>\n')


def transform(pts, tx, ty, flip180):
    out = []
    for x, y in pts:
        if flip180:
            x, y = -x, -y
        out.append((x + tx, SHEET_H - (y + ty)))
    return out


def main():
    scads = sorted(glob.glob(os.path.join(OUT_DIR, "Sheet_*.scad")))
    for scad in scads:
        name = os.path.splitext(os.path.basename(scad))[0]
        shapes, stats = [], []
        for m in PLACE_RE.finditer(open(scad).read()):
            tx, ty, rot, dxf = float(m[1]), float(m[2]), bool(m[3]), m[4]
            dxf = os.path.join(DXF_DIR, os.path.basename(dxf))
            paths = chain(read_dxf_lines(dxf))
            paths = [(transform(p, tx, ty, rot), c) for p, c in paths]
            shapes.append(group_xml(paths, 4))
            stats.append((os.path.basename(dxf), len(paths),
                          sum(1 for _, c in paths if not c)))
        xml = ('<?xml version="1.0" encoding="UTF-8"?>\n'
               '<LightBurnProject AppVersion="1.4.00" FormatVersion="1" '
               'MaterialHeight="0" MirrorX="False" MirrorY="False">\n'
               '    <CutSetting type="Cut">\n'
               '        <index Value="0"/>\n'
               '        <name Value="C00"/>\n'
               '    </CutSetting>\n'
               + "".join(shapes) +
               '</LightBurnProject>\n')
        out = os.path.join(OUT_DIR, name + ".lbrn2")
        with open(out, "w", encoding="utf-8", newline="\n") as f:
            f.write(xml)
        open_chains = [s for s in stats if s[2]]
        print(f"{name}: {len(shapes)} groups, {sum(s[1] for s in stats)} paths "
              f"-> {os.path.relpath(out, REPO)}")
        for fn, n, o in open_chains:
            print(f"  WARNING {fn}: {o} of {n} paths did not close")


if __name__ == "__main__":
    main()
