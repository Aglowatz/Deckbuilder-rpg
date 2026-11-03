"""Render a Score: FluidSynth (48 kHz) -> hall reverb (render_loop.py, Oct 31) -> loop fold or ring-out -> loudness -> OGG + MP3.

Loops: everything past the loop point is folded back onto the start (seamless), -20 LUFS integrated.
One-shots: the tail rings out (trailing silence trimmed), -17 LUFS.
Both: true peak <= PEAK_TARGET (0.5 dB under the game's -1.5 dBFS ceiling: the importer's Vorbis re-encode adds a few tenths).
"""
import json
import os
import shutil
import subprocess
import tempfile

import numpy as np
import scipy.io.wavfile as wf
import scipy.signal as ss
from scipy.ndimage import minimum_filter1d

SR = 48000
LOOP_LUFS = -20.0
ONESHOT_LUFS = -17.0
# The delivered Vorbis quality: q6 by design (Gainlands rock Nov 3: the designer preferred it by ear; the size pass's q3 renders were undone).
VORBIS_Q = 6
PEAK_TARGET = -2.0
CEILING = -1.5
RENDER_TAIL = 6.0     # seconds rendered past the loop point (synth release + reverb), folded onto the start

DEFAULT_TOOLS = r'C:\Dev\music_tools'


def tool_paths():
    root = os.environ.get('WP_MUSIC_TOOLS', DEFAULT_TOOLS)
    sf = os.environ.get('WP_SOUNDFONT', os.path.join(root, 'soundfonts', 'FluidR3_GM.sf2'))
    fs = os.environ.get('WP_FLUIDSYNTH', os.path.join(root, 'fluidsynth', 'fluidsynth-v2.6.1-win10-x64-cpp11', 'bin', 'fluidsynth.exe'))
    ff = os.environ.get('FFMPEG') or shutil.which('ffmpeg') or 'ffmpeg'
    for label, path in (('soundfont', sf), ('fluidsynth', fs)):
        if not os.path.exists(path):
            raise SystemExit(f'{label} not found at {path} (see docs/audio/music_toolchain.md)')
    return sf, fs, ff


# ---------------------------------------------------------------- loudness (ITU-R BS.1770-4)
def _k_weight(x):
    b1, a1 = [1.53512485958697, -2.69169618940638, 1.19839281085285], [1.0, -1.69065929318241, 0.73248077421585]
    b2, a2 = [1.0, -2.0, 1.0], [1.0, -1.99004745483398, 0.99007225036621]
    return ss.lfilter(b2, a2, ss.lfilter(b1, a1, x, axis=0), axis=0)


def _block_power(x, block=0.4, hop=0.1):
    y = _k_weight(x)
    n, h = int(block * SR), int(hop * SR)
    sq = (y ** 2).sum(axis=1)
    c = np.concatenate([[0.0], np.cumsum(sq)])
    starts = np.arange(0, max(1, len(sq) - n + 1), h)
    return (c[starts + n] - c[starts]) / n, starts


def lufs(x):
    if len(x) < int(0.4 * SR):
        return -70.0
    z, _ = _block_power(x)
    lk = -0.691 + 10 * np.log10(z + 1e-12)
    g = z[lk > -70]
    if not len(g):
        return -70.0
    rel = -0.691 + 10 * np.log10(g.mean()) - 10
    g2 = z[(lk > -70) & (lk > rel)]
    return float(-0.691 + 10 * np.log10(g2.mean()))


def true_peak_db(x):
    up = ss.resample_poly(x, 4, 1, axis=0)
    return float(20 * np.log10(np.max(np.abs(up)) + 1e-12))


def limit(x, ceiling_db, circular, release=0.25, look=0.005):
    """Look-ahead peak limiter (smooth gain envelope). circular=True treats the signal as a loop so the seam stays continuous."""
    thr = 10 ** (ceiling_db / 20)
    pad = int(1.0 * SR)
    xx = np.vstack([x[-pad:], x, x[:pad]]) if circular else x
    up_peak = np.abs(ss.resample_poly(xx, 4, 1, axis=0)).max(axis=1).reshape(-1, 4).max(axis=1)[: len(xx)]
    need = np.minimum(1.0, thr / np.maximum(up_peak, 1e-9))
    # hold each dip across the look-ahead window (both sides, so the gain is down before the peak arrives), then release slowly
    held = minimum_filter1d(need, size=2 * int(look * SR) + 1)
    rel = np.exp(-1.0 / (release * SR))
    dip = 1.0 - held
    released = ss.lfilter([1 - rel], [1, -rel], dip)
    gain = 1.0 - np.maximum(dip, released)
    # a short symmetric smoothing so the gain never steps
    k = np.hanning(int(look * SR) * 2 + 1)
    gain = np.minimum(gain, np.convolve(gain, k / k.sum(), mode='same'))
    y = xx * gain[:, None]
    return y[pad:pad + len(x)] if circular else y


# ---------------------------------------------------------------- hall reverb (render_loop.py)
def hall(x, seed=3, length=2.6, dry=0.82, wet=0.32):
    rng = np.random.default_rng(seed)
    n = int(length * SR)
    t = np.arange(n) / SR
    env = np.exp(-t * 6.9 / length)
    ir = rng.standard_normal((n, 2)) * env[:, None]
    b, a = ss.butter(2, [180 / (SR / 2), 7000 / (SR / 2)], 'band')
    ir = ss.lfilter(b, a, ir, axis=0)
    ir[: int(0.018 * SR)] = 0
    ir /= np.sqrt((ir ** 2).sum(axis=0))
    w = np.stack([ss.fftconvolve(x[:, c], ir[:, c]) for c in range(2)], axis=1)
    d = np.vstack([x, np.zeros((len(w) - len(x), 2))])
    return d * dry + w * wet


def synth(mid_path, wav_path, sf, fs, gain=0.45, room=0.82, damp=0.35, level=0.55, polyphony=512):
    subprocess.run([fs, '-ni', '-g', str(gain), '-r', str(SR), '-F', wav_path, '-o', 'audio.file.format=float',
                    '-o', 'synth.reverb.active=1', '-o', f'synth.reverb.room-size={room}',
                    '-o', f'synth.reverb.damp={damp}', '-o', 'synth.reverb.width=1.0', '-o', f'synth.reverb.level={level}',
                    '-o', 'synth.chorus.active=0', '-o', f'synth.polyphony={polyphony}', sf, mid_path], check=True, capture_output=True)
    sr, x = wf.read(wav_path)
    assert sr == SR
    x = x.astype(np.float64)
    if x.dtype.kind == 'i' or np.max(np.abs(x)) > 4:
        x = x / 32768.0
    return x


# ---------------------------------------------------------------- rock profile (Gainlands rock Nov 3: Music_Source/zone_demos/render_rock.py)
def amp_sim(g, drive=7.0, out=0.55):
    """Guitar amp: pre-EQ (120 Hz high-pass), tanh drive, 4-pole cabinet low-pass at 5.2 kHz, a touch of mid scoop (700-1600 Hz)."""
    b, a = ss.butter(2, 120 / (SR / 2), 'high')
    g = ss.lfilter(b, a, g, axis=0)
    g = np.tanh(g * drive) * out
    b, a = ss.butter(4, 5200 / (SR / 2), 'low')
    g = ss.lfilter(b, a, g, axis=0)
    b, a = ss.butter(2, [700 / (SR / 2), 1600 / (SR / 2)], 'bandstop')
    return 0.75 * g + 0.25 * ss.lfilter(b, a, g, axis=0)


def add_risers(mix, risers, seed=1, level=0.18):
    """White-noise risers: a band-pass sweeping up (300 Hz -> ~6.3 kHz) that swells (t^2.2). risers = [(start_s, length_s)]."""
    rng = np.random.default_rng(seed)
    n = len(mix)
    for start, length in risers:
        s0, L = int(start * SR), int(length * SR)
        noise = rng.standard_normal(L)
        out = np.zeros(L)
        seg = 2048
        for i in range(0, L, seg):
            lo = 300 + 6000 * (i / L) ** 2
            bb, aa = ss.butter(2, [lo / (SR / 2), min(0.95, (lo * 2.2) / (SR / 2))], 'band')
            out[i:i + seg] = ss.lfilter(bb, aa, noise[i:i + seg])
        out *= np.linspace(0, 1, L) ** 2.2 * level
        e = min(n, s0 + L)
        if e > s0:
            mix[s0:e, 0] += out[:e - s0]
            mix[s0:e, 1] += out[:e - s0] * 0.9
    return mix


def glue(mix, seed=3, length=1.6, dry=0.88, wet=0.16, drive=1.6):
    """A shorter, brighter hall than the orchestra's, then light bus saturation (tanh soft knee, normalised to the peak)."""
    rng = np.random.default_rng(seed)
    m = int(length * SR)
    t = np.arange(m) / SR
    ir = rng.standard_normal((m, 2)) * np.exp(-t * 6.9 / length)[:, None]
    b, a = ss.butter(2, [200 / (SR / 2), 6000 / (SR / 2)], 'band')
    ir = ss.lfilter(b, a, ir, axis=0)
    ir[: int(0.012 * SR)] = 0
    ir /= np.sqrt((ir ** 2).sum(axis=0))
    w = np.stack([ss.fftconvolve(mix[:, c], ir[:, c]) for c in range(2)], axis=1)
    y = np.vstack([mix, np.zeros((len(w) - len(mix), 2))]) * dry + w * wet
    pk = np.max(np.abs(y)) + 1e-12
    return np.tanh(y / pk * drive) / np.tanh(drive)


def rock_chain(score, tmp, sf, fs, tail_seconds):
    """The approved Gainlands demo's render: band (everything but score.stem) with synth reverb 0.45, the guitar stem with 0.25 through
    amp_sim, mixed 0.9 / 0.85, noise risers, glue. Returns the stereo mix (loop/one-shot handling and loudness follow in render)."""
    stem = set(score.stem)
    kw = dict(gain=0.5, room=0.6, damp=0.35, polyphony=768)
    parts = []
    for name, sel, level in (('rest', dict(skip=stem), 0.45), ('gtr', dict(only=stem), 0.25)):
        mid = os.path.join(tmp, f'{name}.mid')
        score.to_midi(mid, tail_seconds=tail_seconds, **sel)
        parts.append(synth(mid, os.path.join(tmp, f'{name}.wav'), sf, fs, level=level, **kw) if (stem or name == 'rest') else None)
    rest, gtr = parts
    if gtr is None:
        gtr = np.zeros_like(rest)
    n = max(len(rest), len(gtr))
    rest = np.vstack([rest, np.zeros((n - len(rest), 2))])
    gtr = np.vstack([gtr, np.zeros((n - len(gtr), 2))])
    mix = rest * 0.9 + amp_sim(gtr) * 0.85
    mix = add_risers(mix, [(score.seconds_at(b), score.seconds_at(b + L) - score.seconds_at(b)) for b, L in score.risers])
    return glue(mix)


# ---------------------------------------------------------------- checks on audio
def rms_db(x):
    return float(10 * np.log10(np.mean(x ** 2) + 1e-12))


def seam_report(x):
    """Last second vs first second (dB), and the step across the wrap compared with the file's normal sample-to-sample steps."""
    one = SR
    jump = rms_db(x[-one:]) - rms_db(x[:one])
    d = np.abs(np.diff(x, axis=0)).max(axis=1)
    wrap = float(np.abs(x[0] - x[-1]).max())
    p999 = float(np.percentile(d, 99.9))
    return {'jump_db': round(jump, 2), 'wrap_step': round(wrap, 5), 'p999_step': round(p999, 5),
            'click': bool(wrap > max(p999 * 1.5, 0.01)), 'ok': bool(abs(jump) <= 1.5 and wrap <= max(p999 * 1.5, 0.01))}


def section_arc(x, score):
    """Integrated LUFS per section (score.sections) for the loudness-arc check."""
    secs = score.sections or [(0, 'all')]
    out = []
    for i, (bar, nm) in enumerate(secs):
        a = int(score.seconds_at(bar * score.bar_q) * SR)
        e_bar = secs[i + 1][0] if i + 1 < len(secs) else score.bars
        b = int(score.seconds_at(e_bar * score.bar_q) * SR)
        out.append({'section': nm, 'bar': bar, 'bars': e_bar - bar, 'start_s': round(a / SR, 1), 'lufs': round(lufs(x[a:b]), 1)})
    return out


def decode(ff, path):
    raw = subprocess.run([ff, '-v', 'error', '-i', path, '-f', 'f32le', '-ac', '2', '-ar', str(SR), '-'], capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.float32).reshape(-1, 2).astype(np.float64)


def ffmpeg_loudness(ff, path):
    r = subprocess.run([ff, '-hide_banner', '-nostats', '-i', path, '-af', 'ebur128=peak=true', '-f', 'null', '-'], capture_output=True, text=True)
    txt = r.stderr
    i = txt.rfind('Integrated loudness:')
    seg = txt[i:]
    val = lambda key: float(seg.split(key)[1].split()[0])
    return {'lufs': val('I:'), 'true_peak': val('Peak:'), 'lra': val('LRA:')}


# ---------------------------------------------------------------- main entry
def render(score, mid_out, out_dir, preview_tail=15.0, keep_wav=False):
    """Render `score` to <out_dir>/<id>.ogg + <id>.mp3 (preview); writes the clean .mid to `mid_out`. Returns the report dict."""
    sf, fs, ff = tool_paths()
    os.makedirs(out_dir, exist_ok=True)
    score.to_midi(mid_out)
    loop = score.kind == 'loop'
    with tempfile.TemporaryDirectory() as tmp:
        if score.profile == 'rock':
            y = rock_chain(score, tmp, sf, fs, RENDER_TAIL)
        else:
            rmid = os.path.join(tmp, 'render.mid')
            score.to_midi(rmid, tail_seconds=RENDER_TAIL)
            y = hall(synth(rmid, os.path.join(tmp, 'raw.wav'), sf, fs))
    L = int(round(score.seconds * SR))
    if loop:
        out = y[:L].copy()
        tail = y[L:]
        while len(tail):                       # fold (repeatedly, for tails longer than the loop)
            k = min(len(tail), L)
            out[:k] += tail[:k]
            tail = tail[k:]
    else:
        env = np.abs(y).max(axis=1)
        # one-shots start instantly: cut the synth's lead-in silence (keep 2 ms before the first sound above -60 dBFS)
        first = np.nonzero(env > 10 ** (-60 / 20))[0]
        lead = max(0, int(first[0]) - int(0.002 * SR)) if len(first) else 0
        y = y[lead:]
        L = max(1, L - lead)
        env = env[lead:]
        alive = np.nonzero(env > 10 ** (-70 / 20))[0]
        end = max(L, int(alive[-1]) + int(0.25 * SR)) if len(alive) else L
        fade = int(0.25 * SR)
        if score.max_seconds and end > int(score.max_seconds * SR):
            end = int(score.max_seconds * SR)      # stingers heard constantly: no long tail
            fade = int(0.5 * SR)
        out = y[:end].copy()
        out[-fade:] *= np.linspace(1, 0, fade)[:, None]
    target = score.lufs if score.lufs is not None else (LOOP_LUFS if loop else ONESHOT_LUFS)   # story one-shots set -20
    limited_db = 0.0
    for _ in range(4):
        out *= 10 ** ((target - lufs(out)) / 20)
        tp = true_peak_db(out)
        if tp <= PEAK_TARGET:
            break
        out = limit(out, PEAK_TARGET - 0.3, circular=loop)
        limited_db = max(limited_db, tp - PEAK_TARGET)
    wav = os.path.join(out_dir, f'{score.id}.wav')
    wf.write(wav, SR, out.astype(np.float32))
    if not loop:
        # the game keeps stings as WAV: a 16-bit PCM copy for delivery (deliver.py --approve uses it for STG- IDs)
        wf.write(os.path.join(out_dir, f'{score.id}_pcm16.wav'), SR, np.clip(out * 32767, -32768, 32767).astype(np.int16))
    ogg = os.path.join(out_dir, f'{score.id}.ogg')
    mp3 = os.path.join(out_dir, f'{score.id}.mp3')
    # Size pass Nov 3: the delivered OGG's Vorbis quality is VORBIS_Q (env WP_VORBIS_Q overrides); WP_VORBIS_EXTRA="2,3,4" also writes
    # <ID>_q2.ogg ... next to it for a bitrate A/B; WP_KEEP_WAV=1 keeps the float WAV master (about 60 MB a track) for spectral checks.
    q = os.environ.get('WP_VORBIS_Q', str(VORBIS_Q))
    subprocess.run([ff, '-v', 'error', '-y', '-i', wav, '-c:a', 'libvorbis', '-q:a', q, ogg], check=True)
    for extra in [e for e in os.environ.get('WP_VORBIS_EXTRA', '').split(',') if e.strip()]:
        subprocess.run([ff, '-v', 'error', '-y', '-i', wav, '-c:a', 'libvorbis', '-q:a', extra.strip(),
                        os.path.join(out_dir, f'{score.id}_q{extra.strip()}.ogg')], check=True)
    keep_wav = keep_wav or os.environ.get('WP_KEEP_WAV') == '1'
    prev = np.vstack([out, out[: int(preview_tail * SR)]]) if loop else out
    pw = os.path.join(out_dir, f'{score.id}_preview.wav')
    wf.write(pw, SR, prev.astype(np.float32))
    subprocess.run([ff, '-v', 'error', '-y', '-i', pw, '-c:a', 'libmp3lame', '-b:a', '192k', mp3], check=True)
    os.remove(pw)
    # measure what was actually written
    dec = decode(ff, ogg)
    meas = ffmpeg_loudness(ff, ogg)
    rep = {
        'id': score.id, 'kind': score.kind, 'key': score.key, 'bpm': score.bpm, 'meter': f'{score.meter[0]}/{score.meter[1]}',
        'profile': score.profile, 'bars': score.bars, 'seconds': round(len(dec) / SR, 2), 'loop_seconds': round(score.seconds, 3),
        'lufs': meas['lufs'], 'true_peak': meas['true_peak'], 'lra': meas['lra'], 'limited_db': round(limited_db, 2),
        'peak_ok': bool(meas['true_peak'] <= CEILING), 'lufs_ok': bool(abs(meas['lufs'] - target) <= 0.5),
        'sections': section_arc(dec[:L] if loop else dec, score),
        'motifs': [{'bar': round(b, 2), 'form': f, 'ch': c} for b, f, c in score.motifs],
        'notes': score.note_count(),
        'files': {'ogg': ogg, 'mp3': mp3, 'mid': mid_out},
    }
    if loop:
        rep['seam'] = seam_report(dec[:L] if len(dec) >= L else dec)
    else:
        pk = np.abs(dec).max(axis=1)
        hot = np.nonzero(pk > 10 ** (-30 / 20))[0]
        rep['onset_ms'] = round(1000 * float(hot[0]) / SR, 1) if len(hot) else None
        rep['onset_ok'] = bool(rep['onset_ms'] is not None and rep['onset_ms'] <= 20)
    if not keep_wav:
        os.remove(wav)
    return rep
