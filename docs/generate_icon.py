"""Generate PieDay app icon (1024x1024). Solar Geometry — refined."""
from PIL import Image, ImageDraw, ImageFilter
import math

OUT = "/Users/chunlicheng/Desktop/PieDay/docs/icon-1024.png"

SUPERSAMPLE = 3
SIZE = 1024
BIG = SIZE * SUPERSAMPLE

# iOS system colours (the app's category palette)
ORANGE = (255, 159, 10)
BLUE   = (0, 122, 255)
YELLOW = (255, 204, 0)
GREEN  = (52, 199, 89)

# Background gradient — a quiet morning sky
BG_TOP    = (248, 251, 254)
BG_BOTTOM = (225, 235, 248)

img = Image.new("RGB", (BIG, BIG), BG_TOP)
draw = ImageDraw.Draw(img)

for y in range(BIG):
    t = y / (BIG - 1)
    r = int(BG_TOP[0] + (BG_BOTTOM[0] - BG_TOP[0]) * t)
    g = int(BG_TOP[1] + (BG_BOTTOM[1] - BG_TOP[1]) * t)
    b = int(BG_TOP[2] + (BG_BOTTOM[2] - BG_TOP[2]) * t)
    draw.line([(0, y), (BIG, y)], fill=(r, g, b))

# Pie geometry — nudged slightly left so the leader line has breathing room
cx = int(BIG * 0.46)
cy = int(BIG * 0.50)
radius = int(BIG * 0.30)

# (percent, colour, pulled?)
slices = [
    (38, ORANGE, True),
    (30, BLUE,   False),
    (12, YELLOW, False),
    (20, GREEN,  False),
]

# Whisper-soft drop shadow
shadow = Image.new("RGBA", (BIG, BIG), (0, 0, 0, 0))
sd = ImageDraw.Draw(shadow)
sd.ellipse(
    [cx - radius, cy - radius + int(BIG * 0.018),
     cx + radius, cy + radius + int(BIG * 0.018)],
    fill=(35, 55, 95, 55),
)
shadow = shadow.filter(ImageFilter.GaussianBlur(int(BIG * 0.032)))
img.paste(shadow, (0, 0), shadow)

# Slices
start_deg = -90  # 12 o'clock
pulled_info = None
for percent, color, pulled in slices:
    sweep = 360 * percent / 100
    end_deg = start_deg + sweep
    mid_deg = (start_deg + end_deg) / 2

    if pulled:
        mid_rad = math.radians(mid_deg)
        # Subtle pull-out — gap should feel like a held breath, not a break
        offset = int(radius * 0.045)
        ox = cx + math.cos(mid_rad) * offset
        oy = cy + math.sin(mid_rad) * offset
        pulled_info = (ox, oy, mid_rad)
    else:
        ox, oy = cx, cy

    draw.pieslice(
        [ox - radius, oy - radius, ox + radius, oy + radius],
        start_deg, end_deg,
        fill=color,
    )
    start_deg = end_deg

# Leader meridian — from the pulled sector, out to a pin anchor
if pulled_info:
    ox, oy, mid_rad = pulled_info
    cos_m, sin_m = math.cos(mid_rad), math.sin(mid_rad)

    sx = ox + cos_m * radius
    sy = oy + sin_m * radius

    # Knee — radial segment extended outward
    knee_extra = int(radius * 0.30)
    kx = ox + cos_m * (radius + knee_extra)
    ky = oy + sin_m * (radius + knee_extra)

    # Horizontal terminator
    direction = 1 if cos_m >= 0 else -1
    horiz = int(radius * 0.42)
    ex = kx + horiz * direction
    ey = ky

    line_w = int(BIG * 0.009)
    draw.line([(sx, sy), (kx, ky)], fill=ORANGE, width=line_w)
    draw.line([(kx, ky), (ex, ey)], fill=ORANGE, width=line_w)

    # Pin anchor — solid orange ring with a white core (a deliberate observed mark)
    outer_r = int(BIG * 0.022)
    inner_r = int(BIG * 0.010)
    draw.ellipse([ex - outer_r, ey - outer_r, ex + outer_r, ey + outer_r], fill=ORANGE)
    draw.ellipse([ex - inner_r, ey - inner_r, ex + inner_r, ey + inner_r], fill=(255, 255, 255))

img = img.resize((SIZE, SIZE), Image.LANCZOS)
img.save(OUT, optimize=True)
print(f"Saved {OUT}")
