import sys
from PIL import Image

def key_out_green(src, dst):
    im = Image.open(src).convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            # Green screen: green clearly dominates red and blue.
            if g > 90 and g > int(r * 1.35) and g > int(b * 1.35):
                px[x, y] = (r, g, b, 0)
            elif g > 80 and g > r and g > b:
                # soft edge: reduce green spill and partial alpha
                spill = min(r, b)
                na = int(255 * (1 - (g - spill) / max(1, g)))
                px[x, y] = (min(r, spill + 20), spill, min(b, spill + 20), max(0, min(255, na)))
    # crop to content
    bbox = im.getbbox()
    if bbox:
        im = im.crop(bbox)
    im.save(dst)
    print(f"{src} -> {dst} {im.size}")

if __name__ == "__main__":
    for s, d in [(sys.argv[1], sys.argv[2]), (sys.argv[3], sys.argv[4])]:
        key_out_green(s, d)
