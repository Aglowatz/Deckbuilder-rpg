"""Compare two renders of the same score: length, loudness, seam, and how alike they sound (band-energy envelopes over time).

    python tools/music/compare_audio.py reference.ogg new.ogg
"""
import sys
import os
import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import render as R  # noqa: E402

_, _, ff = R.tool_paths()
a = R.decode(ff, sys.argv[1])
b = R.decode(ff, sys.argv[2])


def bands(x, hop=0.25):
    m = x.mean(axis=1)
    n = int(hop * R.SR)
    frames = len(m) // n
    edges = [40, 120, 300, 700, 1500, 3000, 6000, 12000]
    out = np.zeros((frames, len(edges) - 1))
    f = np.fft.rfftfreq(n, 1 / R.SR)
    for i in range(frames):
        s = np.abs(np.fft.rfft(m[i * n:(i + 1) * n] * np.hanning(n))) ** 2
        for j in range(len(edges) - 1):
            out[i, j] = 10 * np.log10(s[(f >= edges[j]) & (f < edges[j + 1])].sum() + 1e-9)
    return out


ba, bb = bands(a), bands(b)
k = min(len(ba), len(bb))
corr = np.corrcoef(ba[:k].ravel(), bb[:k].ravel())[0, 1]
tilt = (ba[:k].mean(axis=0) - ba[:k].mean()) - (bb[:k].mean(axis=0) - bb[:k].mean())
for label, x in (('A', a), ('B', b)):
    print(f"{label}: {len(x) / R.SR:.2f} s, {R.lufs(x):.1f} LUFS, TP {R.true_peak_db(x):.1f} dB, seam {R.seam_report(x)}")
print(f'band-envelope correlation {corr:.3f}; spectral tilt difference per band (dB, A-B): {np.round(tilt, 1).tolist()}')
