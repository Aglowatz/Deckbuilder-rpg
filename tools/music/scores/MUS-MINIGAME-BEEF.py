"""MUS-MINIGAME-BEEF - Chet's revolutionary routine (aerobics bravado). 40 bars 4/4, 132 BPM, A major. TECHNO HARD ROCK
(Gainlands rock Nov 3): an 80s synth-rock workout. Four-on-the-floor, gated 8th-note power chords, saw-synth arps, synth brass stabs, a
pumped poly pad, a voice-like synth lead counting the reps in ("1-2-3-4" on A C# E A), the Gainlands answer in major (A major) on the saw
and lead guitar, the Crossroads motif (A E D C# B E, open) on lead guitar. The count-in opens and closes the loop on the same bed.
"""
from lib import Song, p, motif
from lib import rock as R
from scores._rock_c import brass, pad, gtr_ramp

PROG = [('A1', 'A'), ('E2', 'Emaj'), ('F#1', 'F#m'), ('D2', 'D')]
THEME = R.transpose(R.ANSWER_MAJOR, 5)         # the Gainlands answer, E major -> A major
MOTIF = motif('A4', 'major') + [('r', 1)]
GATED = [(i * .5, .22, 1) for i in range(8)]
COUNT = [('A4', 1), ('C#5', 1), ('E5', 1), ('A5', 1)]


def build():
    s = Song('MUS-MINIGAME-BEEF', bpm=132, bars=40, key='A major', seed=4404)
    s.jitter = 0.005
    R.band(s, brass=62, pad=90)
    s.add('vox', 10, 85, pan=64, rev=70, vol=96)        # voice-like synth lead: the count-ins
    for bar, nm in ((0, 'count-in'), (2, 'A workout'), (10, 'B lead + count'), (18, 'cool-down'), (22, 'build'),
                    (26, 'drop'), (38, 'count-in')):
        s.section(bar, nm)
    s.notes.append("Chet's aerobics: 80s synth rock - gated power chords, saw arps, synth brass, a synth voice counting the reps.")

    def ch(i, per=1):
        return PROG[(i // per) % 4]

    def count_in(bar0, lo, hi):
        for i in range(2):
            r, c = PROG[(2 + i) % 4]
            R.four_floor(s, bar0 + i, 110)
            R.chug(s, bar0 + i, r, 76, pattern=GATED)
            R.subdrop(s, bar0 + i, r, 92)
            pad(s, bar0 + i, c, 70)
            s.mel('vox', bar0 + i, COUNT, 96, arc=False, legato=.5)
        gtr_ramp(s, bar0, 2, lo, hi)

    count_in(0, 84, 100)

    # 2-9 A WORKOUT: gated chords, saw arp, the theme on the saw, synth brass on the hits
    R.crash(s, 2, 112)
    for i in range(8):
        bar = 2 + i
        r, c = ch(i)
        R.four_floor(s, bar, 114)
        R.chug(s, bar, r, 84, pattern=GATED)
        R.bassline(s, bar, r, 92)
        R.arp(s, bar, r, 70, up=36)
        brass(s, bar, c, hits=((0, .3, 78), (1.5, .3, 70), (3, .3, 74)))
    s.mel('saw', 2, THEME, 112, tr=12)
    s.mel('saw', 4, THEME, 116, tr=12)
    s.mel('saw', 6, THEME, 116, tr=12)
    s.mel('saw', 8, THEME[:6] + [(p('A5'), 1), (p('C#6'), 1.5)], 118, tr=0)

    # 10-17 B: lead guitar motif, the voice counts every other bar, sustained gated pad
    R.crash(s, 10, 112)
    for i in range(8):
        bar = 10 + i
        r, c = ch(i)
        R.four_floor(s, bar, 114)
        R.chug(s, bar, r, 80, pattern='straight')
        R.subdrop(s, bar, r, 96)
        pad(s, bar, c, 74)
        if i % 2 == 1:
            s.line('vox', bar, COUNT, 80, arc=False, legato=.4)
    s.pump('pad', 10, 8, lo=24, hi=100)
    s.motif('lead', 10, MOTIF, 106, form='stated (lead guitar)', tr=0)
    s.mel('lead', 12, THEME, 104)
    s.motif('lead', 14, MOTIF, 108, form='stated again', tr=12)
    s.mel('lead', 16, THEME, 108, tr=12)

    # 18-21 COOL-DOWN: half-time, claps, pad and the theme slow on the vox
    for i in range(4):
        bar = 18 + i
        r, c = ch(i)
        R.rock_beat(s, bar, 92, half=True)
        s.note('kit', s.B(bar, 3), .2, 39, 80, human=False)
        pad(s, bar, c, 76)
        R.bassline(s, bar, r, 80, style='hold')
        R.sustain(s, bar, r, 64)
        R.arp(s, bar, r, 74, up=36)
    s.mel('vox', 18, [(n, d * 2) for n, d in THEME[:5]], 84)

    # 22-25 BUILD: gated chords rising, snare roll, riser
    for i in range(4):
        bar = 22 + i
        r, c = PROG[(i + 2) % 4] if i < 2 else [('D2', 'D'), ('E2', 'Emaj')][i - 2]
        R.chug(s, bar, r, 56 + i * 10, pattern=GATED)
        pad(s, bar, c, 70)
        R.kick_pulse(s, bar, 90 + i * 6)
    R.snare_roll(s, 22, 4, 34, 116)
    R.riser(s, 22, 4)
    s.mel('vox', 25, COUNT, 100, arc=False, legato=.5)

    # 26-37 DROP: everything - theme on lead + saw, synth brass, sub, crashes
    R.crash(s, 26, 122)
    for i in range(12):
        bar = 26 + i
        r, c = ch(i)
        R.four_floor(s, bar, 120)
        R.chug(s, bar, r, 92, pattern=GATED if i % 4 < 2 else 'straight')
        R.subdrop(s, bar, r, 104)
        brass(s, bar, c, hits=((0, .4, 90), (1.5, .3, 80), (2.5, .3, 82), (3, .5, 86)))
        pad(s, bar, c, 80)
        if i % 4 == 0 and i:
            R.crash(s, bar, 110)
    s.pump('pad', 26, 12, lo=20, hi=104)
    s.mel('lead', 26, THEME, 112, tr=12)
    s.motif('lead', 28, MOTIF, 112, form='stated 8va (drop)', tr=12)
    s.mel('lead', 30, THEME, 114, tr=12)
    s.mel('saw', 30, THEME, 100, tr=12)
    s.motif('saw', 32, MOTIF, 112, form='saw 8va', tr=12)
    s.mel('lead', 34, THEME[:6] + [(p('A5'), 1), (p('C#6'), 1.5)], 116, tr=0)
    s.mel('lead', 36, [(p('B5'), 4), (p('E5'), 4)], 110)

    # 38-39 the count-in again
    count_in(38, 100, 84)
    s.tag_melody('gtrL', 22, 25)
    return s
