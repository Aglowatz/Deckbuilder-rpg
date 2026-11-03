"""MUS-BEEF-BOSS - Chancellor Clench, Iron Regent. 96 bars 4/4, 136 BPM, D minor (drop-D). TECHNO HARD ROCK (Gainlands rock Nov 3).
The heaviest Beefcake cue. Clench's own villain riff: the Crossroads motif INVERTED (D G A Bb C G, the question turned upside down) ground
out as low drop-D 16th chugs, power chords down to G1, under a double kick. Quota's stopwatch from the orchestral version is kept: metronome
clicks on the 8ths and a ding (metronome bell + triangle) every two bars. The hero's motif (D A G F E A, open) fights back on lead guitar
over his riff, the phrases constrict (2 bars, 1, a half) into the drops, and the final drop is the biggest in the set.
"""
from lib import Song, p, motif
from lib import rock as R
from lib.rock import MOTIF, ANSWER, ANSWER_TAG, LICK, BRASS_HITS

PROG = ['D2', 'Bb1', 'C2', 'A1']                       # i - VI - VII - V in D minor, drop-D low
HIT = {'D2': 'Dm', 'Bb1': 'Bb', 'C2': 'C', 'A1': 'A'}
HERO = R.transpose(MOTIF, -2)                          # D4 A4 G4 F4 E4 A4: open, never resolved here
HERO_ANSWER = R.transpose(ANSWER, -2)
HERO_TAG = R.transpose(ANSWER_TAG, -2)
VILLAIN = motif('D2', 'minor', inverted=True)          # D2 G1 A1 Bb1 C2 G1 (q e e dq e dh)


def build():
    s = Song('MUS-BEEF-BOSS', bpm=136, bars=96, key='D minor', seed=513)
    s.jitter = 0.005
    R.band(s, brass=61)
    for bar, nm in ((0, 'intro stopwatch'), (4, 'Clench riff'), (20, 'the hero fights back'), (28, 'constriction'),
                    (32, 'drop 1'), (48, 'breakdown'), (56, 'build'), (60, 'final drop'), (80, 'Clench riff returns'), (92, 'outro stopwatch')):
        s.section(bar, nm)
    s.notes.append("Clench's villain riff is the inverted Crossroads motif as drop-D chugs; the hero's motif answers on lead guitar, open.")

    def stopwatch(bar, vel):
        for k in range(8):
            s.note('kit', s.B(bar, k * .5), .1, 33, vel - (4 if k % 2 == 0 else 14), human=False)
        if bar % 2 == 0:
            s.note('kit', s.B(bar), .4, 34, vel + 6, human=False)
            s.note('kit', s.B(bar), 1.0, 81, vel - 8, human=False)

    def villain(bar, vel, beats=8):
        """The riff: each note of the inverted motif as 16th chugs (power chord on the attack), then a beat of D chugs; `beats` cuts it."""
        t = 0.0
        cells = VILLAIN + [(p('D2'), 1)]
        for n, d in cells:
            r = p(n)
            for k in range(int(round(d * 4))):
                if t + k * .25 >= beats:
                    break
                acc = k == 0
                notes = [r, r + 7, r + 12] if acc else [r, r + 7]
                for ch, off in (('gtrL', 0.0), ('gtrR', 0.012)):
                    s.chord(ch, s.B(bar, t + k * .25) + off, .22 if not acc else .24, notes, vel + (12 if acc else -6))
            if t < beats:
                s.note('bass', s.B(bar, t), min(d, beats - t) * .95, r, vel + 4)
            t += d
            if t >= beats:
                break

    def bed(bar, c):
        """Intro / outro (identical): the low D power chord held, sub, pad, kick pulse, the stopwatch."""
        R.sustain(s, bar, c, 62)
        R.kick_pulse(s, bar, 110)
        R.subdrop(s, bar, c, 92)
        R.pad_chord(s, bar, HIT[c], 70)
        stopwatch(bar, 90)

    for i, c in enumerate(['D2', 'D2', 'Bb1', 'A1']):
        bed(i, c)
    R.snare_roll(s, 3, 1, 50, 108)
    R.riser(s, 2, 2)

    # 4-19 CLENCH RIFF: the villain riff x8 under double kick, stopwatch, low brass stating it
    R.crash(s, 4, 116)
    for i in range(8):
        villain(4 + i * 2, 90)
        for k in range(2):
            R.double_kick(s, 4 + i * 2 + k, 100)
            stopwatch(4 + i * 2 + k, 70)
    s.motifs.append((4, 'inverted (villain riff, drop-D guitars)', 'gtrL'))
    s.motif('brass', 8, R.transpose(VILLAIN, 12), 96, form='inverted (Clench, brass)')
    s.motif('brass', 12, R.transpose(VILLAIN, 24), 100, form='inverted 8va (Clench, brass)')
    s.motif('saw', 16, R.transpose(VILLAIN, 36), 80, form='inverted (saw, mocking)')

    # 20-27 THE HERO FIGHTS BACK: the riff goes on, the hero's motif answers on lead guitar
    for i in range(4):
        villain(20 + i * 2, 86)
        for k in range(2):
            R.double_kick(s, 20 + i * 2 + k, 98)
            stopwatch(20 + i * 2 + k, 64)
    s.motif('lead', 20, HERO, 108, form="stated (the hero's motif, lead guitar, open)", tr=12)
    s.mel('lead', 22, HERO_ANSWER, 104)
    s.motif('lead', 24, HERO, 110, form='stated again (lead guitar)', tr=12)
    s.mel('lead', 26, HERO_TAG, 112)

    # 28-31 CONSTRICTION: the riff's phrase shrinks (2 bars, 1, a half, a half) - quieter, a roll and a riser
    villain(28, 74, beats=8)
    villain(30, 70, beats=4)
    villain(31, 72, beats=2)
    villain(31.5, 76, beats=2)
    for k in range(4):
        stopwatch(28 + k, 60 + k * 6)
        R.kick_pulse(s, 28 + k, 76 + k * 8)
    R.snare_roll(s, 28, 4, 34, 118)
    for k in range(32):
        s.note('timp', s.B(30) + k * .25, .2, p('A1'), 40 + k * 2, human=False)
    R.riser(s, 28, 4)

    # 32-47 DROP 1: four-floor + double kick, sub, straight chugs on D Bb C A, saw stabs, the hero vs Clench
    R.crash(s, 32, 122)
    for i in range(16):
        bar = 32 + i
        c = PROG[(i // 2) % 4]
        R.double_kick(s, bar, 116)
        s.note('kit', s.B(bar, 2), .2, 39, 100, human=False)
        R.subdrop(s, bar, c, 104)
        R.chug(s, bar, c, 92, pattern='straight')
        for b in (0, 1.5, 3):
            s.chord('saw', s.B(bar, b), .3, [p(c) + 36, p(c) + 43], 78)
        R.pad_chord(s, bar, HIT[c], 76)
        if i % 4 == 0 and i:
            R.crash(s, bar, 108)
    s.pump('pad', 32, 16, lo=20, hi=100)
    s.motif('lead', 32, HERO, 112, form='stated (lead guitar, drop 1)', tr=12)
    s.mel('lead', 34, HERO_ANSWER, 108)
    s.motif('brass', 36, R.transpose(VILLAIN, 24), 102, form='inverted (Clench pushes back, brass)')
    s.motif('lead', 40, HERO, 114, form='stated 8va', tr=24)
    s.mel('lead', 42, HERO_TAG, 112, tr=12)
    s.motif('brass', 44, R.transpose(VILLAIN, 24), 104, form='inverted again (brass)')
    s.mel('lead', 46, [('D5', 2), ('C5', 1), ('A4', 1), ('C#5', 4)], 108)

    # 48-55 BREAKDOWN: half time, the stopwatch alone with the riff held, the lick (in D) on lead, brass chorale on Clench
    for i in range(8):
        bar = 48 + i
        c = ['D2', 'D2', 'Bb1', 'Bb1', 'C2', 'C2', 'A1', 'A1'][i]
        R.rock_beat(s, bar, 92, half=True)
        stopwatch(bar, 84)
        if i % 2 == 0:
            R.sustain(s, bar, c, 62, beats=8)
            s.chord('brass', s.B(bar), 7.9, BRASS_HITS[HIT[c]], 66)
        R.bassline(s, bar, c, 82, style='hold')
    s.mel('lead', 48, R.transpose(LICK, -2), 98)

    # 56-59 BUILD: the riff constricting again, the biggest roll, riser, timpani
    villain(56, 70, beats=8)
    villain(58, 74, beats=4)
    villain(59, 80, beats=2)
    villain(59.5, 84, beats=2)
    for k in range(4):
        stopwatch(56 + k, 66 + k * 6)
        R.pad_chord(s, 56 + k, ['Dm', 'Dm', 'Bb', 'A'][k], 64)
    R.snare_roll(s, 56, 4, 36, 124)
    for k in range(32):
        s.note('timp', s.B(58) + k * .25, .2, p('D2'), 44 + k * 2, human=False)
    R.riser(s, 56, 4)

    # 60-79 FINAL DROP: everything, crashes every 2 bars, the hero's motif 8va over Clench's riff in the guitars and his theme in the brass
    R.crash(s, 60, 127)
    for i in range(20):
        bar = 60 + i
        c = PROG[(i // 2) % 4]
        R.double_kick(s, bar, 122)
        s.note('kit', s.B(bar, 2), .2, 39, 106, human=False)
        R.subdrop(s, bar, c, 110)
        if i < 8 or i >= 16:
            R.chug(s, bar, c, 98, pattern='gallop' if i % 2 == 0 else 'machine')
        s.chord('brass', s.B(bar), .5, BRASS_HITS[HIT[c]], 102)
        s.chord('brass', s.B(bar, 1.5), .4, BRASS_HITS[HIT[c]], 90)
        s.chord('brass', s.B(bar, 3), .5, BRASS_HITS[HIT[c]], 96)
        R.pad_chord(s, bar, HIT[c], 80)
        if i % 2 == 0 and i:
            R.crash(s, bar, 110)
    for j in range(4):
        villain(68 + j * 2, 100)                            # 68-75: the guitars on his riff, the lead against it
    s.motifs.append((68, 'inverted (villain riff under the hero, final drop)', 'gtrL'))
    s.pump('pad', 60, 20, lo=20, hi=106)
    s.motif('lead', 60, HERO, 116, form='stated 8va (lead guitar, final drop)', tr=12)
    s.mel('lead', 62, HERO_ANSWER, 114, tr=12)
    s.motif('lead', 64, HERO, 118, form='stated 8va again', tr=12)
    s.mel('lead', 66, HERO_TAG, 118, tr=12)
    s.motif('lead', 68, HERO, 118, form='stated over his riff (the fight)', tr=12)
    s.motif('saw', 68, R.transpose(VILLAIN, 36), 86, form='inverted (saw, his theme against the hero)')
    s.mel('lead', 70, HERO_ANSWER, 116, tr=12)
    s.motif('lead', 72, HERO, 120, form='stated 8va (lead guitar)', tr=12)
    s.mel('lead', 74, HERO_TAG, 120, tr=12)
    s.motif('saw', 76, HERO, 88, form='stated 2 octaves up (saw)', tr=24)
    s.mel('lead', 76, HERO_ANSWER, 114, tr=12)
    s.mel('lead', 78, [('A5', 2), ('G5', 1), ('E5', 1), ('C#5', 4)], 112)

    # 80-91 CLENCH RIFF RETURNS, thinning
    for i in range(6):
        villain(80 + i * 2, 90 - i * 3)
        for k in range(2):
            R.double_kick(s, 80 + i * 2 + k, 102 - i * 3)
            stopwatch(80 + i * 2 + k, 72)
    s.motif('brass', 84, R.transpose(VILLAIN, 12), 92, form='inverted (Clench, brass, last word)')

    # 92-95 OUTRO STOPWATCH: the intro bed, back to bar 0
    for i, c in enumerate(['D2', 'Bb1', 'C2', 'A1']):
        bed(92 + i, c)

    for a, b in ((0, 20), (28, 32), (56, 60), (80, 96)):
        s.tag_melody('gtrL', a, b)
    return s
