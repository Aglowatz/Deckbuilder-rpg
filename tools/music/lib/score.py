"""Score: the event list one track is written into, plus the orchestration helpers every score shares.

Grown from the MUS-TOWN v04 sketch (G:/My Drive/Card Game Art/Music_Source/MUS-TOWN_v04_score.py): the same note humanising (timing jitter,
velocity spread, phrase arcs), CC11 swells and per-channel pan/reverb, and the same MIDI writer, so the v04 port renders identically.
Beats are quarter notes; `bar` arguments are bar numbers counted from 0 in the score's meter.
"""
import random
import mido
from .theory import p, voice, bass_note, tones, Scale, KIT, REST, length
from .instruments import GM

TPB = 480


class Score:
    def __init__(self, id, bpm, bars, meter=(4, 4), key='', seed=0, kind='loop', human=(0.018, 5)):
        self.id = id
        self.bpm = bpm
        self.bars = bars
        self.meter = meter
        self.bar_q = meter[0] * 4.0 / meter[1]
        self.key = key
        self.kind = kind            # 'loop' (tail folded onto the start) or 'oneshot' (tail rings out)
        self.rng = random.Random(seed)
        self.jitter, self.vel_spread = human
        self.ch = {}                # name -> dict(chan, bank, prog, pan, rev, vol)
        self.events = {}            # name -> [(start, dur, pitch, vel, role)]
        self.cc11 = {}              # name -> [(beat, value)]
        self.ccs = {}               # name -> [(beat, control, value)]
        self.tempos = [(0.0, bpm)]
        self.sections = []          # (bar, name)
        self.motifs = []            # (bar, form, channel)
        self.V = {}                 # named voicings: symbol -> (bass, [voicing]); falls back to theory.voice
        self.notes = []             # free-text composer notes for the report

    # ------------------------------------------------------------ setup
    def channel(self, name, instrument, pan=64, reverb=80, vol=90, chan=None):
        """Add a channel. `instrument` is a key of instruments.GM or a raw program number."""
        bank, prog = GM[instrument] if isinstance(instrument, str) else (0, instrument)
        drums = bank == 128
        if chan is None:
            used = {c['chan'] for c in self.ch.values()}
            if drums:
                chan = 9
            else:
                free = [c for c in range(16) if c != 9 and c not in used]
                if not free:
                    raise ValueError(f'{self.id}: out of MIDI channels at {name}')
                chan = free[0]
        self.ch[name] = dict(chan=chan, bank=0 if drums else bank, prog=prog, pan=pan, rev=reverb, vol=vol, drums=drums)
        self.events[name] = []
        self.cc11[name] = []
        self.ccs[name] = []
        return name

    def tempo(self, bar, bpm):
        self.tempos.append((bar * self.bar_q, bpm))
        self.tempos.sort()

    def section(self, bar, name):
        self.sections.append((bar, name))
        self.sections.sort()

    @property
    def total_beats(self):
        return self.bars * self.bar_q

    def seconds_at(self, beat):
        t, last_b, last_bpm = 0.0, 0.0, self.tempos[0][1]
        for b, bpm in self.tempos[1:]:
            if b >= beat:
                break
            t += (b - last_b) * 60.0 / last_bpm
            last_b, last_bpm = b, bpm
        return t + (beat - last_b) * 60.0 / last_bpm

    @property
    def seconds(self):
        return self.seconds_at(self.total_beats)

    # ------------------------------------------------------------ notes (v04 semantics)
    def note(self, ch, start, dur, pitch, vel, human=True, role=None):
        if pitch == REST:
            return
        j = self.rng.uniform(-self.jitter, self.jitter) if human else 0
        v = max(1, min(127, int(vel + (self.rng.randint(-self.vel_spread, self.vel_spread) if human else 0))))
        self.events[ch].append((max(0, start + j), dur, p(pitch), v, role))

    def line(self, ch, bar, mel, vel, transpose=0, legato=0.96, shape=True, beat=0.0, role=None):
        """A melody from bar `bar` (+ `beat`). Phrase arc: louder toward the middle, long notes leaned into."""
        t = bar * self.bar_q + beat
        total = sum(d for _, d in mel)
        pos = 0
        for n, d in mel:
            if n != REST:
                arc = 1 + (0.10 * (1 - abs(2 * pos / total - 1)) if shape else 0)
                vv = vel * arc + (4 if d >= 1.5 else 0)
                self.note(ch, t + pos, d * legato, p(n) + transpose, vv, role=role)
            pos += d
        return t + total

    def mel(self, ch, bar, mel, vel, **kw):
        """`line` tagged as the lead melody (the audibility check follows it)."""
        return self.line(ch, bar, mel, vel, role='mel', **kw)

    def motif(self, ch, bar, mel, vel, form='stated', lead=True, **kw):
        """Place a Crossroads statement/fragment and log it for the report (form: stated, fragment, augmented, inverted,
        countermelody, bass, resolved, ...)."""
        self.motifs.append((bar + kw.get('beat', 0) / self.bar_q, form, ch))
        return self.line(ch, bar, mel, vel, role='mel' if lead else None, **kw)

    def swell(self, ch, bar, bars, lo, hi, back=None):
        """CC11 ramp lo->hi over `bars` bars ('arch' = up then back down)."""
        s = bar * self.bar_q
        steps = int(bars * 8)
        for i in range(steps + 1):
            f = i / steps
            if back is not None:
                v = lo + (hi - lo) * (f * 2 if f < 0.5 else (2 - f * 2)) if back == 'arch' else lo + (hi - lo) * f
            else:
                v = lo + (hi - lo) * f
            self.cc11[ch].append((s + bars * self.bar_q * f, int(v)))

    def expr(self, ch, bar, value, beat=0.0):
        self.cc11[ch].append((bar * self.bar_q + beat, int(value)))

    def cc(self, ch, bar, control, value, beat=0.0):
        self.ccs[ch].append((bar * self.bar_q + beat, control, int(value)))

    # ------------------------------------------------------------ harmony helpers
    def voicing(self, sym, low='C3', n=4):
        if sym in self.V:
            return self.V[sym]
        return (bass_note(sym), voice(sym, low, n))

    def pad(self, ch, bar, sym, vel, beats=None, octave=0, low='C3', n=4, beat=0.0):
        for t in self.voicing(sym, low, n)[1]:
            self.note(ch, bar * self.bar_q + beat, (beats or self.bar_q) + 0.08, p(t) + 12 * octave, vel)

    def bass(self, bar, sym, vel, pattern='whole', chs=('cb', 'vc'), octave=0):
        """whole / half (root-fifth) as v04, plus pedal (cb only), march (root-fifth crotchets), pulse (8ths), walk, waltz (beat 1)."""
        b = p(self.voicing(sym)[0]) + 12 * octave
        cb, vc = chs
        q = self.bar_q
        t = bar * q
        if pattern == 'whole':
            self.note(cb, t, q + 0.02, b, vel)
            if vc:
                self.note(vc, t, q + 0.02, b + 12, vel - 6)
        elif pattern == 'half':
            fifth = b + 7
            alt = sym.startswith('A7s')
            self.note(cb, t, q / 2, b, vel)
            self.note(cb, t + q / 2, q / 2, fifth if not alt else b, vel - 6)
            if vc:
                self.note(vc, t, q / 2, b + 12, vel - 6)
                self.note(vc, t + q / 2, q / 2, fifth + 12 if not alt else b + 12, vel - 10)
        elif pattern == 'pedal':
            self.note(cb, t, q + 0.02, b, vel)
        elif pattern == 'march':
            for i in range(int(q)):
                self.note(cb, t + i, 0.7, b if i % 2 == 0 else b + 7, vel + (6 if i == 0 else 0))
                if vc:
                    self.note(vc, t + i, 0.6, b + 12 if i % 2 == 0 else b + 19, vel - 8)
        elif pattern == 'pulse':
            for i in range(int(q * 2)):
                self.note(cb, t + i * 0.5, 0.4, b, vel + (8 if i % 2 == 0 else -4))
                if vc and i % 2 == 0:
                    self.note(vc, t + i * 0.5, 0.4, b + 12, vel - 10)
        elif pattern == 'walk':
            tn = tones(sym, low=b, count=4)
            for i in range(int(q)):
                self.note(cb, t + i, 0.9, tn[i % len(tn)], vel + (6 if i == 0 else 0))
        elif pattern == 'waltz':
            self.note(cb, t, 1.0, b, vel + 4)
            if vc:
                self.note(vc, t, 1.0, b + 12, vel - 6)
        else:
            raise ValueError(pattern)

    def harp(self, bar, sym, vel, density=8, ch='harp', octave=0, beats=None, beat=0.0):
        """v04 arpeggio: the voicing plus its octave across the bar (density 16 = up and back down)."""
        ts = sorted(p(n) + 12 * octave for n in self.voicing(sym)[1])
        seq = ts + [t + 12 for t in ts]
        order = seq if density == 8 else seq + seq[::-1]
        span = beats or self.bar_q
        step = span / len(order)
        for i, t in enumerate(order):
            self.note(ch, bar * self.bar_q + beat + i * step, step * 2.5, t, vel - (i % 4 == 0 and -6 or 0))

    def pizz(self, bar, sym, vel, ch='pizz', pattern=None):
        """v04 pizzicato: bass, chord tone, fifth, chord tone on the beats. `pattern` = [(beat, 'b'|'f'|index)] overrides."""
        b = p(self.voicing(sym)[0]) + 12
        ts = sorted(p(n) for n in self.voicing(sym)[1])
        alt = sym.startswith('A7s')
        pat = pattern or [(0, 'b'), (1, 2), (2, 'f'), (3, 3)]
        for beat, w in pat:
            if beat >= self.bar_q:
                continue
            t = b if w == 'b' else ((b + 7 if not alt else ts[1]) if w == 'f' else ts[w % len(ts)])
            self.note(ch, bar * self.bar_q + beat, 0.5, t, vel + (6 if beat == 0 else 0))

    def figure(self, ch, bar, sym, pattern, vel, low='C4', octave=0):
        """Generic accompaniment figure: pattern = [(beat, tone, dur, accent)] where tone indexes the chord tones from `low`
        ('b' = the bass an octave up)."""
        tn = tones(sym, low=p(low) + 12 * octave, count=8)
        b = p(self.voicing(sym)[0]) + 12
        for beat, w, dur, acc in pattern:
            self.note(ch, bar * self.bar_q + beat, dur, b if w == 'b' else tn[w], vel + acc)

    def ostinato(self, ch, bar, bars, cell, vel, transpose=0):
        """Repeat `cell` [(pitch, beats, accent)] for `bars` bars."""
        t = bar * self.bar_q
        end = t + bars * self.bar_q
        cell_len = sum(c[1] for c in cell)
        while t < end - 1e-6:
            pos = t
            for pitch, d, acc in cell:
                if pos >= end - 1e-6:
                    break
                if pitch != REST:
                    self.note(ch, pos, d * 0.9, p(pitch) + transpose, vel + acc)
                pos += d
            t += cell_len

    def brass(self, ch, bar, sym, vel, beats=None, low='F3', n=3, beat=0.0):
        for t in voice(sym, low, n):
            self.note(ch, bar * self.bar_q + beat, beats or self.bar_q, t, vel)

    def run(self, ch, bar, start, end, scale, vel, step=0.25, beat=0.0, crescendo=0):
        notes = scale.run(start, end)
        for i, t in enumerate(notes):
            self.note(ch, bar * self.bar_q + beat + i * step, step * 0.95, t, vel + crescendo * i / max(1, len(notes) - 1))
        return len(notes) * step

    # ------------------------------------------------------------ timpani and percussion
    def timp_hit(self, beat, pitch, vel, ch='timp'):
        self.note(ch, beat, 1.0, p(pitch), vel)

    def timp_roll(self, start, beats, pitch, v0, v1, ch='timp'):
        n = int(beats * 6)
        for i in range(n):
            self.note(ch, start + i / 6, 0.2, p(pitch), v0 + (v1 - v0) * i / n, human=False)

    def hit(self, inst, beat, vel, dur=0.5, ch='perc'):
        """One orchestra-kit hit by name (theory.KIT) or note number; `beat` is absolute."""
        self.note(ch, beat, dur, KIT.get(inst, inst) if isinstance(inst, str) else inst, vel)

    def drum(self, bar, pattern, vel, ch='perc', bars=1):
        """pattern = [(beat, inst, accent)] repeated each bar."""
        for k in range(bars):
            for beat, inst, acc in pattern:
                self.hit(inst, (bar + k) * self.bar_q + beat, vel + acc, ch=ch)

    def snare_roll(self, start, beats, v0, v1, ch='perc', inst='snare', rate=8):
        n = int(beats * rate)
        for i in range(n):
            self.note(ch, start + i / rate, 0.1, KIT[inst], v0 + (v1 - v0) * i / n, human=False)

    # ------------------------------------------------------------ MIDI
    def to_midi(self, path, tail_seconds=0.0):
        """Write the multi-track .mid. `tail_seconds` pushes end_of_track past the loop/end point (render copies only), so the
        synth's release and reverb are rendered instead of cut."""
        mid = mido.MidiFile(ticks_per_beat=TPB)
        meta = mido.MidiTrack()
        msgs = []
        for b, bpm in self.tempos:
            msgs.append((int(b * TPB), 0, mido.MetaMessage('set_tempo', tempo=mido.bpm2tempo(bpm))))
        msgs.append((0, 0, mido.MetaMessage('time_signature', numerator=self.meter[0], denominator=self.meter[1])))
        msgs.append((0, 0, mido.MetaMessage('track_name', name=self.id)))
        for bar, nm in self.sections:
            msgs.append((int(bar * self.bar_q * TPB), 1, mido.MetaMessage('marker', text=nm)))
        msgs.sort(key=lambda m: (m[0], m[1]))
        last = 0
        for t, _, m in msgs:
            meta.append(m.copy(time=t - last))
            last = t
        end = int(self.total_beats * TPB)
        if tail_seconds:
            end += int(tail_seconds * self.tempos[-1][1] / 60.0 * TPB)
        meta.append(mido.MetaMessage('end_of_track', time=end - last))
        mid.tracks.append(meta)
        for k, c in self.ch.items():
            tr = mido.MidiTrack()
            tr.append(mido.MetaMessage('track_name', name=k, time=0))
            chan = c['chan']
            msgs = []
            if c['drums']:
                msgs.append((0, 0, mido.Message('control_change', channel=chan, control=0, value=0)))
            elif c['bank']:
                msgs.append((0, 0, mido.Message('control_change', channel=chan, control=0, value=c['bank'])))
            msgs.append((0, 0, mido.Message('program_change', channel=chan, program=c['prog'])))
            for ctl, v in ((7, c['vol']), (10, c['pan']), (91, c['rev']), (93, 0), (11, 100)):
                msgs.append((0, 1, mido.Message('control_change', channel=chan, control=ctl, value=v)))
            for b, ctl, v in self.ccs[k]:
                msgs.append((int(b * TPB), 1, mido.Message('control_change', channel=chan, control=ctl, value=max(0, min(127, v)))))
            for b, v in self.cc11[k]:
                msgs.append((int(b * TPB), 2, mido.Message('control_change', channel=chan, control=11, value=max(0, min(127, v)))))
            for s, d, n, v, _ in self.events[k]:
                on = int(s * TPB)
                off = int((s + d) * TPB)
                msgs.append((on, 4, mido.Message('note_on', channel=chan, note=n, velocity=v)))
                msgs.append((off, 3, mido.Message('note_off', channel=chan, note=n, velocity=0)))
            msgs.sort(key=lambda m: (m[0], m[1]))
            last = 0
            for t, _, m in msgs:
                tr.append(m.copy(time=t - last))
                last = t
            mid.tracks.append(tr)
        mid.save(path)
        return path

    def note_count(self):
        return sum(len(e) for e in self.events.values())
