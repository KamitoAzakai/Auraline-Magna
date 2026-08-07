from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SPRITES = ROOT / "sprites"


def clamp(val, minimum, maximum):
    return max(minimum, min(maximum, val))


def blend_pixel(pixels, width, height, x, y, color):
    if x < 0 or y < 0 or x >= width or y >= height or color[3] <= 0:
        return
    dst_r, dst_g, dst_b, dst_a = pixels[x, y]
    src_r, src_g, src_b, src_a = color
    dst_af = dst_a / 255.0
    src_af = clamp(src_a, 0, 255) / 255.0
    out_af = src_af + dst_af * (1.0 - src_af)
    if out_af <= 0:
        return
    if out_af == 0:
        pixels[x, y] = (0, 0, 0, 0)
        return
    out_r = round(((src_r * src_af) + (dst_r * dst_af * (1.0 - src_af))) / out_af)
    out_g = round(((src_g * src_af) + (dst_g * dst_af * (1.0 - src_af))) / out_af)
    out_b = round(((src_b * src_af) + (dst_b * dst_af * (1.0 - src_af))) / out_af)
    pixels[x, y] = (
        clamp(out_r, 0, 255),
        clamp(out_g, 0, 255),
        clamp(out_b, 0, 255),
        clamp(round(out_af * 255), 0, 255),
    )


def draw_rect(pixels, width, height, x, y, w, h, color):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            blend_pixel(pixels, width, height, xx, yy, color)


def draw_line(pixels, width, height, x0, y0, x1, y1, thickness, color):
    dx = x1 - x0
    dy = y1 - y0
    steps = max(abs(dx), abs(dy))
    if steps == 0:
        steps = 1
    for s in range(steps + 1):
        x = round(x0 + dx * s / steps)
        y = round(y0 + dy * s / steps)
        draw_circle(pixels, width, height, x, y, thickness, color)


def draw_circle(pixels, width, height, cx, cy, radius, color):
    r2 = radius * radius
    for y in range(cy - radius, cy + radius + 1):
        for x in range(cx - radius, cx + radius + 1):
            dx = x - cx
            dy = y - cy
            if dx * dx + dy * dy <= r2:
                blend_pixel(pixels, width, height, x, y, color)


def draw_ring(pixels, width, height, cx, cy, outer, inner, color):
    outer2 = outer * outer
    inner2 = inner * inner
    for y in range(cy - outer, cy + outer + 1):
        for x in range(cx - outer, cx + outer + 1):
            dx = x - cx
            dy = y - cy
            d2 = dx * dx + dy * dy
            if outer2 >= d2 >= inner2:
                blend_pixel(pixels, width, height, x, y, color)


def draw_diamond(pixels, width, height, cx, cy, rx, ry, color):
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            v = abs(x - cx) / rx + abs(y - cy) / ry
            if v <= 1.0:
                blend_pixel(pixels, width, height, x, y, color)


def draw_base(pixels, width, height, accent):
    pad = max(3, int(width * 0.08))
    draw_rect(pixels, width, height, pad, pad, width - pad * 2, height - pad * 2, (36, 41, 48, 255))
    draw_rect(pixels, width, height, pad + 3, pad + 3, width - (pad + 3) * 2, height - (pad + 3) * 2, (50, 58, 68, 255))
    draw_rect(pixels, width, height, pad + 7, pad + 7, width - (pad + 7) * 2, height - (pad + 7) * 2, (30, 35, 42, 255))
    draw_line(pixels, width, height, pad, pad, width - pad - 1, pad, 1, (96, 112, 128, 210))
    draw_line(pixels, width, height, pad, pad, pad, height - pad - 1, 1, (96, 112, 128, 170))
    draw_line(pixels, width, height, width - pad - 1, pad, width - pad - 1, height - pad - 1, 1, (10, 14, 20, 190))
    draw_line(pixels, width, height, pad, height - pad - 1, width - pad - 1, height - pad - 1, 1, (10, 14, 20, 190))
    draw_circle(pixels, width, height, width // 2, height // 2, int(width * 0.17), (*accent, 165))


def save_sprite(path, width, height, draw_fn):
    path.parent.mkdir(parents=True, exist_ok=True)
    image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    pixels = image.load()
    draw_fn(pixels, width, height)
    image.save(path)
    print(f"Wrote {path.relative_to(ROOT)}")


def generate():
    save_sprite(SPRITES / "blocks" / "turrets" / "zenith-pillar.png", 160, 160, lambda p,w,h: (
        draw_base(p, w, h, (184, 146, 255)),
        draw_rect(p, w, h, 68, 18, 24, 112, (54, 44, 74, 255)),
        draw_rect(p, w, h, 74, 12, 12, 124, (184, 146, 255, 120)),
        draw_ring(p, w, h, 80, 80, 34, 27, (255, 107, 56, 190)),
        draw_circle(p, w, h, 80, 80, 16, (255, 255, 255, 210)),
    ))
    save_sprite(SPRITES / "blocks" / "turrets" / "zenith-pillar-orb.png", 160, 160, lambda p,w,h: (
        draw_circle(p, w, h, 80, 62, 19, (184, 146, 255, 120)),
        draw_circle(p, w, h, 80, 62, 12, (255, 255, 255, 210)),
        draw_circle(p, w, h, 75, 57, 4, (255, 107, 56, 170)),
    ))
    save_sprite(SPRITES / "blocks" / "defense" / "phase-resonance-projector-crystal.png", 64, 64, lambda p,w,h: (
        draw_diamond(p, w, h, 32, 28, 14, 21, (184, 146, 255, 210)),
        draw_diamond(p, w, h, 32, 28, 8, 13, (255, 255, 255, 190)),
        draw_line(p, w, h, 20, 44, 44, 44, 2, (152, 255, 217, 120)),
    ))
    save_sprite(SPRITES / "blocks" / "effect" / "abyssal-void-vent-center.png", 64, 64, lambda p,w,h: (
        draw_circle(p, w, h, 32, 32, 18, (0, 0, 0, 240)),
        draw_ring(p, w, h, 32, 32, 22, 17, (184, 146, 255, 150)),
        draw_circle(p, w, h, 32, 32, 7, (12, 4, 24, 255)),
    ))
    save_sprite(SPRITES / "blocks" / "crafting" / "mass-pulverizer.png", 64, 64, lambda p,w,h: (
        draw_base(p, w, h, (255, 121, 94)),
        draw_circle(p, w, h, 24, 32, 10, (88, 96, 105, 255)),
        draw_circle(p, w, h, 40, 32, 10, (88, 96, 105, 255)),
    ))
    save_sprite(SPRITES / "blocks" / "crafting" / "mass-pulverizer-grinder.png", 64, 64, lambda p,w,h: (
        draw_ring(p, w, h, 32, 32, 24, 12, (170, 178, 188, 230)),
        draw_ring(p, w, h, 32, 32, 40, 12, (170, 178, 188, 230)),
        [draw_line(p, w, h, int(24 + __import__("math").cos(i * __import__("math").pi / 4) * 13), int(32 + __import__("math").sin(i * __import__("math").pi / 4) * 13), int(40 - __import__("math").cos(i * __import__("math").pi / 4) * 13), int(32 - __import__("math").sin(i * __import__("math").pi / 4) * 13), 1, (255, 166, 77, 160)) for i in range(8)]
    ))
    save_sprite(SPRITES / "blocks" / "crafting" / "silicon-ultraforge.png", 64, 64, lambda p,w,h: (
        draw_base(p, w, h, (132, 244, 255)),
        draw_rect(p, w, h, 22, 18, 20, 28, (20, 42, 48, 255)),
        draw_circle(p, w, h, 32, 32, 9, (132, 244, 255, 190)),
    ))
    save_sprite(SPRITES / "blocks" / "crafting" / "silicon-ultraforge-ring.png", 64, 64, lambda p,w,h: (
        draw_ring(p, w, h, 32, 32, 22, 19, (255, 255, 255, 170)),
        draw_ring(p, w, h, 32, 32, 15, 13, (132, 244, 255, 150)),
        draw_line(p, w, h, 12, 32, 52, 32, 1, (132, 244, 255, 90)),
        draw_line(p, w, h, 32, 12, 32, 52, 1, (132, 244, 255, 90)),
    ))
    save_sprite(SPRITES / "blocks" / "production" / "quantum-heat-sieve.png", 32, 32, lambda p,w,h: (
        draw_rect(p, w, h, 3, 10, 26, 12, (45, 50, 58, 255)),
        draw_rect(p, w, h, 6, 13, 20, 6, (255, 166, 101, 210)),
        draw_line(p, w, h, 3, 10, 28, 10, 1, (96, 112, 128, 180)),
        draw_line(p, w, h, 3, 21, 28, 21, 1, (12, 14, 18, 180)),
    ))
    save_sprite(SPRITES / "blocks" / "production" / "quantum-heat-sieve-glow.png", 32, 32, lambda p,w,h: (
        draw_rect(p, w, h, 5, 12, 22, 8, (255, 166, 101, 120)),
        draw_line(p, w, h, 6, 16, 25, 16, 2, (255, 230, 190, 150)),
    ))
    save_sprite(SPRITES / "blocks" / "processors" / "auraline-hyper-processor.png", 96, 96, lambda p,w,h: (
        draw_base(p, w, h, (184, 146, 255)),
        draw_rect(p, w, h, 28, 28, 40, 40, (25, 19, 39, 255)),
        draw_circle(p, w, h, 48, 48, 15, (184, 146, 255, 190)),
    ))
    save_sprite(SPRITES / "blocks" / "processors" / "auraline-hyper-processor-rings.png", 96, 96, lambda p,w,h: (
        draw_ring(p, w, h, 48, 48, 32, 29, (184, 146, 255, 145)),
        draw_ring(p, w, h, 48, 48, 22, 20, (152, 255, 217, 130)),
        draw_line(p, w, h, 16, 48, 80, 48, 1, (255, 255, 255, 95)),
        draw_line(p, w, h, 48, 16, 48, 80, 1, (255, 255, 255, 95)),
    ))
    save_sprite(SPRITES / "blocks" / "power" / "steam-fusion-generator-bottom.png", 64, 64, lambda p,w,h: (
        draw_rect(p, w, h, 7, 7, 50, 50, (24, 29, 36, 255)),
        draw_rect(p, w, h, 12, 12, 40, 40, (43, 50, 60, 255)),
        draw_ring(p, w, h, 32, 32, 18, 13, (96, 112, 128, 160)),
        draw_line(p, w, h, 12, 52, 52, 52, 1, (8, 10, 14, 170)),
    ))
    save_sprite(SPRITES / "blocks" / "production" / "oil-seismic-production-pump-bottom.png", 96, 96, lambda p,w,h: (
        draw_rect(p, w, h, 10, 10, 76, 76, (31, 29, 26, 255)),
        draw_rect(p, w, h, 16, 16, 64, 64, (52, 47, 38, 255)),
        draw_ring(p, w, h, 48, 48, 27, 20, (83, 69, 46, 180)),
        draw_line(p, w, h, 18, 74, 78, 74, 2, (15, 12, 10, 170)),
    ))
    save_sprite(SPRITES / "blocks" / "production" / "tectonic-drill-bottom.png", 96, 96, lambda p,w,h: (
        draw_rect(p, w, h, 9, 9, 78, 78, (27, 31, 36, 255)),
        draw_rect(p, w, h, 16, 16, 64, 64, (45, 53, 61, 255)),
        draw_ring(p, w, h, 48, 48, 26, 19, (208, 255, 244, 125)),
    ))
    save_sprite(SPRITES / "blocks" / "crafting" / "petroleum-synthesizer-bottom.png", 96, 96, lambda p,w,h: (
        draw_rect(p, w, h, 10, 10, 76, 76, (31, 29, 26, 255)),
        draw_rect(p, w, h, 20, 20, 56, 56, (52, 47, 38, 255)),
        draw_ring(p, w, h, 48, 48, 20, 14, (96, 112, 128, 160)),
        draw_line(p, w, h, 24, 24, 72, 24, 1, (255, 255, 255, 80)),
        draw_line(p, w, h, 24, 72, 72, 72, 1, (255, 255, 255, 80)),
        draw_line(p, w, h, 24, 24, 24, 72, 1, (255, 255, 255, 80)),
        draw_line(p, w, h, 72, 24, 72, 72, 1, (255, 255, 255, 80)),
    ))
    # phase-link-conduit-bottom variants
    save_sprite(SPRITES / "blocks" / "liquid-routing" / "phase-link-conduit-bottom-2.png", 32, 32, lambda p,w,h: (
        draw_rect(p, w, h, 0, 14, 32, 4, (184, 146, 255, 210)),
        draw_rect(p, w, h, 14, 0, 4, 32, (184, 146, 255, 210)),
    ))
    save_sprite(SPRITES / "blocks" / "liquid-routing" / "phase-link-conduit-bottom-3.png", 32, 32, lambda p,w,h: (
        draw_diamond(p, w, h, 16, 16, 12, 12, (184, 146, 255, 190)),
        draw_circle(p, w, h, 16, 16, 4, (255, 255, 255, 175)),
    ))
    save_sprite(SPRITES / "blocks" / "liquid-routing" / "phase-link-conduit-bottom-4.png", 32, 32, lambda p,w,h: (
        draw_ring(p, w, h, 16, 16, 14, 10, (152, 255, 217, 160)),
        draw_circle(p, w, h, 16, 16, 3, (255, 255, 255, 210)),
    ))


if __name__ == '__main__':
    generate()
