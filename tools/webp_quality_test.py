"""Size pass Nov 3, Part 3: lossy WebP quality A/B on the worst cases (faces, gradients, line art, gold trim).

    python tools/webp_quality_test.py [--out docs/art/size_pass] [--qs 75,80,85,92] SPEC...
    SPEC = <path to a source image>[:x,y[,x,y...]]   crop centres (source pixels) for the 100 % crops; default: three automatic ones
           (the sharpest block, the smoothest bright block, the centre)

For every source: encodes with the same encoder Godot's importer uses (libwebp, through ffmpeg) at each quality, measures PSNR / SSIM
(grey, 7x7 gaussian) / the 99.9th percentile of the absolute error and the file size, and writes <out>/<name>_sheet.png: one row per
crop, columns = source then each quality at 100 % zoom (so a 1:1 pixel look), labelled. Judge with the eye; keep a quality only when the
difference does not show at play size.
"""
import argparse
import os
import shutil
import subprocess
import sys
import tempfile

import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy.ndimage import gaussian_filter, uniform_filter

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(HERE, 'music'))
from lib import render as R  # noqa: E402  (ffmpeg path lookup)

CROP = (320, 240)


def ssim(a, b):
    a = a.astype(np.float64); b = b.astype(np.float64)
    mu_a = gaussian_filter(a, 1.5); mu_b = gaussian_filter(b, 1.5)
    saa = gaussian_filter(a * a, 1.5) - mu_a ** 2
    sbb = gaussian_filter(b * b, 1.5) - mu_b ** 2
    sab = gaussian_filter(a * b, 1.5) - mu_a * mu_b
    c1, c2 = (0.01 * 255) ** 2, (0.03 * 255) ** 2
    m = ((2 * mu_a * mu_b + c1) * (2 * sab + c2)) / ((mu_a ** 2 + mu_b ** 2 + c1) * (saa + sbb + c2))
    return float(m.mean())


def auto_crops(gray, w, h):
    """Three interesting centres: the sharpest block (edges / line art / trim), the smoothest bright block (gradient / skin), the centre."""
    cw, ch = CROP
    lap = np.abs(gaussian_filter(gray, 1.0) - gaussian_filter(gray, 3.0))
    sharp = uniform_filter(lap, (ch, cw))
    smooth = uniform_filter(lap, (ch, cw)) + (255 - uniform_filter(gray, (ch, cw))) * 0.1
    valid = np.zeros_like(sharp, dtype=bool)
    valid[ch // 2:h - ch // 2, cw // 2:w - cw // 2] = True
    sharp[~valid] = -1; smooth[~valid] = 1e9
    ys, xs = np.unravel_index(np.argmax(sharp), sharp.shape)
    yg, xg = np.unravel_index(np.argmin(smooth), smooth.shape)
    return [(int(xs), int(ys)), (int(xg), int(yg)), (w // 2, h // 2)]


def encode(ff, png, q, out):
    subprocess.run([ff, '-v', 'error', '-y', '-i', png, '-c:v', 'libwebp', '-quality', str(q), '-compression_level', '6', out], check=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('specs', nargs='+')
    ap.add_argument('--out', default='docs/art/size_pass')
    ap.add_argument('--qs', default='75,80,85,92')
    a = ap.parse_args()
    _, _, ff = R.tool_paths()
    out_dir = os.path.join(REPO, a.out)
    os.makedirs(out_dir, exist_ok=True)
    qs = [int(q) for q in a.qs.split(',')]
    try:
        font = ImageFont.truetype('arial.ttf', 14)
    except Exception:
        font = ImageFont.load_default()
    rows = []
    for spec in a.specs:
        src, _, centres = spec.partition(':')
        src_path = src if os.path.isabs(src) else os.path.join(REPO, src)
        name = os.path.splitext(os.path.basename(src_path))[0]
        img = Image.open(src_path).convert('RGBA')
        w, h = img.size
        rgb = np.asarray(img.convert('RGB'))
        gray = rgb.mean(axis=2)
        if centres:
            nums = [int(v) for v in centres.split(',')]
            pts = list(zip(nums[0::2], nums[1::2]))
        else:
            pts = auto_crops(gray, w, h)
        variants = []
        with tempfile.TemporaryDirectory() as tmp:
            png = os.path.join(tmp, 'src.png')
            img.save(png)
            for q in qs:
                o = os.path.join(tmp, f'q{q}.webp')
                encode(ff, png, q, o)
                dec = Image.open(o).convert('RGBA')
                drgb = np.asarray(dec.convert('RGB'))
                err = np.abs(drgb.astype(np.int16) - rgb.astype(np.int16))
                mse = float((err.astype(np.float64) ** 2).mean())
                psnr = 10 * np.log10(255 ** 2 / mse) if mse > 0 else 99.0
                s = ssim(gray, drgb.mean(axis=2))
                kb = os.path.getsize(o) / 1024
                rows.append({'name': name, 'size': f'{w}x{h}', 'q': q, 'kb': round(kb), 'psnr': round(psnr, 2), 'ssim': round(s, 4), 'p999': int(np.percentile(err, 99.9)), 'max': int(err.max())})
                variants.append((f'q{q}  {kb:.0f} KB  SSIM {s:.4f}', dec))
        cw, ch = CROP
        cols = 1 + len(variants)
        sheet = Image.new('RGB', (cols * (cw + 8) + 8, len(pts) * (ch + 28) + 36), (24, 24, 24))
        d = ImageDraw.Draw(sheet)
        d.text((8, 8), f'{name} {w}x{h} - 100 % crops: source then each lossy WebP quality (libwebp, the importer\'s encoder)', fill=(230, 230, 230), font=font)
        for r, (cx, cy) in enumerate(pts):
            box = (max(0, min(w - cw, cx - cw // 2)), max(0, min(h - ch, cy - ch // 2)))
            box = (box[0], box[1], box[0] + cw, box[1] + ch)
            y0 = 36 + r * (ch + 28)
            for c, (label, im) in enumerate([('source (repo file)', img)] + variants):
                x0 = 8 + c * (cw + 8)
                crop = im.crop(box).convert('RGB')
                sheet.paste(crop, (x0, y0 + 20))
                d.text((x0, y0 + 2), f'{label} @ {box[0]},{box[1]}' if c == 0 else label, fill=(230, 230, 230), font=font)
        sheet_path = os.path.join(out_dir, f'{name}_sheet.png')
        sheet.save(sheet_path, optimize=True)
        print(f'{name}: sheet {os.path.relpath(sheet_path, REPO)}')
    print('\n| Image | Size | q | KB | PSNR dB | SSIM | err p99.9 | err max |\n|---|---|---:|---:|---:|---:|---:|---:|')
    for r in rows:
        print(f"| {r['name']} | {r['size']} | {r['q']} | {r['kb']} | {r['psnr']} | {r['ssim']} | {r['p999']} | {r['max']} |")


if __name__ == '__main__':
    main()
