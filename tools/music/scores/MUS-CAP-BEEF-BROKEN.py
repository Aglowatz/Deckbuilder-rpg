"""MUS-CAP-BEEF-BROKEN - Transit Yards, broken service (Capital district). 44 bars 4/4, 88 BPM, Bb major (120 s loop).
The Gainlands theme (MUS-BEEF-EXP) played thin, detuned and interrupted: one horn starts each phrase and stops mid-line, a second horn
shadows it 15 cents flat (Music Pass 3: was 25), a flute catches two notes of the echo; the tuba's march pulse is exhausted (beat one only, a bar missing here and
there), a snare tap drags. Under it a faint bowed-glass rift pad, itself a little off pitch. The Crossroads motif's head on a muted
trumpet, never finished. Human warmth barely audible.
"""
from lib import Score, m, motif_head, voice, p, split_beats, REST

THEME = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1 | C5:1 D5:.5 Eb5:.5 F5:1 G5:1 | F5:3 r:1 '
          '| G5:1.5 F5:.5 Eb5:1 C5:1 | D5:1.5 C5:.5 Bb4:1 G4:1 | A4:1 C5:1 F5:1 A4:1 | Bb4:2 F4:1 r:1 '
          '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 G5:1 A5:1 | Bb5:2 G5:1 Eb5:1 | F5:3 r:1 '
          '| Ab5:1.5 G5:.5 F5:1 Eb5:1 | G5:1.5 F5:.5 Eb5:1 D5:1 | C5:1 Eb5:1 D5:1 C5:1 | Bb4:3 r:1')
PHRASE = [split_beats(THEME, 16 * k, 16 * k + 16) for k in range(4)]
PH_H = [['Bb', 'Bb', 'Cm7', 'F'], ['Eb', 'Gm', 'F', 'Bb'], ['Bb', 'F', 'Eb', 'F'], ['Ab', 'Eb', 'F7', 'Bb']]


def cut(mel, keep):
    """The first `keep` beats of a phrase, then silence: the line gives out."""
    out, pos = [], 0.0
    for n, d in mel:
        if pos >= keep:
            break
        out.append((n, min(d, keep - pos)))
        pos += d
    return out


def build():
    s = Score('MUS-CAP-BEEF-BROKEN', bpm=88, bars=44, key='Bb major', seed=816)
    s.seat('hn', 'tpt', 'fl', 'tuba', 'cb', 'pad', 'perc', tpt={'inst': 'muted_tpt', 'vol': 70}, pad={'vol': 70})
    s.channel('hn2', 'horn', pan=88, reverb=100, vol=66)
    s.channel('glass', 'bowed_glass', pan=50, reverb=110, vol=58)
    s.detune('hn2', -15)          # the shadow horn, flat for the whole cue
    s.detune('glass', -12)
    for bar, nm in ((0, 'A thin'), (12, 'B fragments'), (24, 'C stalling'), (36, "A' thin"), (40, 'thin (loop)')):
        s.section(bar, nm)
    s.notes.append('Broken = the Gainlands theme cut off mid-phrase, a shadow horn 15 cents flat (Music Pass 3: was 25) (Score.detune), exhausted tuba pulse.')

    missing = {6, 17, 27, 30, 33}

    def pulse(bar, sym, vel):
        if bar % 44 in missing:
            return
        b = p(s.voicing(sym)[0])
        s.note('tuba', bar * 4, 1.2, b + 12 if b < p('Bb1') else b, vel)
        s.note('cb', bar * 4, 3.0, b, vel - 14)
        if bar % 3 == 1:
            s.hit('snare', bar * 4 + 3.08, vel - 24)

    def bed(bar, sym, vel):
        s.pad('glass', bar, sym, vel, low='D4', n=3)
        s.pad('pad', bar, sym, vel - 14, low='F3', n=3)

    def phrase(bar, k, keep, vel, lead='hn', beat=0.0):
        frag = cut(PHRASE[k], keep)
        s.mel(lead, bar, frag, vel, beat=beat)
        if lead == 'hn':
            s.line('hn2', bar, frag, vel - 18, beat=beat)
        tail = [x for x in frag if x[0] != REST][-2:]
        s.mel('fl', bar + 2, [(n, 1.0) for n, _ in tail] + [('r', 2)], 50, transpose=12)

    def thin(bar, k, keep, vel, beat=0.0):
        for i, sym in enumerate(PH_H[k]):
            pulse(bar + i, sym, 60)
            bed(bar + i, sym, 50)
        phrase(bar, k, keep, vel, beat=beat)

    # A 0-11: the theme's first three phrases, each giving out sooner
    thin(0, 0, 9, 66, beat=1.0)          # the horn comes in late, softly (loop seam)
    thin(4, 1, 7, 70)
    thin(8, 2, 6, 66)

    # B 12-23: fragments pass between muted trumpet and horn; the motif head on the muted trumpet, unfinished
    for i in range(12):
        sym = PH_H[3 if i < 4 else (0 if i < 8 else 1)][i % 4]
        pulse(12 + i, sym, 56)
        bed(12 + i, sym, 54)
    phrase(12, 3, 6, 66, lead='tpt')
    s.motif('tpt', 16, motif_head('Bb4', 'major', rhythm=(1, .5, 2.5)) + m('r:4'), 64, form='head (muted trumpet, unfinished)')
    phrase(17, 0, 5, 62)
    phrase(20, 1, 6, 64, lead='tpt')

    # C 24-35: stalling - the pulse drags and drops out, the glass rises, the horn tries the opening twice
    for i in range(12):
        sym = ['Gm', 'Eb', 'Cm7', 'F'][i % 4]
        pulse(24 + i, sym, 52)
        bed(24 + i, sym, 56 + (i % 4) * 2)
    phrase(24, 0, 4, 62)
    phrase(28, 0, 3, 58)
    s.motif('hn', 32, motif_head('F4', 'major', rhythm=(2, 1, 3)) + m('r:2'), 60, form='head (horn, slowed, unfinished)')
    s.line('hn2', 32, motif_head('F4', 'major', rhythm=(2, 1, 3)), 44)
    s.mel('fl', 34, m('C6:2 Bb5:2 | A5:4'), 46)

    # A' 36-43: thin again; bars 40-43 have bar 0's voices so the loop closes
    thin(36, 1, 8, 70)
    thin(40, 3, 6, 72)
    s.line('hn', 43, m('F4:4'), 62)          # a held note left hanging into the loop
    s.line('hn2', 43, m('F4:4'), 46)
    s.swell('glass', 43, 1, 96, 110)
    return s
