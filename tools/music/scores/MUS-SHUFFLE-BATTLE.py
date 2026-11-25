"""MUS-SHUFFLE-BATTLE - All in (fights in the Shuffle House and the Shuffled Halls). Loop, 96 bars 4/4, 172 BPM, G minor. Quantised.
Fast electronic combat music: four-on-the-floor on the electronic kit, a rolling detuned synth bass, a pumped pad, the DEAL
riff on two saw leads with a square arpeggio under it, synth-brass stabs. It starts on the hit: no intro. The back-room CASINO
tune is the second section, a half-time passage and an eight-bar build lead to the drop, where the house's own hook rides in
on the calliope (turned minor), and a glitch section brings the riff back for the seam. Original (Fable Nov 25).
"""
from lib import Score
from scores._shuffle import fight


def build():
    s = Score('MUS-SHUFFLE-BATTLE', bpm=172, bars=96, key='G minor', seed=2511, human=(0.0, 2))
    s.channel('kit', 'electro_kit', pan=64, reverb=36, vol=100)
    s.channel('sbass', 'synth_bass2', pan=64, reverb=18, vol=96)
    s.channel('sbass2', 'bass_lead', pan=64, reverb=18, vol=66)
    s.channel('pad', 'poly_pad', pan=64, reverb=90, vol=72)
    s.channel('lead', 'saw_lead', pan=50, reverb=66, vol=86)
    s.channel('lead2', 'saw_lead', pan=80, reverb=66, vol=64)
    s.channel('sq', 'square_lead', pan=34, reverb=60, vol=54)
    s.channel('stab', 'synth_brass', pan=72, reverb=80, vol=82)
    s.channel('hit', 'orch_hit', pan=64, reverb=90, vol=68)
    s.channel('cal', 'calliope', pan=42, reverb=70, vol=70)
    s.channel('rise', 'sweep_pad', pan=64, reverb=100, vol=68)
    s.detune('sbass2', 9)
    s.detune('lead2', -10)
    fight(s, shift=0, hot=False)
    s.notes.append('The house hook (HOOK_MINOR) on the calliope over the drop, bars 64-71; the casino tune in B and D.')
    return s
