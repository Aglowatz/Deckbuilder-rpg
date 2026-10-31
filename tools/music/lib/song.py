"""Song: the zone-demo score engine (Music_Source/zone_demos/musiclib.py) on top of Score.

The three approved zone demos (ZONE-DNA, ZONE-BUFFET, ZONE-DUMP, Oct 31) were written against musiclib.Song: explicit MIDI channels and raw
GM program numbers, chord lists inside melodies, `tr=` / `arc=` keywords, CC ramps and a sidechain-style `pump`. This subclass keeps that
API so the demos port line for line (and give the same notes: the same humanising draws from the same seed), while every Score helper,
the motif log, sections and the renderer stay available. Zone scores in Music Pass 2 may use either style.
"""
from .score import Score
from .theory import p, REST


class Song(Score):
    def __init__(self, id, bpm, bars, meter=(4, 4), key='', seed=1, kind='loop', jitter=0.018):
        super().__init__(id, bpm, bars, meter=meter, key=key, seed=seed, kind=kind, human=(jitter, 5))

    @property
    def bpb(self):
        return self.bar_q

    def add(self, name, chan, prog, pan=64, rev=90, vol=90, bank=0):
        """musiclib.add: an explicit channel number and a raw GM program (bank 0 unless given)."""
        self.channel(name, prog, pan=pan, reverb=rev, vol=vol, chan=chan)
        if bank:
            self.ch[name]['bank'] = bank
        return name

    def B(self, bar, beat=0.0):
        return bar * self.bar_q + beat

    def note(self, ch, start, dur, pitch, vel, human=True, role=None):
        if pitch is None or pitch == REST:
            return
        super().note(ch, start, max(0.05, dur), pitch, vel, human=human, role=role)

    def line(self, ch, bar, mel, vel, tr=0, legato=0.95, arc=True, beat=0.0, role=None, transpose=None, shape=None):
        """musiclib.line (chord lists allowed). Also accepts Score's `transpose` / `shape` names so s.mel / s.motif work."""
        tr = transpose if transpose is not None else tr
        arc = shape if shape is not None else arc
        t = self.B(bar, beat)
        total = sum(d for _, d in mel) or 1
        pos = 0.0
        for n, d in mel:
            if n != REST:
                a = 1 + (0.10 * (1 - abs(2 * pos / total - 1)) if arc else 0)
                vv = vel * a + (4 if d >= 1.5 else 0)
                for k in (n if isinstance(n, (list, tuple)) else [n]):
                    self.note(ch, t + pos, d * legato, p(k) + tr, vv, role=role)
            pos += d
        return t + pos

    def chord(self, ch, start, dur, notes, vel, tr=0, spread=0.0):
        """Absolute-beat chord (musiclib.chord)."""
        for i, n in enumerate(notes):
            self.note(ch, start + i * spread, dur, p(n) + tr, vel)

    def ramp(self, ch, bar, bars, lo, hi, shape='lin', ctrl=11):
        s = self.B(bar)
        span = bars * self.bar_q
        steps = max(2, int(bars * 8))
        for i in range(steps + 1):
            f = i / steps
            g = (f * 2 if f < 0.5 else 2 - f * 2) if shape == 'arch' else f
            self._cc(ch, s + span * f, ctrl, int(lo + (hi - lo) * g))

    def set_cc(self, ch, beat, value, ctrl=11):
        self._cc(ch, beat, ctrl, int(value))

    def pump(self, ch, bar, bars, lo=40, hi=110, per_beat=1):
        """Sidechain-style ducking: dip on every beat, swell back up (the EDM pad pump)."""
        for b in range(int(bars * self.bar_q * per_beat)):
            t = self.B(bar) + b / per_beat
            seg = 1.0 / per_beat
            self._cc(ch, t, 11, lo)
            self._cc(ch, t + seg * 0.35, 11, int(lo + (hi - lo) * 0.7))
            self._cc(ch, t + seg * 0.8, 11, hi)

    def _cc(self, ch, beat, ctrl, value):
        if ctrl == 11:
            self.cc11[ch].append((beat, value))
        else:
            self.ccs[ch].append((beat, ctrl, value))
