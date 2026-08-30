#!/usr/bin/env python3
"""Regenerate overview.png -- a contact sheet of cropped pattern tiles for
every Complete_NN panel in the repo."""
import os, re, subprocess, sys, glob
from PIL import Image, ImageDraw, ImageFont

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OSCAD = os.environ.get("OPENSCAD", r"C:\Program Files (x86)\OpenSCAD\openscad.exe")
RENDER_DIR = os.path.join(os.environ.get("TEMP", "/tmp"), "ws_ov_renders")
os.makedirs(RENDER_DIR, exist_ok=True)

IMGW, IMGH = 1200, 1500
CAMERA = "0,115,0,0,0,0,520"
CROP = (400, 930, 800, 1330)          # left, top, right, bottom -- inside the pattern
TILE = 240                             # final tile size in the sheet
COLS = 6
PAD = 14
CAPTION_H = 26
TITLE_H = 60
BG = (255, 255, 240)
FG = (30, 30, 30)

GROUPS = ["p1","p2","pm","pg","cm","pmm","pmg","pgg","cmm",
          "p3","p3m1","p31m","p4","p4m","p4g","p6m","p6"]

def caption(fname):
    m = re.match(r"Complete_(\d+)_(.+)\.scad$", fname)
    num, rest = m.group(1), m.group(2)
    for g in GROUPS:
        if rest.lower().startswith(g + "_"):
            rest = rest[len(g) + 1:]
            break
    rest = rest.replace("_", " ").strip()
    return f"{num}. {rest}"

def font(sz, bold=False):
    for name in ((["arialbd.ttf","seguisb.ttf"] if bold else ["arial.ttf","segoeui.ttf"])):
        try:
            return ImageFont.truetype(name, sz)
        except OSError:
            pass
    return ImageFont.load_default()

files = sorted(glob.glob(os.path.join(REPO, "Complete", "Complete_*.scad")),
               key=lambda p: int(re.match(r"Complete_(\d+)", os.path.basename(p)).group(1)))

tiles = []
for path in files:
    fname = os.path.basename(path)
    png = os.path.join(RENDER_DIR, fname.replace(".scad", ".png"))
    if not os.path.exists(png) or "--force" in sys.argv:
        print("render", fname, flush=True)
        r = subprocess.run([OSCAD, "-o", png, f"--imgsize={IMGW},{IMGH}",
                            "--render", "--projection=o", f"--camera={CAMERA}", path],
                           capture_output=True, text=True)
        if r.returncode != 0:
            print(r.stderr[-800:]); sys.exit(1)
    im = Image.open(png).convert("RGB").crop(CROP).resize((TILE, TILE), Image.LANCZOS)
    tiles.append((im, caption(fname)))

rows = (len(tiles) + COLS - 1) // COLS
cellw = TILE + PAD
cellh = TILE + CAPTION_H + PAD
sheetw = COLS * cellw + PAD
sheeth = TITLE_H + rows * cellh + PAD
sheet = Image.new("RGB", (sheetw, sheeth), BG)
d = ImageDraw.Draw(sheet)

title = f"Wanderers Star Laser Cutting \u2014 {len(tiles)} Completed Panel Patterns"
tf = font(30, bold=True)
d.text((sheetw // 2, TITLE_H // 2 + 4), title, font=tf, fill=FG, anchor="mm")

cf = font(15)
for i, (im, cap) in enumerate(tiles):
    r, c = divmod(i, COLS)
    x = PAD + c * cellw
    y = TITLE_H + PAD + r * cellh
    sheet.paste(im, (x, y))
    d.text((x + TILE // 2, y + TILE + CAPTION_H // 2 + 2), cap,
           font=cf, fill=FG, anchor="mm")

out = os.path.join(REPO, "overview.png")
sheet.save(out)
print("wrote", out, sheet.size)
