#!/usr/bin/env python3
import math
import os
import struct
import zlib


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ICONSET = os.path.join(ROOT, "Resources", "AppIcon.iconset")
ICNS_PATH = os.path.join(ROOT, "Resources", "GraceAI.icns")


def clamp(value, low=0, high=255):
    return max(low, min(high, int(round(value))))


def mix(a, b, t):
    return a + (b - a) * t


def blend(dst, src):
    sr, sg, sb, sa = src
    dr, dg, db, da = dst
    sa /= 255.0
    da /= 255.0
    out_a = sa + da * (1 - sa)
    if out_a <= 0:
        return (0, 0, 0, 0)
    out_r = (sr * sa + dr * da * (1 - sa)) / out_a
    out_g = (sg * sa + dg * da * (1 - sa)) / out_a
    out_b = (sb * sa + db * da * (1 - sa)) / out_a
    return (clamp(out_r), clamp(out_g), clamp(out_b), clamp(out_a * 255))


class Canvas:
    def __init__(self, size):
        self.size = size
        self.pixels = [(0, 0, 0, 0)] * (size * size)

    def set(self, x, y, rgba):
        if 0 <= x < self.size and 0 <= y < self.size:
            idx = y * self.size + x
            self.pixels[idx] = blend(self.pixels[idx], rgba)

    def fill_rounded_background(self):
        n = self.size
        radius = 0.225 * n
        for y in range(n):
            for x in range(n):
                dx = max(radius - x, 0, x - (n - radius))
                dy = max(radius - y, 0, y - (n - radius))
                outside = math.hypot(dx, dy)
                if outside > radius:
                    continue
                edge = radius - outside
                alpha = 255 if edge > 2 else clamp(edge / 2 * 255)
                t = (x + y) / (2 * n)
                r = mix(38, 146, t)
                g = mix(102, 184, t)
                b = mix(226, 255, t)
                self.set(x, y, (r, g, b, alpha))

        self.ellipse(0.12, 0.03, 0.82, 0.55, (255, 255, 255, 46))
        self.ellipse(0.45, 0.40, 1.16, 1.08, (126, 80, 255, 42))
        self.ellipse(-0.20, 0.52, 0.42, 1.15, (255, 216, 95, 34))

    def ellipse(self, x0, y0, x1, y1, color):
        n = self.size
        minx, maxx = int(x0 * n), int(x1 * n)
        miny, maxy = int(y0 * n), int(y1 * n)
        cx, cy = (x0 + x1) * n / 2, (y0 + y1) * n / 2
        rx, ry = max(1, (x1 - x0) * n / 2), max(1, (y1 - y0) * n / 2)
        for y in range(miny, maxy + 1):
            for x in range(minx, maxx + 1):
                d = math.sqrt(((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2)
                if d <= 1.04:
                    edge = max(0, min(1, (1.04 - d) / 0.04))
                    rgba = color[:3] + (clamp(color[3] * edge),)
                    self.set(x, y, rgba)

    def rounded_rect(self, x0, y0, x1, y1, r, color):
        n = self.size
        minx, maxx = int(x0 * n), int(x1 * n)
        miny, maxy = int(y0 * n), int(y1 * n)
        radius = r * n
        for y in range(miny, maxy + 1):
            for x in range(minx, maxx + 1):
                px = min(max(x, x0 * n + radius), x1 * n - radius)
                py = min(max(y, y0 * n + radius), y1 * n - radius)
                d = math.hypot(x - px, y - py)
                if d <= radius + 1.5:
                    edge = 1 if d <= radius else max(0, 1 - (d - radius) / 1.5)
                    rgba = color[:3] + (clamp(color[3] * edge),)
                    self.set(x, y, rgba)

    def line(self, x0, y0, x1, y1, width, color):
        n = self.size
        ax, ay = x0 * n, y0 * n
        bx, by = x1 * n, y1 * n
        minx, maxx = int(min(ax, bx) - width * n), int(max(ax, bx) + width * n)
        miny, maxy = int(min(ay, by) - width * n), int(max(ay, by) + width * n)
        vx, vy = bx - ax, by - ay
        denom = vx * vx + vy * vy or 1
        radius = width * n / 2
        for y in range(miny, maxy + 1):
            for x in range(minx, maxx + 1):
                t = max(0, min(1, ((x - ax) * vx + (y - ay) * vy) / denom))
                px, py = ax + t * vx, ay + t * vy
                d = math.hypot(x - px, y - py)
                if d <= radius + 1:
                    edge = 1 if d <= radius else max(0, 1 - (d - radius))
                    rgba = color[:3] + (clamp(color[3] * edge),)
                    self.set(x, y, rgba)

    def draw_icon(self):
        self.fill_rounded_background()

        # Soft glass card behind the portrait.
        self.rounded_rect(0.18, 0.15, 0.82, 0.88, 0.12, (255, 255, 255, 46))
        self.rounded_rect(0.20, 0.17, 0.80, 0.86, 0.10, (255, 255, 255, 22))

        # Hair silhouette.
        self.ellipse(0.25, 0.18, 0.75, 0.78, (35, 38, 72, 235))
        self.ellipse(0.18, 0.34, 0.47, 0.86, (27, 31, 61, 230))
        self.ellipse(0.53, 0.34, 0.82, 0.86, (27, 31, 61, 230))
        self.ellipse(0.27, 0.16, 0.58, 0.43, (52, 57, 99, 210))

        # Neck and shoulders.
        self.rounded_rect(0.43, 0.58, 0.57, 0.77, 0.04, (238, 184, 156, 255))
        self.ellipse(0.25, 0.70, 0.75, 0.98, (70, 95, 204, 235))
        self.ellipse(0.33, 0.72, 0.67, 0.96, (106, 132, 235, 190))

        # Face.
        self.ellipse(0.32, 0.24, 0.68, 0.65, (248, 204, 178, 255))
        self.ellipse(0.35, 0.25, 0.65, 0.50, (255, 226, 204, 75))

        # Hair fringe.
        self.ellipse(0.28, 0.18, 0.56, 0.36, (39, 42, 79, 245))
        self.ellipse(0.46, 0.18, 0.72, 0.39, (38, 41, 76, 245))
        self.ellipse(0.29, 0.30, 0.43, 0.55, (31, 35, 66, 220))
        self.ellipse(0.57, 0.30, 0.71, 0.55, (31, 35, 66, 220))

        # Facial features.
        self.ellipse(0.39, 0.43, 0.43, 0.46, (25, 29, 48, 245))
        self.ellipse(0.57, 0.43, 0.61, 0.46, (25, 29, 48, 245))
        self.line(0.48, 0.45, 0.46, 0.53, 0.010, (185, 123, 112, 115))
        self.ellipse(0.43, 0.56, 0.57, 0.60, (181, 70, 96, 210))
        self.ellipse(0.45, 0.55, 0.55, 0.58, (238, 119, 139, 190))

        # Subtle voice waves.
        self.line(0.70, 0.42, 0.75, 0.37, 0.014, (255, 211, 82, 180))
        self.line(0.72, 0.50, 0.80, 0.50, 0.014, (255, 211, 82, 170))
        self.line(0.70, 0.58, 0.75, 0.63, 0.014, (255, 211, 82, 160))

        # Shine.
        self.line(0.22, 0.14, 0.76, 0.08, 0.018, (255, 255, 255, 72))

    def write_png(self, path):
        n = self.size
        raw = bytearray()
        for y in range(n):
            raw.append(0)
            for x in range(n):
                raw.extend(self.pixels[y * n + x])

        def chunk(kind, data):
            return (
                struct.pack(">I", len(data))
                + kind
                + data
                + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
            )

        png = b"\x89PNG\r\n\x1a\n"
        png += chunk(b"IHDR", struct.pack(">IIBBBBB", n, n, 8, 6, 0, 0, 0))
        png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        png += chunk(b"IEND", b"")
        with open(path, "wb") as f:
            f.write(png)


def main():
    os.makedirs(ICONSET, exist_ok=True)
    sizes = {
        "icon_16x16.png": 16,
        "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32,
        "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128,
        "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256,
        "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512,
        "icon_512x512@2x.png": 1024,
    }
    for filename, size in sizes.items():
        canvas = Canvas(size)
        canvas.draw_icon()
        canvas.write_png(os.path.join(ICONSET, filename))

    icns_sources = [
        ("icp4", "icon_16x16.png"),
        ("icp5", "icon_32x32.png"),
        ("icp6", "icon_32x32@2x.png"),
        ("ic07", "icon_128x128.png"),
        ("ic08", "icon_128x128@2x.png"),
        ("ic09", "icon_256x256@2x.png"),
        ("ic10", "icon_512x512@2x.png"),
    ]
    chunks = []
    total_size = 8
    for chunk_type, filename in icns_sources:
        with open(os.path.join(ICONSET, filename), "rb") as f:
            data = f.read()
        chunk = chunk_type.encode("ascii") + struct.pack(">I", len(data) + 8) + data
        chunks.append(chunk)
        total_size += len(chunk)

    with open(ICNS_PATH, "wb") as f:
        f.write(b"icns")
        f.write(struct.pack(">I", total_size))
        for chunk in chunks:
            f.write(chunk)


if __name__ == "__main__":
    main()
