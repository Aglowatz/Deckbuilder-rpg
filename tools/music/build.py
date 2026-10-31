"""Build orchestral tracks from their scores (docs/audio/music_toolchain.md).

    python tools/music/build.py MUS-TITLE MUS-FOREST ...        render, check, write .mid + report
    python tools/music/build.py --check-only MUS-TITLE          score checks only (no audio)
    python tools/music/build.py --review "Batch 01" IDS...      also copy the MP3 previews to <Drive>/Music Review/Batch 01/
    python tools/music/build.py --approve IDS...                also back up the old Approved_Audio file to Superseded/Music_v01 and
                                                                copy the new OGG in (then run "import audio")
Scores: tools/music/scores/<ID>.py, each with build() -> Score. MIDI: tools/music/midi/<ID>.mid (the source of truth for a later
re-render). Reports: tools/music/reports/<ID>.json. Audio: <WP_MUSIC_TOOLS>/renders/<ID>/ (outside the repo).
"""
import argparse
import glob
import importlib.util
import json
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from lib import render as R          # noqa: E402
from lib.checks import all_checks    # noqa: E402

DRIVE = os.environ.get('WP_DRIVE', r'G:\My Drive\Card Game Art')


def load(id):
    path = os.path.join(HERE, 'scores', f'{id}.py')
    if not os.path.exists(path):
        raise SystemExit(f'no score for {id} ({path})')
    spec = importlib.util.spec_from_file_location(id.replace('-', '_'), path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.build()


def approve(id, ogg):
    src = os.path.join(DRIVE, 'Approved_Audio')
    bak = os.path.join(DRIVE, 'Superseded', 'Music_v01')
    os.makedirs(bak, exist_ok=True)
    moved = []
    for old in glob.glob(os.path.join(src, f'{id}.*')) + glob.glob(os.path.join(src, f'{id}_[vV]*.*')):
        dest = os.path.join(bak, os.path.basename(old))
        if not os.path.exists(dest):
            shutil.copy2(old, dest)
            moved.append(os.path.basename(old))
        if not old.lower().endswith('.ogg') or os.path.basename(old) != f'{id}.ogg':
            os.remove(old)    # a stale WAV / _vN would win over the new OGG in the importer
    shutil.copy2(ogg, os.path.join(src, f'{id}.ogg'))
    return moved


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('ids', nargs='+')
    ap.add_argument('--check-only', action='store_true')
    ap.add_argument('--review', default='')
    ap.add_argument('--approve', action='store_true')
    a = ap.parse_args()
    os.makedirs(os.path.join(HERE, 'midi'), exist_ok=True)
    os.makedirs(os.path.join(HERE, 'reports'), exist_ok=True)
    renders = os.path.join(os.environ.get('WP_MUSIC_TOOLS', R.DEFAULT_TOOLS), 'renders')
    seen = {}
    failed = []
    for id in a.ids:
        s = load(id)
        chk = all_checks(s)
        sig = (s.key, s.bpm)
        if sig in seen:
            print(f'!! {id} shares key and tempo with {seen[sig]} ({s.key}, {s.bpm} BPM)')
            failed.append(id)
        seen[sig] = id
        line = f'{id}: {s.key}, {s.bpm} BPM {s.meter[0]}/{s.meter[1]}, {s.bars} bars = {s.seconds:.1f} s, {s.note_count()} notes'
        flags = [k for k, v in chk.items() if not v['ok']]
        if a.check_only:
            print(line, '| checks:', 'ok' if not flags else 'WARN ' + ', '.join(flags))
            for k in flags:
                print('   ', k, json.dumps(chk[k])[:300])
            continue
        rep = R.render(s, os.path.join(HERE, 'midi', f'{id}.mid'), os.path.join(renders, id))
        rep['checks'] = chk
        rep['composer_notes'] = s.notes
        audio_ok = rep['peak_ok'] and rep['lufs_ok'] and (rep.get('seam', {'ok': True})['ok'])
        if not audio_ok:
            failed.append(id)
        seam = rep.get('seam')
        arc = ' '.join(f"{x['section']}:{x['lufs']}" for x in rep['sections'])
        print(f"{line} | {rep['lufs']} LUFS, TP {rep['true_peak']} dB"
              + (f", seam {seam['jump_db']:+.2f} dB{' CLICK' if seam['click'] else ''}" if seam else '')
              + (f", limited {rep['limited_db']} dB" if rep['limited_db'] else '')
              + f" | arc {arc} | checks {'ok' if not flags else 'WARN ' + ', '.join(flags)}")
        for k in flags:
            print('   ', k, json.dumps(chk[k])[:300])
        if a.review:
            d = os.path.join(DRIVE, 'Music Review', a.review)
            os.makedirs(d, exist_ok=True)
            shutil.copy2(rep['files']['mp3'], os.path.join(d, f'{id}.mp3'))
            rep['review'] = os.path.join(d, f'{id}.mp3')
        if a.approve:
            rep['superseded'] = approve(id, rep['files']['ogg'])
        with open(os.path.join(HERE, 'reports', f'{id}.json'), 'w', encoding='utf-8') as f:
            json.dump(rep, f, indent=1, ensure_ascii=False)
    if failed:
        print('NEEDS ATTENTION:', ', '.join(failed))
        sys.exit(1)


if __name__ == '__main__':
    main()
