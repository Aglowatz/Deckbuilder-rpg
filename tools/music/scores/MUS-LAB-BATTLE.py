"""MUS-LAB-BATTLE - Experiments still running (Path-ology Lab combat). Loop, 96 bars 4/4, 160 BPM, F# minor. Quantised.
Relentless lab techno: four-on-the-floor on the electronic kit, a rolling detuned saw bass, a pumped pad, a 16th string ostinato
interlocking with clinical synth ticks, the Lab riff on two saw leads. A B section of abrupt answers: the four Paths' theme heads
snapped out by orchestral stabs (D.N.A. waltz head, Buffet hook, Dump jig, a Gainlands brass call), each answered by the Crossroads
motif as a glitched synth lead. A distinct quiet passage (no kick: cello, piano ticks, the motif augmented), a riser, the drop with
cold string/brass hits and timpani, a glitch section, and an intro/outro bed that keeps the loop from falling into a hole.
"""
from lib import Score, motif, motif_head, augment, m, p, voice, bass_note
from lib.zones import DNA_THEME, BUFFET_HOOK, DUMP_JIG_HEAD
from scores._fork_c import (LAB_RIFF, tr, chord, drums, snare_build, pump, roll_bass, arp, stutter, glitch, riser, human, CRASH)

S = -3                                  # A minor riff -> F# minor
A_PROG = ['F#m', 'D', 'E', 'C#']
B_PROG = ['Bm', 'F#m', 'G', 'C#']


def build():
    s = Score('MUS-LAB-BATTLE', bpm=160, bars=96, key='F# minor', seed=902, human=(0.0, 2))
    s.channel('kit', 'electro_kit', pan=64, reverb=40, vol=100)
    s.channel('sbass', 'synth_bass2', pan=64, reverb=20, vol=94)
    s.channel('sbass2', 'bass_lead', pan=64, reverb=20, vol=64)
    s.channel('pad', 'poly_pad', pan=64, reverb=90, vol=76)
    s.channel('tick', 'synth_drum', pan=30, reverb=40, vol=56)
    s.channel('spic', 'strings', pan=40, reverb=80, vol=86)
    s.channel('lead', 'saw_lead', pan=50, reverb=70, vol=84)
    s.channel('lead2', 'saw_lead', pan=78, reverb=70, vol=66)
    s.channel('stab', 'strings', pan=36, reverb=85, vol=84)
    s.channel('brass', 'brass', pan=74, reverb=85, vol=84)
    s.channel('hit', 'orch_hit', pan=64, reverb=90, vol=70)
    s.channel('timp', 'timpani', pan=64, reverb=75, vol=94)
    s.channel('vc', 'cello', pan=82, reverb=90, vol=92)
    s.channel('piano', 'piano', pan=56, reverb=90, vol=80)
    s.channel('rise', 'sweep_pad', pan=64, reverb=100, vol=70)
    s.detune('sbass2', 9)
    s.detune('lead2', -10)
    for bar, nm in ((0, 'bed'), (4, 'A ostinato + riff'), (20, 'B Path answers'), (36, 'C quiet'), (52, 'drop'), (76, 'D glitch'),
                    (92, 'bed')):
        s.section(bar, nm)

    def ostinato(bar, sym, vel):
        tn = voice(sym, 'F#3', 3)
        cell = [tn[0], tn[0], tn[1], tn[0], tn[2], tn[0], tn[1], tn[2]]
        for k in range(16):
            s.note('spic', bar * 4 + k * .25, .2, cell[k % 8], vel + (10 if k % 4 == 0 else -6), human=False)

    def ticks(bar, vel):
        for k in (1, 3, 6, 7, 9, 11, 14):
            s.note('tick', bar * 4 + k * .25, .1, p('C6'), vel, human=False)

    def bed(bar, n=4):
        for i in range(n):
            sym = A_PROG[i % 4]
            s.pad('pad', bar + i, sym, 70, low='A3')
            chord(s, 'brass', (bar + i) * 4, 3.9, voice(sym, 'C#3', 3), 64)
            roll_bass(s, ('sbass', 'sbass2'), bar + i, sym, 84)
            drums(s, bar + i, 1, 92, clap=False)
            ostinato(bar + i, sym, 60)
        pump(s, 'pad', bar, n)
        s.motif('lead', bar, glitch(motif('F#4', 'minor')) + [('r', 1)], 80, form='glitched (saw lead, bed)')
        s.mel('lead', bar + 2, tr(LAB_RIFF, S), 78, legato=.8)
        s.line('lead2', bar + 2, tr(LAB_RIFF, S), 62, legato=.8)
        s.timp_roll((bar + n) * 4 - 2, 2, 'C#3', 50, 86)

    bed(0)

    # A 4-19: ostinato + ticks + riff, full kit
    for i in range(16):
        bar, sym = 4 + i, A_PROG[i % 4]
        s.pad('pad', bar, sym, 66, low='A3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 90)
        drums(s, bar, 1, 98)
        ostinato(bar, sym, 66)
        ticks(bar, 60)
        if i % 4 == 0:
            s.timp_hit(bar * 4, bass_note(sym) + 12, 84)
    pump(s, 'pad', 4, 16)
    s.mel('lead', 4, tr(LAB_RIFF, S) * 4, 90, legato=.8)
    s.line('lead2', 4, tr(LAB_RIFF, S) * 4, 72, legato=.8)
    s.motif('lead', 12, motif('F#5', 'minor') + [('r', 1)], 92, form='stated (saw lead, high)', legato=.85)
    s.line('lead2', 12, motif('F#4', 'minor'), 72)
    s.mel('lead', 14, tr(LAB_RIFF, S + 12) * 3, 88, legato=.8)
    s.line('lead2', 14, tr(LAB_RIFF, S) * 3, 70, legato=.8)

    # B 20-35: the Paths answer in orchestral stabs, the hero's motif answers back glitched
    calls = [('D.N.A. waltz head', [(p(n) - 6, d * .5) for n, d in DNA_THEME[:5]]),
             ('Buffet hook', tr(BUFFET_HOOK[:5], -3)),
             ('Dump jig head', tr(DUMP_JIG_HEAD[:8], -10)),
             ('Gainlands brass call', m('F#4:.5 F#4:.25 F#4:.25 C#5:1 B4:.5 A4:.5 F#4:1'))]
    for i in range(16):
        bar, sym = 20 + i, B_PROG[i % 4]
        s.pad('pad', bar, sym, 60, low='A3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 88, pattern='gallop')
        drums(s, bar, 1, 96, ohat=i % 4 != 3)
        ticks(bar, 56)
    pump(s, 'pad', 20, 16)
    for k, (nm, cell) in enumerate(calls):
        bar = 20 + k * 4
        s.mel('stab', bar, cell, 96, legato=.5)
        s.line('brass', bar, cell, 84, legato=.5)
        s.note('hit', bar * 4, 1, p('F#4'), 84, human=False)
        s.motif('lead', bar + 2, glitch(motif('F#4', 'minor'), cuts=(0, 3)) + [('r', 1)], 88, form=f'glitched answer to the {nm}')
        s.line('lead2', bar + 2, motif('F#4', 'minor'), 66)
    s.notes.append('B section: the four Paths\' theme heads as stabs (D.N.A., Buffet hook, Dump jig, a Gainlands-style brass call).')
    snare_build(s, 34, 2, 50, 104)

    # C 36-51: the quiet passage - no kick, pad, cello, piano ticks, the motif augmented in the cello; riser 48-51
    for i in range(16):
        bar, sym = 36 + i, B_PROG[i % 4]
        s.pad('pad', bar, sym, 66, low='A3')
        s.note('sbass', bar * 4, 3.9, bass_note(sym), 72, human=False)
        for k in range(8):
            s.note('piano', bar * 4 + k * .5, .2, voice(sym, 'F#5', 3)[k % 3], 54 + (8 if k % 4 == 0 else 0), human=False)
        if i >= 12:
            drums(s, bar, 1, 80, kick=False, clap=False)
    with human(s, (0.03, 8)):
        s.motif('vc', 36, augment(motif('B3', 'minor'), 2) + [('r', 2)], 90, form='augmented (cello, quiet passage)')
        s.mel('vc', 44, m('D4:4 | C#4:4 | B3:2 D4:2 | E#3:4'), 86, legato=1.0)
    riser(s, 'rise', 48, 4, 'F#3', vel=56)
    s.tag_melody('rise', 48, 52)
    snare_build(s, 48, 4, 40, 106)

    # DROP 52-75: heavy - full kit, timpani, hits, the riff and the motif together
    for i in range(24):
        bar, sym = 52 + i, A_PROG[i % 4]
        s.pad('pad', bar, sym, 76, low='A3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 96)
        drums(s, bar, 1, 104)
        ostinato(bar, sym, 70)
        if i % 2 == 0:
            chord(s, 'stab', bar * 4, .3, voice(sym, 'A3', 4), 80)
            chord(s, 'brass', bar * 4 + 2.5, .3, voice(sym, 'C#3', 3), 78)
            s.timp_hit(bar * 4, bass_note(sym) + 12, 90)
        if i % 8 == 0:
            s.note('kit', bar * 4, 2, CRASH, 106, human=False)
            s.note('hit', bar * 4, 1, voice(sym, 'F#4', 1)[0], 90, human=False)
    pump(s, 'pad', 52, 24, lo=30, hi=114)
    s.motif('lead', 52, glitch(motif('F#5', 'minor'), cuts=(0, 3, 5)) + [('r', 1)], 94, form='glitched high (drop)')
    s.line('lead2', 52, motif('F#4', 'minor'), 74)
    s.mel('lead', 54, tr(LAB_RIFF, S + 12) * 3, 90, legato=.8)
    s.line('lead2', 54, tr(LAB_RIFF, S) * 3, 72, legato=.8)
    s.motif('brass', 60, augment(motif_head('F#3', 'minor'), 2) + [('r', 4)], 90, form='head augmented (brass, drop)', lead=False)
    s.mel('lead', 60, tr(LAB_RIFF, S + 12) * 4, 92, legato=.8)
    s.line('lead2', 60, tr(LAB_RIFF, S) * 4, 72, legato=.8)
    s.motif('lead', 68, motif('F#5', 'minor') + [('r', 1)], 94, form='stated (saw lead, end of drop)', legato=.9)
    s.line('stab', 68, motif('F#4', 'minor'), 80)
    s.mel('lead', 70, tr(LAB_RIFF, S + 12) * 3, 90, legato=.8)
    s.line('lead2', 70, tr(LAB_RIFF, S) * 3, 72, legato=.8)

    # D 76-91: glitch - half-time kick, stutters, timpani, the riff chopped
    for i in range(16):
        bar, sym = 76 + i, B_PROG[i % 4]
        s.pad('pad', bar, sym, 66, low='A3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 90, pattern='gallop')
        drums(s, bar, 1, 98, half=i % 4 != 3, ohat=False)
        ticks(bar, 62)
        if i % 4 == 3:
            for k in range(4):
                stutter(s, 'spic', bar * 4 + k, voice(sym, 'F#4', 3)[k % 3], 70, beats=.5)
            s.timp_roll(bar * 4, 4, bass_note(sym) + 12, 50, 90)
        else:
            ostinato(bar, sym, 62)
    pump(s, 'pad', 76, 16)
    for k in (76, 80, 84):
        s.mel('lead', k, glitch(tr(LAB_RIFF, S), cuts=(0, 4, 10, 14)), 88, legato=.8)
        s.line('lead2', k, tr(LAB_RIFF, S), 68, legato=.8)
        s.mel('lead', k + 2, m('B4:1 A4:1 G4:1 F#4:1 | E#4:4'), 86)
    s.motif('lead', 88, glitch(motif('F#4', 'minor', inverted=True)) + [('r', 1)], 90, form='inverted glitched (saw lead)')
    s.mel('lead', 90, m('D5:2 C#5:2 | E#4:4'), 88)
    snare_build(s, 90, 2, 50, 100)

    bed(92)
    s.fade_vel(94, 96, 1.0, ['kit'])
    return s
