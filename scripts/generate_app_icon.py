#!/usr/bin/env python3
import os
import struct
import subprocess
import zlib


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SOURCE_IMAGE = os.path.join(ROOT, "Resources", "SpeedProofIconSource.png")
ICONSET = os.path.join(ROOT, "Resources", "AppIcon.iconset")
ICNS_PATH = os.path.join(ROOT, "Resources", "SpeedProof.icns")


def resize_icon(filename, size):
    output_path = os.path.join(ICONSET, filename)
    subprocess.run(
        ["sips", "-z", str(size), str(size), SOURCE_IMAGE, "--out", output_path],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    apply_black_background(output_path)


def png_chunks(data):
    offset = 8
    while offset < len(data):
        length = struct.unpack(">I", data[offset : offset + 4])[0]
        kind = data[offset + 4 : offset + 8]
        chunk_data = data[offset + 8 : offset + 8 + length]
        yield kind, chunk_data
        offset += length + 12


def unfilter_scanline(filter_type, scanline, previous, bytes_per_pixel):
    result = bytearray(scanline)
    for index, value in enumerate(scanline):
        left = result[index - bytes_per_pixel] if index >= bytes_per_pixel else 0
        up = previous[index] if previous else 0
        up_left = previous[index - bytes_per_pixel] if previous and index >= bytes_per_pixel else 0

        if filter_type == 1:
            result[index] = (value + left) & 0xFF
        elif filter_type == 2:
            result[index] = (value + up) & 0xFF
        elif filter_type == 3:
            result[index] = (value + ((left + up) // 2)) & 0xFF
        elif filter_type == 4:
            predictor = left + up - up_left
            pa = abs(predictor - left)
            pb = abs(predictor - up)
            pc = abs(predictor - up_left)
            chosen = left if pa <= pb and pa <= pc else (up if pb <= pc else up_left)
            result[index] = (value + chosen) & 0xFF
        elif filter_type != 0:
            raise ValueError(f"Unsupported PNG filter: {filter_type}")
    return bytes(result)


def png_chunk(kind, data):
    return (
        struct.pack(">I", len(data))
        + kind
        + data
        + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
    )


def write_rgba_png(path, width, height, pixels):
    raw = bytearray()
    row_bytes = width * 4
    for y in range(height):
        raw.append(0)
        raw.extend(pixels[y * row_bytes : (y + 1) * row_bytes])

    png = b"\x89PNG\r\n\x1a\n"
    png += png_chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    png += png_chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += png_chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


def apply_black_background(path):
    with open(path, "rb") as f:
        data = f.read()

    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"Not a PNG: {path}")

    width = height = color_type = interlace = None
    idat = bytearray()
    for kind, chunk_data in png_chunks(data):
        if kind == b"IHDR":
            width, height, bit_depth, color_type, _, _, interlace = struct.unpack(">IIBBBBB", chunk_data)
            if bit_depth != 8 or interlace != 0 or color_type not in (2, 6):
                raise ValueError(f"Unsupported PNG format: {path}")
        elif kind == b"IDAT":
            idat.extend(chunk_data)

    channels = 4 if color_type == 6 else 3
    row_bytes = width * channels
    decompressed = zlib.decompress(bytes(idat))
    pixels = bytearray(width * height * 4)
    previous = None
    source_offset = 0
    target_offset = 0
    for y in range(height):
        filter_type = decompressed[source_offset]
        source_offset += 1
        scanline = decompressed[source_offset : source_offset + row_bytes]
        source_offset += row_bytes
        row = unfilter_scanline(filter_type, scanline, previous, channels)
        previous = row

        for x in range(width):
            src = x * channels
            r = row[src]
            g = row[src + 1]
            b = row[src + 2]

            # Keep the yellow bolt and its warm glow, remove the dark glass tile.
            warmth = min(r, g) - b * 0.55
            yellow_bias = (r + g) / 2 - b
            if r > 180 and g > 125 and b < 130:
                mask_alpha = 255
            elif r > 105 and g > 62 and r > b * 1.18 and g > b * 0.85:
                mask_alpha = max(0, min(255, int(round((warmth - 28) * 4.2))))
            elif yellow_bias > 35 and r > 80 and g > 45:
                mask_alpha = max(0, min(160, int(round((yellow_bias - 35) * 3.0))))
            else:
                mask_alpha = 0

            source_alpha = row[src + 3] if channels == 4 else 255
            effective_alpha = source_alpha * mask_alpha / 255
            pixels[target_offset : target_offset + 4] = bytes((
                int(round(row[src] * effective_alpha / 255)),
                int(round(row[src + 1] * effective_alpha / 255)),
                int(round(row[src + 2] * effective_alpha / 255)),
                255,
            ))
            target_offset += 4

    write_rgba_png(path, width, height, pixels)


def write_icns():
    subprocess.run(
        ["iconutil", "-c", "icns", ICONSET, "-o", ICNS_PATH],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def main():
    if not os.path.exists(SOURCE_IMAGE):
        raise FileNotFoundError(f"Missing icon source: {SOURCE_IMAGE}")

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
        resize_icon(filename, size)

    write_icns()


if __name__ == "__main__":
    main()
