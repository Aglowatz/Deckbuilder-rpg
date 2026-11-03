"""Size pass Nov 3, Part 2: an objective check of Vorbis bitrates against the WAV master, plus the blind A/B folder.

    python tools/music/bitrate_check.py IDS...                      metrics table (markdown) for <renders>/<ID>/<ID>_q{2,3,4}.ogg + <ID>.ogg
    python tools/music/bitrate_check.py --ab "<folder>" IDS...      also copies every variant + the in-game file as <ID>_A..D.ogg (shuffled)
                                                                    and writes KEY.txt (which letter is which) into the folder

Needs the WAV master next to the variants (render with WP_KEEP_WAV=1 WP_VORBIS_EXTRA=2,3,4). Metrics, per variant, after sample-exact
alignment to the master:
  bw_khz     effective bandwidth: the highest frequency where the long-term spectrum stays within 6 dB of the master (the encoder lowpass)
  snr_<band> 5th percentile (the worst frames) of the per-frame band SNR of the coding noise (master - decoded) in dB; the band's own
             signal masks noise that sits 13-15 dB and more below it, so values under about 12 dB in the 2-14 kHz bands are the ones to
             listen for ("swirl" on strings and cymbals)
  pre_echo   in the 20 ms before each onset (spectral-flux peaks of the master), the 2-16 kHz energy of the decoded file relative to the
             master, mean dB over onsets; above +3 dB the smear before transients is likely audible
  lsd_hi     log-spectral distance in the 8-16 kHz band (mean |dB| per bin per frame): fizz / sparkle changes
"""
import argparse
import os
import random
import shutil
import subprocess
import sys

import numpy as np
import scipy.io.wavfile as wf
import scipy.signal as sg

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from lib import render as R  # noqa: E402

SR = R.SR
BANDS = [(0, 2000), (2000, 4000), (4000, 8000), (8000, 14000), (14000, 20000)]
BAND_NAMES = ['0-2k', '2-4k', '4-8k', '8-14k', '14-20k']
REPO = os.path.dirname(os.path.dirname(HERE))


def decode(ff, path):
    x = R.decode(ff, path)
    return x if x.ndim == 2 else x[:, None]


def mono(x):
    return x.mean(axis=1)


def align(ref, enc, search=4800):
    """Sample offset of `enc` relative to `ref` (cross-correlation over the first 3 s), then both trimmed to the common length."""
    n = min(len(ref), len(enc), 3 * SR)
    a = ref[:n] - ref[:n].mean()
    b = enc[:n] - enc[:n].mean()
    corr = sg.correlate(b, a, mode='full', method='fft')
    lags = sg.correlation_lags(len(b), len(a), mode='full')
    keep = np.abs(lags) <= search
    lag = int(lags[keep][np.argmax(corr[keep])])
    if lag > 0:
        enc = enc[lag:]
    elif lag < 0:
        ref = ref[-lag:]
    m = min(len(ref), len(enc))
    return ref[:m], enc[:m], lag


def spectra(x, n=2048, hop=512):
    f, t, Z = sg.stft(x, fs=SR, nperseg=n, noverlap=n - hop, window='hann', padded=False, boundary=None)
    return f, np.abs(Z) ** 2


def band_mask(f, lo, hi):
    return (f >= lo) & (f < hi)


def metrics(ref, enc):
    ref, enc, lag = align(ref, enc)
    noise = ref - enc
    f, P_ref = spectra(ref)
    _, P_enc = spectra(enc)
    _, P_noise = spectra(noise)
    eps = 1e-12
    out = {'lag': lag}
    # effective bandwidth from the long-term spectra
    lt_ref = 10 * np.log10(P_ref.mean(axis=1) + eps)
    lt_enc = 10 * np.log10(P_enc.mean(axis=1) + eps)
    audible = lt_ref > lt_ref.max() - 80
    within = (lt_enc >= lt_ref - 6) & audible
    bw = 0.0
    for i in range(len(f) - 1, -1, -1):
        if within[i] and f[i] <= 20000:
            bw = f[i]
            break
    out['bw_khz'] = round(bw / 1000, 1)
    # per-frame band SNR of the coding noise, 5th percentile over frames that carry signal in the band
    for (lo, hi), name in zip(BANDS, BAND_NAMES):
        m = band_mask(f, lo, hi)
        s = P_ref[m].sum(axis=0)
        nz = P_noise[m].sum(axis=0)
        active = s > s.max() * 1e-5
        snr = 10 * np.log10((s[active] + eps) / (nz[active] + eps))
        out['snr_' + name] = round(float(np.percentile(snr, 5)), 1) if len(snr) else float('nan')
    # pre-echo: energy in the 20 ms before onsets (master flux peaks), 2-16 kHz
    hop_s = 512 / SR
    m_hi = band_mask(f, 2000, 16000)
    flux = np.maximum(np.diff(np.sqrt(P_ref[m_hi]), axis=1), 0).sum(axis=0)
    if len(flux):
        thr = np.percentile(flux, 97)
        peaks, _ = sg.find_peaks(flux, height=thr, distance=int(0.3 / hop_s))
        ratios = []
        pre = max(1, int(round(0.02 / hop_s)))
        for p in peaks:
            i = p + 1  # diff index -> frame index of the onset
            a, b = max(0, i - pre), i
            if b <= a:
                continue
            e_ref = P_ref[m_hi][:, a:b].sum() + eps
            e_enc = P_enc[m_hi][:, a:b].sum() + eps
            ratios.append(10 * np.log10(e_enc / e_ref))
        out['pre_echo_db'] = round(float(np.mean(ratios)), 2) if ratios else float('nan')
        out['onsets'] = len(ratios)
    # log-spectral distance 8-16 kHz
    m = band_mask(f, 8000, 16000)
    lr = 10 * np.log10(P_ref[m] + eps)
    le = 10 * np.log10(P_enc[m] + eps)
    frames = P_ref[m].sum(axis=0) > P_ref[m].sum(axis=0).max() * 1e-4
    out['lsd_hi'] = round(float(np.abs(lr[:, frames] - le[:, frames]).mean()), 2) if frames.any() else float('nan')
    return out


def kbps(path, seconds):
    return round(os.path.getsize(path) * 8 / seconds / 1000)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('ids', nargs='+')
    ap.add_argument('--ab', default='', help='folder for the blind A/B copies + KEY.txt')
    ap.add_argument('--qs', default='2,3,4')
    ap.add_argument('--seed', type=int, default=1103)
    a = ap.parse_args()
    _, _, ff = R.tool_paths()
    renders = os.path.join(os.environ.get('WP_MUSIC_TOOLS', R.DEFAULT_TOOLS), 'renders')
    qs = [q.strip() for q in a.qs.split(',')]
    rows = []
    key_lines = []
    rng = random.Random(a.seed)
    if a.ab:
        os.makedirs(a.ab, exist_ok=True)
    for id in a.ids:
        d = os.path.join(renders, id)
        wav = os.path.join(d, f'{id}.wav')
        if not os.path.exists(wav):
            print(f'{id}: no WAV master in {d} (render with WP_KEEP_WAV=1)')
            continue
        sr, master = wf.read(wav)
        master = master.astype(np.float32)
        if master.ndim == 1:
            master = master[:, None]
        ref = mono(master)
        seconds = len(ref) / SR
        variants = [(f'q{q}', os.path.join(d, f'{id}_q{q}.ogg')) for q in qs] + [('q6 (render)', os.path.join(d, f'{id}.ogg'))]
        sting = id.startswith('STG-')
        game = os.path.join(REPO, 'assets', 'audio', 'stings' if sting else 'music', f'{id}.wav' if sting else f'{id}.ogg')
        for label, path in variants:
            if not os.path.exists(path):
                continue
            enc = mono(decode(ff, path))
            m = metrics(ref, enc)
            m.update({'id': id, 'variant': label, 'kbps': kbps(path, seconds), 'kb': round(os.path.getsize(path) / 1024)})
            rows.append(m)
        if a.ab:
            choices = [(f'q{q}', os.path.join(d, f'{id}_q{q}.ogg')) for q in qs]
            if os.path.exists(game):
                choices.append(('current in-game file', game))
            rng.shuffle(choices)
            for letter, (label, path) in zip('ABCDEF', choices):
                ext = os.path.splitext(path)[1]
                shutil.copyfile(path, os.path.join(a.ab, f'{id}_{letter}{ext}'))
                key_lines.append(f'{id}_{letter}{ext}: {label}')
    cols = ['id', 'variant', 'kbps', 'kb', 'bw_khz'] + ['snr_' + n for n in BAND_NAMES] + ['pre_echo_db', 'onsets', 'lsd_hi', 'lag']
    print('| ' + ' | '.join(cols) + ' |')
    print('|' + '---|' * len(cols))
    for r in rows:
        print('| ' + ' | '.join(str(r.get(c, '')) for c in cols) + ' |')
    if a.ab:
        with open(os.path.join(a.ab, 'KEY.txt'), 'w', encoding='utf-8') as fh:
            fh.write('Blind bitrate test (Size pass Nov 3). Listen first, then open this.\n')
            fh.write('q2 / q3 / q4 = Vorbis quality levels encoded from the fresh WAV master; "current in-game file" = the file shipped in v0.5.1 (q6).\n')
            fh.write('Stings (STG-) ship as WAV (QOA in the pack) regardless of this test; the STG row is for reference only.\n\n')
            fh.write('\n'.join(key_lines) + '\n')
        print(f'\nA/B folder: {a.ab} ({len(key_lines)} files + KEY.txt)')


if __name__ == '__main__':
    main()
