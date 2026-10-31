"""MUS-LAB-EXP - The subject's corridors (Path-ology Lab exploration). Loop, 96 bars 4/4, 150 BPM, A minor. Quantised.
Minimal, relentless lab techno: a cold glass/piano pulse and an electronic kit under a sidechain-pumped pad, a rolling detuned synth bass,
the Lab's own needle-sharp riff (_fork_c.LAB_RIFF) on two saw leads a few cents apart. Against the sterile grid a very human cello keeps
playing root-like organic phrases (humanised). A breakdown with the lullaby's first four notes once on the piano, glitched off, a riser,
then the drop with the Crossroads motif as a glitched saw lead and cold string/brass stabs. Exploration weight: drums half-time in the
quiet sections, full only in the two drops. Intro and outro are the same bed so the loop is seamless.
"""
from lib import Score, motif, motif_head, augment, m, p, voice, LULLABY_HEAD
from scores._fork_c import (LAB_RIFF, tr, chord, drums, snare_build, pump, roll_bass, arp, stutter, glitch, riser, human, CRASH)

A_PROG = ['Am', 'Am', 'F', 'E']
B_PROG = ['Dm', 'Am', 'Bb', 'E']


def build():
    s = Score('MUS-LAB-EXP', bpm=150, bars=96, key='A minor', seed=901, human=(0.0, 2))
    s.channel('kit', 'electro_kit', pan=64, reverb=40, vol=98)
    s.channel('sbass', 'synth_bass2', pan=64, reverb=20, vol=92)
    s.channel('sbass2', 'bass_lead', pan=64, reverb=20, vol=62)
    s.channel('pad', 'poly_pad', pan=64, reverb=90, vol=78)
    s.channel('glass', 'crystal', pan=40, reverb=95, vol=64)
    s.channel('piano', 'piano', pan=56, reverb=90, vol=78)
    s.channel('arp', 'square_lead', pan=80, reverb=70, vol=58)
    s.channel('lead', 'saw_lead', pan=50, reverb=70, vol=82)
    s.channel('lead2', 'saw_lead', pan=78, reverb=70, vol=66)
    s.channel('vc', 'cello', pan=82, reverb=90, vol=92)
    s.channel('stab', 'strings', pan=40, reverb=85, vol=88)
    s.channel('brass', 'brass', pan=74, reverb=85, vol=80)
    s.channel('rise', 'sweep_pad', pan=64, reverb=100, vol=70)
    s.detune('sbass2', 8)
    s.detune('lead2', -9)
    for bar, nm in ((0, 'bed'), (8, 'A grid + cello'), (24, 'B breakdown'), (40, 'drop 1'), (56, 'C glitch'), (72, 'drop 2'), (88, 'bed')):
        s.section(bar, nm)
    s.notes.append('Lab techno per the Pass 3 direction; the row\'s cold glass pulse, human cello and lullaby fragment are kept inside it.')

    def glass_pulse(bar, sym, vel, step=.5):
        tones = [x + 12 for x in s.voicing(sym, 'A4', 3)[1]]
        for i in range(int(4 / step)):
            s.note('glass', bar * 4 + i * step, step * .6, tones[i % 3], vel + (8 if i % 4 == 0 else 0), human=False)

    def bed(bar, n=8, prog=A_PROG):
        for i in range(n):
            sym = prog[i % 4]
            s.pad('pad', bar + i, sym, 60, low='A3')
            glass_pulse(bar + i, sym, 56)
            roll_bass(s, ('sbass', 'sbass2'), bar + i, sym, 82, pattern='roll' if i % 2 else 'off')
            drums(s, bar + i, 1, 88, clap=False, ohat=True, half=False)
            arp(s, 'arp', bar + i, 1, sym, 44, low='A4', step=.5)
        pump(s, 'pad', bar, n, lo=40, hi=104)
        s.motif('piano', bar + 2, motif_head('A4', 'minor', rhythm=(1, .5, 2.5)), 70, form='head (piano, cold, cut short)')
        s.mel('piano', bar, m('A4:1 r:1 E5:1 r:1 | C5:2 B4:2'), 74)
        s.mel('piano', bar + 4, m('E5:1 r:1 C5:1 r:1 | B4:3 r:1 | A4:1 r:1 E4:1 r:1 | G#4:2 B4:1 E5:1'), 74)

    bed(0)

    # A 8-23: grid + cello. Bass rolling, hats on, the riff in the leads from bar 16, the human cello throughout.
    for i in range(16):
        bar, sym = 8 + i, A_PROG[i % 4]
        s.pad('pad', bar, sym, 62, low='A3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 84)
        drums(s, bar, 1, 90, clap=i >= 8, ohat=i >= 4, half=i < 4)
        arp(s, 'arp', bar, 1, sym, 50, low='A4')
    pump(s, 'pad', 8, 16)
    with human(s):
        s.mel('vc', 8, m('A3:3 C4:1 | E4:2 D4:1 C4:1 | A3:4 | B3:2 G#3:2 | A3:2 E4:2 | F4:3 E4:1 | D4:2 C4:1 A3:1 | B3:4'), 82, legato=1.0)
        s.line('vc', 16, m('E4:4 | C4:4 | F4:2 E4:1 D4:1 | E4:4 | E4:4 | C4:4 | D4:2 C4:1 B3:1 | G#3:4'), 70, legato=1.0)
    s.mel('lead', 16, LAB_RIFF * 4, 88, legato=.8)
    s.line('lead2', 16, LAB_RIFF * 4, 70, legato=.8)
    s.cc11['kit'].append((16 * 4, 110))

    # B 24-39: breakdown. Kick out, pad + glass + cello, the lullaby's first four notes once on the piano (glitched off), riser 36-39.
    for i in range(16):
        bar, sym = 24 + i, B_PROG[i % 4]
        s.pad('pad', bar, sym, 56, low='A3')
        glass_pulse(bar, sym, 50, step=.25 if i >= 12 else .5)
        if i < 12:
            s.note('sbass', bar * 4, 3.9, bass_root(s, sym), 70, human=False)
        else:
            roll_bass(s, ('sbass', 'sbass2'), bar, sym, 72, pattern='off')
    s.swell('pad', 24, 4, 70, 100)
    with human(s, (0.03, 8)):
        s.mel('vc', 24, m('D4:3 F4:1 | E4:4 | D4:2 C4:2 | B3:4'), 86, legato=1.0)
        s.mel('vc', 32, m('F4:3 E4:1 | D4:2 C4:2 | D4:2 Bb3:2 | G#3:4'), 84, legato=1.0)
    s.mel('piano', 28, [(p(n) - 5, d * 1.5) for n, d in LULLABY_HEAD[:4]], 72)       # A E C B: the lullaby's first four notes, once
    stutter(s, 'piano', 28 * 4 + 6, 'B4', 60, beats=1.5)
    s.notes.append('Lullaby: first four notes once (piano, bar 28, transposed to A: A E C B), glitched off by a stutter.')
    s.motif('arp', 33, glitch(motif('A4', 'minor')) + [('r', 1)], 62, form='glitched (square lead, breakdown)')
    riser(s, 'rise', 36, 4, 'A3', vel=54)
    snare_build(s, 36, 4, 40, 100)

    # DROP 1 40-55: full kit, rolling bass, pumped pad, the Crossroads motif glitched in the saw leads, string/brass stabs.
    def drop(bar, motif_bar_set, vel=100):
        for i in range(16):
            b, sym = bar + i, A_PROG[i % 4]
            s.pad('pad', b, sym, 74, low='A3')
            roll_bass(s, ('sbass', 'sbass2'), b, sym, 92)
            drums(s, b, 1, vel)
            arp(s, 'arp', b, 1, sym, 56, low='A4', step=.25)
            if i % 2 == 0:
                chord(s, 'stab', b * 4, .3, voice(sym, 'A3', 4), 76)
                chord(s, 'brass', b * 4 + 2.5, .3, voice(sym, 'E3', 3), 74)
        pump(s, 'pad', bar, 16, lo=30, hi=112)
        s.note('kit', bar * 4, 2, CRASH, 104, human=False)
        s.note('kit', (bar + 8) * 4, 2, CRASH, 96, human=False)

    drop(40, None)
    for k, form in ((40, 'glitched (saw leads, drop 1)'), (48, 'glitched an octave up (drop 1)')):
        o = 12 if k == 48 else 0
        mel = tr(glitch(motif('A4', 'minor')), o) + [('r', 1)]
        s.motif('lead', k, mel, 92, form=form, legato=.85)
        s.line('lead2', k, mel, 74, legato=.85)
        s.mel('lead', k + 2, tr(LAB_RIFF * 3, o), 86, legato=.8)
        s.line('lead2', k + 2, tr(LAB_RIFF * 3, o), 70, legato=.8)
    with human(s):
        s.line('vc', 44, augment(motif_head('A3', 'minor'), 2) + [('r', 4)], 84)

    # C 56-71: glitch section. Kick half time, stutters on the riff, the motif inverted on the cello, an orchestral turn on F/E.
    for i in range(16):
        bar, sym = 56 + i, B_PROG[i % 4]
        s.pad('pad', bar, sym, 64, low='A3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 84, pattern='gallop')
        drums(s, bar, 1, 90, half=True, clap=True, ohat=False)
        if i % 4 == 3:
            for k in range(4):
                stutter(s, 'arp', bar * 4 + k, s.voicing(sym, 'A4', 3)[1][k % 3], 58, beats=.5)
        else:
            arp(s, 'arp', bar, 1, sym, 52, low='A4', step=.5)
    pump(s, 'pad', 56, 16, lo=40, hi=108)
    with human(s, (0.03, 8)):
        s.motif('vc', 56, motif('D4', 'minor', inverted=True) + [('r', 1)], 88, form='inverted (cello, human)')
        s.mel('vc', 60, m('A3:2 Bb3:2 | A3:2 G#3:2 | A3:4 | E4:4'), 82, legato=1.0)
    for k in (64, 66, 68):
        s.mel('lead', k, glitch(LAB_RIFF[:10], cuts=(0, 4)), 84, legato=.8)
        s.line('lead2', k, glitch(LAB_RIFF[:10], cuts=(0, 4)), 66, legato=.8)
    s.mel('lead', 70, m('Bb4:2 A4:2 | G#4:4'), 86)
    snare_build(s, 70, 2, 50, 104)

    # DROP 2 72-87: the riff and the motif together, an octave-doubled stab line.
    drop(72, None, vel=104)
    s.mel('lead', 72, LAB_RIFF * 2, 92, legato=.8)
    s.line('lead2', 72, LAB_RIFF * 2, 74, legato=.8)
    s.motif('lead', 76, glitch(motif('A5', 'minor'), cuts=(0, 3, 5)) + [('r', 1)], 94, form='glitched high (drop 2)')
    s.line('lead2', 76, motif('A4', 'minor'), 70)
    s.mel('lead', 80, LAB_RIFF * 3, 90, legato=.8)
    s.line('lead2', 80, LAB_RIFF * 3, 72, legato=.8)
    with human(s):
        s.line('vc', 80, m('A3:4 | C4:4 | F4:4 | E4:4 | A3:4 | C4:4 | D4:4 | E4:4'), 80, legato=1.0)
    s.motif('brass', 86, motif_head('A3', 'minor', rhythm=(2, 1, 5)), 86, form='head (brass, end of drop 2)', lead=False)

    bed(88)
    s.fade_vel(94, 96, 0.8, ['pad', 'sbass', 'sbass2', 'glass', 'arp'])     # seam: the bed ends on F/E (louder bass) and starts on Am
    s.fade_vel(0, 2, 1.0, ['pad', 'sbass', 'sbass2', 'glass', 'arp'], start_factor=1.2)
    s.tag_melody('rise', 36, 40)
    return s


def bass_root(s, sym):
    from lib import bass_note
    return bass_note(sym)
