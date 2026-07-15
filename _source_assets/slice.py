import os
from collections import deque
from PIL import Image

SRC = "chicken_sprites.png"
OUT = "sliced"
os.makedirs(OUT, exist_ok=True)

im = Image.open(SRC).convert("RGBA")
W, H = im.size
px = im.load()

BG = 30          # luminance below -> background (black)
SOFT_HI = 55     # soft alpha ramp ceiling to reduce black halo
MIN_AREA = 2500  # ignore tiny specks / palette dots

def lum(r, g, b):
    return (r * 299 + g * 587 + b * 114) // 1000

# foreground mask
fg = bytearray(W * H)
for y in range(H):
    row = y * W
    for x in range(W):
        r, g, b, a = px[x, y]
        if a > 0 and lum(r, g, b) >= BG:
            fg[row + x] = 1

# connected components (8-connectivity, iterative BFS)
label = [0] * (W * H)
comps = []
cur = 0
for sy in range(H):
    base = sy * W
    for sx in range(W):
        idx = base + sx
        if fg[idx] and label[idx] == 0:
            cur += 1
            q = deque()
            q.append((sx, sy))
            label[idx] = cur
            minx = maxx = sx
            miny = maxy = sy
            area = 0
            while q:
                x, y = q.popleft()
                area += 1
                if x < minx: minx = x
                if x > maxx: maxx = x
                if y < miny: miny = y
                if y > maxy: maxy = y
                for dx in (-1, 0, 1):
                    for dy in (-1, 0, 1):
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < W and 0 <= ny < H:
                            nidx = ny * W + nx
                            if fg[nidx] and label[nidx] == 0:
                                label[nidx] = cur
                                q.append((nx, ny))
            comps.append((cur, area, minx, miny, maxx, maxy))

comps = [c for c in comps if c[1] >= MIN_AREA]
# sort top-to-bottom, then left-to-right (row grouping by 80px band)
comps.sort(key=lambda c: (c[3] // 80, c[2]))

print(f"image {W}x{H}, kept {len(comps)} components")
meta = []
for i, (lbl, area, minx, miny, maxx, maxy) in enumerate(comps):
    pad = 6
    x0 = max(0, minx - pad); y0 = max(0, miny - pad)
    x1 = min(W, maxx + 1 + pad); y1 = min(H, maxy + 1 + pad)
    w = x1 - x0; h = y1 - y0
    crop = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    cp = crop.load()
    for y in range(y0, y1):
        for x in range(x0, x1):
            r, g, b, a = px[x, y]
            l = lum(r, g, b)
            if a == 0 or l < BG:
                continue
            if l < SOFT_HI:
                na = int(255 * (l - BG) / (SOFT_HI - BG))
            else:
                na = a
            cp[x - x0, y - y0] = (r, g, b, na)
    name = f"sprite_{i:02d}_{w}x{h}.png"
    crop.save(os.path.join(OUT, name))
    meta.append((i, area, x0, y0, w, h, name))
    print(f"{i:02d} area={area:7d} bbox=({x0},{y0}) size={w}x{h} -> {name}")
