"""Checks on a Score's notes (the audio checks live in render.py). See docs/audio/score_bible.md, "Quality checklist"."""
LOW_FLOOR = 28        # E1: no pitched note below it
LOW_ZONE = 48         # below C3 counts as a bass voice
MAX_LOW = 2           # distinct bass pitches sounding together


def _pitched(score):
    for k, c in score.ch.items():
        if c['drums']:
            continue
        for s, d, n, v, role in score.events[k]:
            yield k, s, d, n, v, role


def range_report(score):
    low = sorted({(k, n) for k, s, d, n, v, r in _pitched(score) if n < LOW_FLOOR})
    return {'below_E1': [f'{k}:{n}' for k, n in low], 'ok': not low}


def low_end_report(score, step=0.25):
    """Beats where more than MAX_LOW distinct pitches under C3 sound at once (unison/octave-free count)."""
    grid = {}
    for k, s, d, n, v, r in _pitched(score):
        if n >= LOW_ZONE:
            continue
        a = int(round(s / step))
        b = int(round((s + min(d, 4.0)) / step))
        for i in range(a, max(a + 1, b)):
            grid.setdefault(i, set()).add(n)
    bad = sorted(i for i, ns in grid.items() if len(ns) > MAX_LOW)
    bars = sorted({int(i * step // score.bar_q) for i in bad})
    return {'crowded_steps': len(bad), 'bars': bars[:40], 'ok': len(bad) <= 4}


def melody_report(score):
    """Bars with no lead-melody note, and bars where the loudest accompaniment note out-weighs the melody
    (velocity x channel volume - a rough proxy; GM patches differ in loudness)."""
    q = score.bar_q
    mel_bars, mel_w, acc_w = set(), {}, {}
    notes = list(_pitched(score))
    # a note on a melody onset with the melody's pitch class is a doubling of the tune, not accompaniment
    mel_keys = {(round(s * 4), n % 12) for k, s, d, n, v, role in notes if role == 'mel'}
    for k, s, d, n, v, role in notes:
        w = v * score.ch[k]['vol'] / 127
        b = int(s // q)
        if role == 'mel':
            mel_bars.add(b)
            mel_w[b] = max(mel_w.get(b, 0), w)
        elif n >= 55 and (round(s * 4), n % 12) not in mel_keys:  # accompaniment in the melody's register
            acc_w[b] = max(acc_w.get(b, 0), w)
    silent = [b for b in range(score.bars) if b not in mel_bars]
    buried = [b for b in mel_w if acc_w.get(b, 0) > mel_w[b] * 1.05]
    cover = 1 - len(silent) / score.bars
    return {'coverage': round(cover, 2), 'bars_without_melody': silent, 'buried_bars': sorted(buried),
            'ok': cover >= 0.6 and len(buried) <= score.bars // 10}


def all_checks(score):
    return {'range': range_report(score), 'low_end': low_end_report(score), 'melody': melody_report(score)}
