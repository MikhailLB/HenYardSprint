import os
from collections import deque
from PIL import Image

SRC = "chicken_sprites.png"
OUT = "sliced2"
os.makedirs(OUT, exist_ok=True)

im = Image.open(SRC).convert("RGBA")
W, H = im.size
px = im.load()

BG_TOL = 50      # a pixel reachable from the border and darker than this = background
EDGE_LUM = 85    # feather ceiling for the 1px silhouette ring
MIN_AREA = 2500

def lum(r, g, b):
    return (r * 299 + g * 587 + b * 114) // 1000

# 1) Flood fill the TRUE background starting from all border pixels.
#    Internal dark details (pupils, outlines) are never reached, so they stay.
is_bg = bytearray(W * H)
q = deque()

def consider(x, y):
    idx = y * W + x
    if is_bg[idx]:
        return
    r, g, b, a = px[x, y]
    if a == 0 or lum(r, g, b) < BG_TOL:
        is_bg[idx] = 1
        q.append((x, y))

for x in range(W):
    consider(x, 0)
    consider(x, H - 1)
for y in range(H):
    consider(0, y)
    consider(W - 1, y)

while q:
    x, y = q.popleft()
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            nx, ny = x + dx, y + dy
            if 0 <= nx < W and 0 <= ny < H and not is_bg[ny * W + nx]:
                consider(nx, ny)

# 2) Build output alpha: background -> 0, foreground -> keep, feather the silhouette ring.
out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
op = out.load()
for y in range(H):
    for x in range(W):
        idx = y * W + x
        if is_bg[idx]:
            continue
        r, g, b, a = px[x, y]
        # is this a silhouette-edge pixel (touches background)?
        edge = False
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                nx, ny = x + dx, y + dy
                if 0 <= nx < W and 0 <= ny < H and is_bg[ny * W + nx]:
                    edge = True
                    break
            if edge:
                break
        na = a
        if edge:
            l = lum(r, g, b)
            if l < EDGE_LUM:
                na = min(a, int(255 * (l / EDGE_LUM)))
        op[x, y] = (r, g, b, na)

# 3) Connected components of the foreground to extract each sprite.
seen = bytearray(W * H)
comps = []
for sy in range(H):
    for sx in range(W):
        idx = sy * W + sx
        if not is_bg[idx] and not seen[idx]:
            st = deque([(sx, sy)])
            seen[idx] = 1
            minx = maxx = sx
            miny = maxy = sy
            area = 0
            while st:
                x, y = st.pop()
                area += 1
                if x < minx: minx = x
                if x > maxx: maxx = x
                if y < miny: miny = y
                if y > maxy: maxy = y
                for dx in (-1, 0, 1):
                    for dy in (-1, 0, 1):
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < W and 0 <= ny < H:
                            j = ny * W + nx
                            if not is_bg[j] and not seen[j]:
                                seen[j] = 1
                                st.append((nx, ny))
            if area >= MIN_AREA:
                comps.append((area, minx, miny, maxx, maxy))

comps.sort(key=lambda c: (c[2] // 80, c[1]))
print(f"kept {len(comps)} components")
for i, (area, minx, miny, maxx, maxy) in enumerate(comps):
    pad = 8
    x0 = max(0, minx - pad); y0 = max(0, miny - pad)
    x1 = min(W, maxx + 1 + pad); y1 = min(H, maxy + 1 + pad)
    crop = out.crop((x0, y0, x1, y1))
    name = f"s_{i:02d}_{x1 - x0}x{y1 - y0}.png"
    crop.save(os.path.join(OUT, name))
    print(f"{i:02d} area={area:7d} size={x1-x0}x{y1-y0} -> {name}")
