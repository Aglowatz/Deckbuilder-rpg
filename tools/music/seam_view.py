"""Print the level (dB RMS) in 0.25 s steps across a loop's seam: the last N seconds, then the first N.

    python tools/music/seam_view.py C:/Dev/music_tools/renders/MUS-TITLE/MUS-TITLE.ogg [seconds]
"""
import os
import sys
import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import render as R  # noqa: E402

_, _, ff = R.tool_paths()
x = R.decode(ff, sys.argv[1])
n = float(sys.argv[2]) if len(sys.argv) > 2 else 3.0
k = int(0.25 * R.SR)
seg = np.vstack([x[-int(n * R.SR):], x[:int(n * R.SR)]])
row = []
for i in range(0, len(seg) - k + 1, k):
    row.append(f'{R.rms_db(seg[i:i + k]):6.1f}')
half = len(row) // 2
print('end  :', ' '.join(row[:half]))
print('start:', ' '.join(row[half:]))
print(R.seam_report(x))
