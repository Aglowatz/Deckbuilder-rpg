"""MUS-SIPHON-BOSS - A life's work (Dr. Ambrose Siphon). Loop, 112 bars 4/4, 170 BPM, C minor. Quantised. Its own track.
The heaviest Lab cue: an 808 kit, a rolling detuned saw bass, a pumped pad, orchestral hits, timpani and choir. Siphon's own idea
(SIPHON: a precise, delighted chromatic figure in even 8ths that circles the tonic through F# and B, like a scalpel) is stated on glass
and piano - intellectually delighted, morally chilling - then hammered by brass and strings in octaves at the climax. The "dissection"
section chops the royal/Path motifs into pieces and recombines them: the Crossroads head, the lullaby's first four notes (once), the
Lab riff and Siphon's cells stuttered and spliced together. The Crossroads motif answers as a glitched saw lead and, at the climax,
augmented in the horns. Intro/outro bed for the seam.
"""
from lib import Score, motif, motif_head, motif_tail, augment, m, p, voice, bass_note, LULLABY_HEAD
from scores._fork_c import (LAB_RIFF, tr, chord, drums, snare_build, pump, roll_bass, arp, stutter, glitch, riser, human, CRASH)

S = 3                                   # A minor riff -> C minor
SIPHON = [('C5', .5), ('G5', .5), ('F#5', .5), ('G5', .5), ('Eb5', .5), ('D5', .5), ('B4', 1),
          ('C5', .5), ('Ab5', .5), ('G5', .5), ('F#5', .5), ('F5', .5), ('Eb5', .5), ('D5', 1)]
SIPHON_END = [('C5', .5), ('G5', .5), ('F#5', .5), ('G5', .5), ('Ab5', 1), ('B4', 1), ('C5', 4)]
A_PROG = ['Cm', 'Ab', 'Fm', 'G']
B_PROG = ['Cm', 'Db', 'Bdim', 'G']


def build():
    s = Score('MUS-SIPHON-BOSS', bpm=170, bars=112, key='C minor', seed=903, human=(0.0, 2))
    s.channel('kit', 'tr808_kit', pan=64, reverb=40, vol=100)
    s.channel('sbass', 'synth_bass2', pan=64, reverb=20, vol=94)
    s.channel('sbass2', 'bass_lead', pan=64, reverb=20, vol=66)
    s.channel('pad', 'metal_pad', pan=64, reverb=90, vol=70)
    s.channel('glass', 'crystal', pan=40, reverb=95, vol=80)
    s.channel('piano', 'piano', pan=56, reverb=85, vol=86)
    s.channel('arp', 'square_lead', pan=82, reverb=70, vol=56)
    s.channel('lead', 'saw_lead', pan=50, reverb=70, vol=84)
    s.channel('lead2', 'saw_lead', pan=78, reverb=70, vol=66)
    s.channel('stab', 'strings', pan=36, reverb=85, vol=90)
    s.channel('brass', 'brass', pan=74, reverb=85, vol=88)
    s.channel('hn', 'horn', pan=78, reverb=95, vol=90)
    s.channel('timp', 'timpani', pan=64, reverb=75, vol=96)
    s.channel('choir', 'choir', pan=64, reverb=110, vol=70)
    s.channel('vc', 'cello', pan=82, reverb=90, vol=90)
    s.channel('rise', 'sweep_pad', pan=64, reverb=100, vol=70)
    s.detune('sbass2', 10)
    s.detune('lead2', -11)
    for bar, nm in ((0, 'bed'), (4, 'A Siphon on glass'), (20, 'drop 1'), (36, 'C dissection'), (52, 'climax'), (76, 'E recombine'),
                    (92, 'final drop'), (108, 'bed')):
        s.section(bar, nm)
    s.notes.append('Own villain idea SIPHON (glass/piano, then brass + strings in octaves); lullaby first four notes once in the dissection.')

    def hits(bar, sym, vel, every=2, i=0):
        if i % every == 0:
            chord(s, 'stab', bar * 4, .3, voice(sym, 'G3', 4), vel)
            chord(s, 'brass', bar * 4 + 1.5, .3, voice(sym, 'C3', 3), vel - 4)

    def bed(bar, n=4):
        for i in range(n):
            sym = A_PROG[i % 4]
            s.pad('pad', bar + i, sym, 72, low='G3')
            chord(s, 'choir', (bar + i) * 4, 3.9, voice(sym, 'G3', 3), 60)
            roll_bass(s, ('sbass', 'sbass2'), bar + i, sym, 88)
            drums(s, bar + i, 1, 94, clap=False)
            arp(s, 'arp', bar + i, 1, sym, 50, low='G4', step=.25)
        pump(s, 'pad', bar, n)
        s.mel('glass', bar, SIPHON * 2, 80, legato=.7)
        s.line('piano', bar, SIPHON * 2, 60, legato=.5, transpose=-12)
        s.timp_roll((bar + n) * 4 - 2, 2, 'G2', 50, 90)

    bed(0)

    # A 4-19: Siphon's figure on glass + piano over the grid; the cello answers with the motif, coldly
    for i in range(16):
        bar, sym = 4 + i, A_PROG[i % 4]
        s.pad('pad', bar, sym, 66, low='G3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 92)
        drums(s, bar, 1, 100)
        arp(s, 'arp', bar, 1, sym, 52, low='G4')
        hits(bar, sym, 80, every=4, i=i)
    pump(s, 'pad', 4, 16)
    s.mel('glass', 4, SIPHON * 3 + SIPHON_END, 88, legato=.7)
    s.line('piano', 4, SIPHON * 3 + SIPHON_END, 70, legato=.5)
    with human(s):
        s.motif('vc', 8, motif('C4', 'minor') + [('r', 1)], 84, form='stated (cello, answering)', lead=False)
    s.mel('lead', 12, SIPHON * 2, 86, legato=.8)
    s.line('lead2', 12, SIPHON * 2, 66, legato=.8, transpose=-12)
    s.motif('lead', 16, glitch(motif('C5', 'minor')) + [('r', 1)], 88, form='glitched (saw lead)')
    s.mel('glass', 18, SIPHON_END[:5] + [('r', 4)], 80)
    snare_build(s, 18, 2, 50, 106)

    # DROP 1 20-35: the Lab riff in the leads, hits every bar, timpani
    for i in range(16):
        bar, sym = 20 + i, A_PROG[i % 4]
        s.pad('pad', bar, sym, 76, low='G3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 96)
        drums(s, bar, 1, 106)
        arp(s, 'arp', bar, 1, sym, 56, low='G4')
        hits(bar, sym, 86, every=2, i=i)
        if i % 4 == 0:
            s.timp_hit(bar * 4, bass_note(sym) + 12, 92)
            s.note('brass', bar * 4, 1, p('C5'), 90, human=False)
        if i % 8 == 0:
            s.note('kit', bar * 4, 2, CRASH, 108, human=False)
    pump(s, 'pad', 20, 16, lo=30, hi=114)
    s.mel('lead', 20, tr(LAB_RIFF, S + 12) * 4, 90, legato=.8)
    s.line('lead2', 20, tr(LAB_RIFF, S) * 4, 72, legato=.8)
    s.motif('lead', 28, glitch(motif('C5', 'minor'), cuts=(0, 3, 5)) + [('r', 1)], 94, form='glitched (drop 1)')
    s.line('lead2', 28, motif('C4', 'minor'), 72)
    s.mel('lead', 30, SIPHON * 2 + tr(LAB_RIFF, S + 12) * 1, 90, legato=.8)
    s.line('lead2', 30, SIPHON * 2 + tr(LAB_RIFF, S), 70, legato=.8, transpose=-12)

    # C 36-51: the dissection - half-time, motifs chopped and spliced; the lullaby's first four notes once (glass), cut by a stutter
    for i in range(16):
        bar, sym = 36 + i, B_PROG[i % 4]
        s.pad('pad', bar, sym, 66, low='G3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 86, pattern='off')
        drums(s, bar, 1, 96, half=True, ohat=False)
    pump(s, 'pad', 36, 16, lo=44, hi=104)
    s.motif('lead', 36, glitch(motif_head('C5', 'minor', rhythm=(1, .5, .5)), cuts=(0,)) + [('r', 2)], 88, form='head, dissected (saw)')
    s.mel('glass', 37, SIPHON[:7], 84, legato=.6)
    s.motif('piano', 38, motif_tail('C5', 'minor', rhythm=(1, .5, 2.5)), 82, form='tail, spliced onto Siphon (piano)')
    s.mel('glass', 39, SIPHON[7:], 84, legato=.6)
    s.mel('glass', 40, [(p(n) - 2, 1.5) for n, d in LULLABY_HEAD[:4]], 82)          # C G Eb D: the lullaby's first four notes, once
    stutter(s, 'glass', 40 * 4 + 4.5, 'D5', 76, beats=1.5)
    s.notes.append('Lullaby: first four notes once (glass, bar 40, in C: C G Eb D), dissected by a stutter.')
    for k, cell in ((42, tr(LAB_RIFF[:10], S + 12)), (43, SIPHON[:7]), (44, motif_head('C5', 'minor', rhythm=(1, .5, 2.5))),
                    (45, SIPHON[7:]), (46, tr(LAB_RIFF[10:], S + 12)), (47, SIPHON_END[:5])):
        s.mel('lead' if k % 2 == 0 else 'glass', k, glitch(cell, cuts=(0,)), 86, legato=.75)
    with human(s, (0.03, 8)):
        s.line('vc', 40, m('C4:4 | Db4:4 | B3:4 | G3:4 | C4:4 | Db4:4 | D4:4 | G3:4'), 80, legato=1.0)
    riser(s, 'rise', 48, 4, 'G3', vel=58)
    s.tag_melody('rise', 48, 52)
    snare_build(s, 48, 4, 40, 108)

    # CLIMAX 52-75: Siphon's figure hammered in brass + strings in octaves; choir; the motif augmented in the horns against it
    for i in range(24):
        bar, sym = 52 + i, A_PROG[i % 4]
        s.pad('pad', bar, sym, 74, low='G3')
        chord(s, 'choir', bar * 4, 3.9, voice(sym, 'G3', 4), 72)
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 98)
        drums(s, bar, 1, 108)
        if i % 2 == 0:
            s.timp_hit(bar * 4, bass_note(sym) + 12, 94)
        if i % 8 == 0:
            s.note('kit', bar * 4, 2, CRASH, 110, human=False)
            s.note('brass', bar * 4, 1, p('G4'), 94, human=False)
    pump(s, 'pad', 52, 24, lo=30, hi=114)
    s.mel('stab', 52, SIPHON * 4, 96, legato=.8)
    s.line('brass', 52, SIPHON * 4, 90, legato=.7, transpose=-12)
    s.line('glass', 52, SIPHON * 4, 70, legato=.6)
    s.motif('hn', 54, augment(motif('C4', 'minor'), 2) + [('r', 2)], 96, form='augmented (horns, against Siphon)', lead=False)
    s.motif('lead', 60, motif('C5', 'minor') + [('r', 1)], 96, form='stated (saw lead, climax)', legato=.9)
    s.line('lead2', 60, motif('C4', 'minor'), 74)
    s.mel('lead', 62, tr(LAB_RIFF, S + 12) * 3, 92, legato=.8)
    s.line('lead2', 62, tr(LAB_RIFF, S) * 3, 72, legato=.8)
    s.mel('stab', 68, SIPHON * 3 + SIPHON_END[:5] + [('r', 2)], 98, legato=.8)
    s.line('brass', 68, SIPHON * 3 + SIPHON_END[:5], 92, legato=.7, transpose=-12)
    s.motif('hn', 70, motif_head('C4', 'minor', rhythm=(2, 1, 5)), 96, form='head augmented (horns)', lead=False)
    snare_build(s, 74, 2, 54, 110)

    # E 76-91: recombine - the hero's head + Siphon's tail (and back), glitches, a calmer bass
    for i in range(16):
        bar, sym = 76 + i, B_PROG[i % 4]
        s.pad('pad', bar, sym, 68, low='G3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 90, pattern='gallop')
        drums(s, bar, 1, 100, half=i % 4 != 3, ohat=False)
        arp(s, 'arp', bar, 1, sym, 54, low='G4', step=.5)
        if i % 4 == 3:
            for k in range(4):
                stutter(s, 'stab', bar * 4 + k, voice(sym, 'G4', 3)[k % 3], 76, beats=.5)
            s.timp_roll(bar * 4, 4, bass_note(sym) + 12, 50, 94)
    pump(s, 'pad', 76, 16)
    for k in (76, 80, 84):
        s.motif('lead', k, glitch(motif_head('C5', 'minor', rhythm=(1, .5, .5)), cuts=(0,)) + SIPHON[2:7], 90,
                form='head recombined with Siphon')
        s.line('lead2', k, motif_head('C4', 'minor', rhythm=(1, .5, .5)) + tr(SIPHON[2:7], -12), 70)
        s.mel('glass', k + 2, SIPHON[:3] + motif_tail('C5', 'minor', rhythm=(1, .5, 1)) + [('r', .5)], 84, legato=.7)
    s.motif('lead', 88, glitch(motif('C5', 'minor', inverted=True)) + [('r', 1)], 92, form='inverted glitched (saw)')
    s.mel('lead', 90, m('Ab5:2 G5:2 | B4:4'), 90)
    snare_build(s, 90, 2, 50, 108)

    # FINAL DROP 92-107
    for i in range(16):
        bar, sym = 92 + i, A_PROG[i % 4]
        s.pad('pad', bar, sym, 76, low='G3')
        chord(s, 'choir', bar * 4, 3.9, voice(sym, 'G3', 4), 66)
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 98)
        drums(s, bar, 1, 108)
        arp(s, 'arp', bar, 1, sym, 56, low='G4')
        hits(bar, sym, 88, every=2, i=i)
        if i % 8 == 0:
            s.note('kit', bar * 4, 2, CRASH, 108, human=False)
    pump(s, 'pad', 92, 16, lo=30, hi=114)
    s.motif('lead', 92, glitch(motif('C5', 'minor'), cuts=(0, 3, 5)) + [('r', 1)], 96, form='glitched (final drop)')
    s.line('lead2', 92, motif('C4', 'minor'), 74)
    s.mel('lead', 94, SIPHON * 3, 92, legato=.8)
    s.line('lead2', 94, SIPHON * 3, 70, legato=.8, transpose=-12)
    s.mel('lead', 100, tr(LAB_RIFF, S + 12) * 4, 92, legato=.8)
    s.line('lead2', 100, tr(LAB_RIFF, S) * 4, 72, legato=.8)
    s.motif('hn', 100, motif_head('C4', 'minor', rhythm=(2, 1, 5)), 92, form='head augmented (horns, final)', lead=False)

    bed(108)
    return s
