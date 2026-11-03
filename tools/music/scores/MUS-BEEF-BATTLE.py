"""MUS-BEEF-BATTLE - The Gainlands, combat. 64 bars 4/4, 140 BPM, E minor. TECHNO HARD ROCK (Gainlands rock Nov 3).
The approved demo (Music_Source/zone_demos/ZONE-GAINLANDS_demo_score.py, "Gainlands battle demo (techno hard rock).mp3") ported note for
note through lib/rock.py: riff -> theme -> build -> drop -> breakdown -> build -> drop 2 -> outro. Distorted double-tracked guitars,
bass + synth sub in the drops, GS power kit, noise risers, heroic brass stabs, the Crossroads motif on lead guitar (E B A G F# B) and the
Gainlands answer phrase - the Gainlands theme every Beefcake cue carries. Loop fixes only (see the end).
"""
from lib import Song, p
from lib import rock as R
from lib.rock import PROG, ROOT, MOTIF, ANSWER, ANSWER_TAG, LICK, BRASS_HITS


def build():
    S = Song('MUS-BEEF-BATTLE', bpm=140, bars=64, key='E minor', seed=5)
    S.jitter = 0.006
    R.band(S)
    for bar, nm in ((0, 'intro arp'), (4, 'riff'), (12, 'theme'), (20, 'build'), (24, 'drop'), (32, 'breakdown'),
                    (40, 'build 2'), (44, 'drop 2'), (56, 'outro riff'), (62, 'outro arp')):
        S.section(bar, nm)
    S.notes.append('The approved Gainlands techno hard rock demo, ported exactly (lib/rock.py keeps its note order and humanising).')

    # 0-3 INTRO: saw arp over a kick pulse; riser into the riff
    for i in range(4):
        c = PROG[i % 4]
        R.arp(S, i, c, 50 + i * 8)
        R.kick_pulse(S, i, 70 + i * 10)
    S.ramp('saw', 0, 4, 40, 110)
    R.snare_roll(S, 3, 1, 50, 110)
    R.riser(S, 2, 2)

    # 4-11 RIFF A: gallop chug, rock beat, bass
    R.crash(S, 4)
    for i in range(8):
        bar = 4 + i
        c = PROG[(i // 2) % 4]
        R.chug(S, bar, c, 86)
        R.bassline(S, bar, c, 92)
        R.rock_beat(S, bar, 104, fill=(i == 7))

    # 12-19 THEME: lead guitar motif + answer, brass stabs, sustained power chords
    R.crash(S, 12)
    for i in range(8):
        bar = 12 + i
        c = PROG[(i // 2) % 4]
        if i % 2 == 0:
            R.sustain(S, bar, c, 80, beats=8)
        R.bassline(S, bar, c, 90)
        R.rock_beat(S, bar, 104, fill=(i == 7))
        S.chord('brass', S.B(bar), .6, BRASS_HITS[c], 92)
        S.chord('brass', S.B(bar, 2.5), .4, BRASS_HITS[c], 80)
    S.motif('lead', 12, MOTIF, 104, form='stated (lead guitar)', tr=12)
    S.mel('lead', 14, ANSWER, 102, tr=0)
    S.motif('lead', 16, MOTIF, 108, form='stated again (lead guitar)', tr=12)
    S.mel('lead', 18, ANSWER_TAG, 110)

    # 20-23 BUILD: half-time, snare roll, riser, guitars swell
    for i in range(4):
        bar = 20 + i
        c = ['C', 'D', 'C', 'D'][i]
        R.sustain(S, bar, c, 48 + i * 10)
        S.chord('pad', S.B(bar), 4, [p(n) + 12 for n in BRASS_HITS[c][1:]], 70)
    R.snare_roll(S, 20, 4, 30, 112)
    for k in range(32):
        S.note('timp', S.B(22) + k * .25, .2, p('E2'), 40 + k * 2, human=False)
    R.riser(S, 20, 4)

    # 24-31 DROP 1: four-on-the-floor, sub bass, chug locked to the kick, saw stabs
    R.crash(S, 24, 120)
    for i in range(8):
        bar = 24 + i
        c = PROG[(i // 2) % 4]
        R.four_floor(S, bar, 118)
        R.subdrop(S, bar, c, 104)
        R.chug(S, bar, c, 90, pattern='straight')
        for b in (0, 1.5, 3):
            S.chord('saw', S.B(bar, b), .3, [p(ROOT[c]) + 36, p(ROOT[c]) + 43], 80)
    S.pump('pad', 24, 8, lo=20, hi=100)
    for i in range(8):
        S.chord('pad', S.B(24 + i), 4, [p(n) + 12 for n in BRASS_HITS[PROG[(i // 2) % 4]][1:]], 76)
    S.motif('lead', 28, MOTIF, 96, form='stated (lead guitar, in the drop)', tr=12)

    # 32-39 BREAKDOWN: half-time groove, gym clank (cowbell), lead lick, brass chorale
    for i in range(8):
        bar = 32 + i
        c = ['E', 'E', 'C', 'C', 'D', 'D', 'B', 'B'][i]
        R.rock_beat(S, bar, 96, half=True)
        if i % 2 == 0:
            R.sustain(S, bar, c, 66, beats=8)
            S.chord('brass', S.B(bar), 7.9, BRASS_HITS[c], 70)
        R.bassline(S, bar, c, 84, style='hold')
        S.note('kit', S.B(bar, 1.5), .2, 56, 70, human=False)      # cowbell clank
        S.note('kit', S.B(bar, 3.5), .2, 56, 60, human=False)
    S.mel('lead', 32, LICK, 100)

    # 40-43 BUILD 2: bigger roll + riser + timpani
    for i in range(4):
        bar = 40 + i
        c = ['C', 'D', 'C', 'B'][i]
        R.sustain(S, bar, c, 52 + i * 10)
        S.chord('brass', S.B(bar), 3.9, BRASS_HITS[c], 56 + i * 10)
    R.snare_roll(S, 40, 4, 36, 118)
    for k in range(32):
        S.note('timp', S.B(42) + k * .25, .2, p('B1'), 46 + k * 2, human=False)
    R.riser(S, 40, 4)

    # 44-55 DROP 2 + THEME: everything - four-floor, sub, chug, brass, motif an octave up
    R.crash(S, 44, 124)
    for i in range(12):
        bar = 44 + i
        c = PROG[(i // 2) % 4]
        R.four_floor(S, bar, 122)
        R.subdrop(S, bar, c, 108)
        R.chug(S, bar, c, 96, pattern='gallop' if i % 4 < 2 else 'straight')
        S.chord('brass', S.B(bar), .5, BRASS_HITS[c], 100)
        S.chord('brass', S.B(bar, 1.5), .4, BRASS_HITS[c], 88)
        S.chord('brass', S.B(bar, 3), .5, BRASS_HITS[c], 94)
        if i % 4 == 0:
            R.crash(S, bar, 112)
    S.motif('lead', 44, MOTIF, 112, form='stated 8va (lead guitar, drop 2)', tr=12)
    S.mel('lead', 46, ANSWER, 110, tr=12)
    S.motif('lead', 48, MOTIF, 114, form='stated 8va again', tr=12)
    S.mel('lead', 50, ANSWER_TAG, 116, tr=12)
    S.motif('saw', 52, MOTIF, 86, form='stated 2 octaves up (saw)', tr=24)
    S.pump('pad', 44, 12, lo=20, hi=104)
    for i in range(12):
        S.chord('pad', S.B(44 + i), 4, [p(n) + 12 for n in BRASS_HITS[PROG[(i // 2) % 4]][1:]], 80)

    # 56-63 OUTRO RIFF: back to the gallop riff, thinning into the intro arp so the loop wraps
    for i in range(8):
        bar = 56 + i
        c = PROG[(i // 2) % 4]
        if i < 6:
            R.chug(S, bar, c, 84 - i * 2)
            R.bassline(S, bar, c, 88)
            R.rock_beat(S, bar, 100 - i * 3, fill=(i == 5))
        else:
            R.arp(S, bar, c, 46)
            R.kick_pulse(S, bar, 72)
            R.bassline(S, bar, c, 70, style='hold')

    # LOOP/LOUDNESS FIX (added after the port, so every note above keeps its humanising draw). The approved MP3's first four bars are
    # kick-heavy and ~16 dB louder than the same bars when its preview wraps; rendered from the script they sit 13 LU under the track
    # (a 7 s hole at every battle start and loop). Both arp sections get the same bed so the seam stays matched: a firmer kick pulse,
    # the drops' synth-sub 8ths, a pad, and the saw's CC11 starting at 100 instead of 40.
    S.cc11['saw'] = [(t, v) for t, v in S.cc11['saw'] if t >= S.B(4)]
    S.ramp('saw', 0, 4, 100, 116)
    S.ramp('saw', 62, 2, 100, 108)
    for bar, c in ((0, 'E'), (1, 'C'), (2, 'D'), (3, 'B'), (62, 'D'), (63, 'B')):
        R.kick_pulse(S, bar, 116)
        R.subdrop(S, bar, c, 100)
        R.pad_chord(S, bar, c, 70)
        R.sustain(S, bar, c, 58)                                   # a held power chord under the arp, as in the builds
    S.fade_vel(0, 4, 1.7, chans=['saw'], start_factor=1.7)      # the arp itself up (velocities only)
    S.fade_vel(62, 64, 2.3, chans=['saw'], start_factor=2.1)
    for ch in ('gtrL', 'gtrR'):
        S.ramp(ch, 0, 4, 76, 100)
        S.ramp(ch, 62, 2, 76, 84)

    # The riff is the tune in the riff/build sections (audibility check only, no audible change).
    for a, b in ((4, 12), (20, 28), (40, 44), (56, 62)):
        S.tag_melody('gtrL', a, b)
    S.tag_melody('saw', 0, 4)
    S.tag_melody('saw', 62, 64)
    return S
