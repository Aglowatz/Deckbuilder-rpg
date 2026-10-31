"""Deliver rendered tracks (docs/audio/music_toolchain.md, "Deliver").

    python tools/music/deliver.py --review "Batch 01" IDS...     MP3 previews -> <Drive>/Music Review/Batch 01/<ID>.mp3
    python tools/music/deliver.py --approve IDS...               new OGG -> <Drive>/Approved_Audio/<ID>.ogg (old file backed up first)
    python tools/music/deliver.py --record-only --revision v04 MUS-TOWN   only refresh the registry.json record of the Drive file
    python tools/music/deliver.py --own MUS-TUT-BOSS             drop a compatibility alias in the Drive metadata (it has its own file now)

--approve also brings the Drive's registry.json record up to date (loop end = the new file's length, duration, sha256): the importer treats a
recorded loop end that falls inside the file as an explicit loop point, so a stale record would cut the new loop short. Every Drive file this
touches is copied to <Drive>/Superseded/Music_v01/ first (once; an existing backup is never overwritten). Then run "import audio".
"""
import argparse
import glob
import hashlib
import json
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from lib import render as R  # noqa: E402

DRIVE = os.environ.get('WP_DRIVE', r'G:\My Drive\Card Game Art')
AUDIO = os.path.join(DRIVE, 'Approved_Audio')
BACKUP = os.path.join(DRIVE, 'Superseded', 'Music_v01')
RENDERS = os.path.join(os.environ.get('WP_MUSIC_TOOLS', R.DEFAULT_TOOLS), 'renders')


def backup(path):
    os.makedirs(BACKUP, exist_ok=True)
    dest = os.path.join(BACKUP, os.path.basename(path))
    if os.path.exists(path) and not os.path.exists(dest):
        shutil.copy2(path, dest)
        return os.path.basename(path)
    return None


def frames_of(ff, path):
    raw = subprocess.run([ff, '-v', 'error', '-i', path, '-f', 's16le', '-ac', '1', '-ar', str(R.SR), '-'], capture_output=True, check=True).stdout
    return len(raw) // 2


def sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for block in iter(lambda: f.read(1 << 20), b''):
            h.update(block)
    return h.hexdigest()


def load_json(name):
    with open(os.path.join(AUDIO, name), encoding='utf-8-sig') as f:
        return json.load(f)


def save_json(name, data):
    with open(os.path.join(AUDIO, name), 'w', encoding='utf-8', newline='\r\n') as f:
        json.dump(data, f, indent=2)


def approve(ids, revision, record_only=False):
    _, _, ff = R.tool_paths()
    done = []
    reg = load_json('registry.json')
    saved = backup(os.path.join(AUDIO, 'registry.json'))
    for id in ids:
        dest = os.path.join(AUDIO, f'{id}.ogg')
        if record_only:
            n = frames_of(ff, dest)
        src = os.path.join(RENDERS, id, f'{id}.ogg')
        if not record_only and not os.path.exists(src):
            raise SystemExit(f'{id}: no render at {src} (run build.py first)')
        for old in [] if record_only else glob.glob(os.path.join(AUDIO, f'{id}.*')) + glob.glob(os.path.join(AUDIO, f'{id}_[vV]*.*')):
            backup(old)
            if os.path.basename(old) != f'{id}.ogg':
                os.remove(old)    # a stale WAV / _vN would win over the new OGG in the importer
        if not record_only:
            shutil.copy2(src, dest)
            n = frames_of(ff, dest)
        recs = [r for r in reg['records'] if r.get('file') == f'{id}.ogg' or r.get('id') == id]
        for r in recs:
            r.update({'file': f'{id}.ogg', 'source_revision': revision, 'status': 'Pending review', 'engine_verified': False,
                      'sample_rate': R.SR, 'channels': 2, 'duration_seconds': n / R.SR, 'loop_start_frame': 0,
                      'loop_end_exclusive_frame': n, 'sha256': sha256(dest)})
        done.append(f'{id}: {n} frames ({n / R.SR:.2f} s), {len(recs)} registry record(s)')
    save_json('registry.json', reg)
    return done, saved


def own(ids):
    """The ID gets its own music: drop the alias from dungeon_battle_aliases.json and the alias_of field in registry.json."""
    out = []
    for name in ('dungeon_battle_aliases.json', 'registry.json'):
        backup(os.path.join(AUDIO, name))
    al = load_json('dungeon_battle_aliases.json')
    before = len(al['aliases'])
    al['aliases'] = [a for a in al['aliases'] if a['id'] not in ids]
    save_json('dungeon_battle_aliases.json', al)
    out.append(f'dungeon_battle_aliases.json: {before - len(al["aliases"])} alias(es) removed')
    reg = load_json('registry.json')
    k = 0
    for r in reg['records']:
        if r.get('id') in ids and 'alias_of' in r:
            del r['alias_of']
            k += 1
    save_json('registry.json', reg)
    out.append(f'registry.json: alias_of removed from {k} record(s)')
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('ids', nargs='+')
    ap.add_argument('--review', default='')
    ap.add_argument('--approve', action='store_true')
    ap.add_argument('--own', action='store_true')
    ap.add_argument('--record-only', action='store_true', help='refresh the registry.json record from the Drive file as it is')
    ap.add_argument('--revision', default='orch-v1')
    a = ap.parse_args()
    if a.review:
        d = os.path.join(DRIVE, 'Music Review', a.review)
        os.makedirs(d, exist_ok=True)
        for id in a.ids:
            shutil.copy2(os.path.join(RENDERS, id, f'{id}.mp3'), os.path.join(d, f'{id}.mp3'))
        print(f'{len(a.ids)} previews -> {d}')
    if a.approve or a.record_only:
        done, saved = approve(a.ids, a.revision, record_only=a.record_only)
        print('\n'.join(done))
        if saved:
            print('backed up', saved)
    if a.own:
        print('\n'.join(own(a.ids)))


if __name__ == '__main__':
    main()
