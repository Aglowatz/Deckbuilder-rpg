"""Gainlands rock Nov 3: the rock render profile (render.amp_sim / add_risers / glue / rock_chain, Score stems, lib/rock.py).
Run: "$LOCALAPPDATA/Programs/Python/Python312/python.exe" -m unittest tools.music.tests.test_rock_render  (from the repo root)"""
import importlib.util
import os
import sys
import tempfile
import unittest

import mido
import numpy as np

HERE = os.path.dirname(__file__)
sys.path.insert(0, os.path.join(HERE, '..'))
from lib import Song, Score  # noqa: E402
from lib import rock as R  # noqa: E402
from lib import render  # noqa: E402

SR = render.SR
DEMO = r'G:\My Drive\Card Game Art\Music_Source\zone_demos'


def band_db(x, lo, hi):
    f = np.abs(np.fft.rfft(x)) ** 2
    fr = np.fft.rfftfreq(len(x), 1 / SR)
    return 10 * np.log10(f[(fr >= lo) & (fr < hi)].sum() + 1e-12)


def note_ons(path):
    out = []
    for tr in mido.MidiFile(path).tracks:
        t = 0
        for m in tr:
            t += m.time
            if m.type == 'note_on' and m.velocity > 0:
                out.append((t, m.channel, m.note, m.velocity))
    return sorted(out)


class AmpSimTest(unittest.TestCase):
    def setUp(self):
        t = np.arange(SR) / SR
        self.sine = np.stack([0.3 * np.sin(2 * np.pi * 220 * t)] * 2, axis=1)

    def test_drive_adds_harmonics(self):
        y = render.amp_sim(self.sine)[:, 0]
        # a clean 220 Hz sine has no energy at its 3rd harmonic; the tanh drive puts it there
        self.assertGreater(band_db(y, 640, 680) - band_db(self.sine[:, 0], 640, 680), 40)

    def test_output_is_bounded_and_the_cabinet_rolls_off_the_fizz(self):
        y = render.amp_sim(self.sine * 10)
        self.assertLess(np.max(np.abs(y)), 0.7)
        hard = np.sign(self.sine[:, 0]) * 0.55          # what the drive alone would leave: a square wave
        self.assertLess(band_db(y[:, 0], 9000, 20000), band_db(hard, 9000, 20000) - 20)

    def test_low_rumble_is_cut_before_the_drive(self):
        t = np.arange(SR) / SR
        rumble = np.stack([0.3 * np.sin(2 * np.pi * 30 * t)] * 2, axis=1)
        self.assertLess(np.sqrt(np.mean(render.amp_sim(rumble) ** 2)), np.sqrt(np.mean(render.amp_sim(self.sine) ** 2)) * 0.5)


class RiserAndGlueTest(unittest.TestCase):
    def test_riser_sits_in_its_window_and_swells(self):
        mix = render.add_risers(np.zeros((4 * SR, 2)), [(1.0, 2.0)])
        self.assertEqual(np.abs(mix[:SR]).max(), 0.0)
        self.assertEqual(np.abs(mix[3 * SR + 10:]).max(), 0.0)
        early, late = np.abs(mix[SR:int(1.5 * SR), 0]).mean(), np.abs(mix[int(2.5 * SR):3 * SR, 0]).mean()
        self.assertGreater(late, early * 5)

    def test_riser_past_the_end_is_clipped_not_an_error(self):
        mix = render.add_risers(np.zeros((SR, 2)), [(0.5, 2.0)])
        self.assertEqual(mix.shape, (SR, 2))

    def test_glue_adds_the_hall_tail_and_stays_under_full_scale(self):
        x = np.zeros((SR, 2))
        x[100:2000] = 0.9
        y = render.glue(x)
        self.assertGreater(len(y), len(x))
        self.assertLessEqual(np.max(np.abs(y)), 1.0 + 1e-9)
        self.assertGreater(np.abs(y[len(x):]).max(), 0.0)


class StemTest(unittest.TestCase):
    def song(self):
        s = Song('TEST-ROCK', bpm=140, bars=2, key='E minor', seed=1)
        R.band(s)
        R.chug(s, 0, 'E', 90)
        R.bassline(s, 0, 'E', 90)
        R.crash(s, 1)
        R.rock_beat(s, 1, 100)          # its beat-1 kick doubles the crash kick
        s.mel('lead', 1, R.MOTIF[:3], 100, tr=12)
        return s

    def test_band_sets_the_rock_profile(self):
        s = self.song()
        self.assertEqual(s.profile, 'rock')
        self.assertEqual(s.stem, set(R.GTR))
        self.assertTrue(s.ch['kit']['drums'])
        self.assertEqual(Score('X', 120, 1).profile, 'orchestral')

    def test_only_and_skip_split_the_channels(self):
        s = self.song()
        with tempfile.TemporaryDirectory() as tmp:
            full, g, r = (os.path.join(tmp, n) for n in ('full.mid', 'g.mid', 'r.mid'))
            s.to_midi(full)
            s.to_midi(g, only=s.stem)
            s.to_midi(r, skip=s.stem)
            names = lambda pth: {t.name for t in mido.MidiFile(pth).tracks[1:]}
            self.assertEqual(names(g), set(R.GTR))
            self.assertFalse(names(r) & set(R.GTR))
            self.assertEqual(sorted(note_ons(g) + note_ons(r)), note_ons(full))
            self.assertAlmostEqual(mido.MidiFile(g).length, mido.MidiFile(r).length, places=3)

    def test_stacked_drums_keep_the_doubled_kick(self):
        s = self.song()
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, 'a.mid')
            s.to_midi(path)
            kicks = [e for e in note_ons(path) if e[1] == 9 and e[2] == 36 and e[0] == 4 * 480]
            self.assertEqual(len(kicks), 2)
            s.stack_drums = False
            s.to_midi(path)
            kicks = [e for e in note_ons(path) if e[1] == 9 and e[2] == 36 and e[0] == 4 * 480]
            self.assertEqual(len(kicks), 1, 'the orchestral path still merges same-pitch strikes (the overlap fix)')

    def test_risers_are_in_beats(self):
        s = self.song()
        R.riser(s, 1, 1)
        self.assertEqual(s.risers, [(4.0, 4.0)])


@unittest.skipUnless(os.path.exists(os.path.join(DEMO, 'ZONE-GAINLANDS_demo_guitars.mid')), 'approved demo MIDI not on this machine')
class DemoPortTest(unittest.TestCase):
    def test_battle_port_matches_the_approved_demo(self):
        spec = importlib.util.spec_from_file_location('beef_battle', os.path.join(HERE, '..', 'scores', 'MUS-BEEF-BATTLE.py'))
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        s = mod.build()
        with tempfile.TemporaryDirectory() as tmp:
            g = os.path.join(tmp, 'g.mid')
            s.to_midi(g, only=s.stem)
            demo = [e for e in note_ons(os.path.join(DEMO, 'ZONE-GAINLANDS_demo_guitars.mid'))]
            ours = note_ons(g)
            # every demo guitar note is in the port, at the same tick and velocity; the port only adds the intro/outro swell (loop fix)
            missing = set(demo) - set(ours)
            self.assertFalse(missing, f'{len(missing)} demo guitar notes missing')
            extra = [e for e in ours if e not in set(demo)]
            self.assertTrue(all(e[0] < 4 * 4 * 480 or e[0] >= 62 * 4 * 480 - 20 for e in extra), 'additions only in the arp bars')


if __name__ == '__main__':
    unittest.main()
