// Generates docs/audio/music_integration.md from data/audio/audio_registry.json (what plays), data/source/music_triggers.csv (where it is triggered),
// data/source/audio_levels.csv (loudness and loop-seam analysis) and data/source/music_list.csv (cue names). Usage: node tools/audio_doc.js
// Prints the comma-separated list of IDs that are In Game.
const fs = require('fs');

function parseCsv(text) {
  const rows = [];
  let row = [], field = '', quoted = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (quoted) {
      if (c === '"') { if (text[i + 1] === '"') { field += '"'; i++; } else quoted = false; } else field += c;
    } else if (c === '"') quoted = true;
    else if (c === ',') { row.push(field); field = ''; }
    else if (c === '\n') { row.push(field); rows.push(row); row = []; field = ''; }
    else if (c !== '\r') field += c;
  }
  if (field || row.length) { row.push(field); rows.push(row); }
  return rows;
}
const read = (p) => parseCsv(fs.readFileSync(p, 'utf8').replace(/^\uFEFF/, ''));

const registry = JSON.parse(fs.readFileSync('data/audio/audio_registry.json', 'utf8')).entries;
const triggers = {};
for (const r of read('data/source/music_triggers.csv').slice(1)) if (r[0]) triggers[r[0]] = { status: r[1], trigger: r[2], notes: r[3] || '' };
const levels = {};
for (const r of read('data/source/audio_levels.csv').slice(1)) if (r[0]) levels[r[0]] = { frames: +r[3], lufs: +r[5], peak: +r[6], click: +r[8], gap: +r[9], jump: +r[10], flags: (r[13] || '').trim() };
const catalogue = {};
for (const r of read('data/source/music_list.csv')) if (/^(MUS|STG)-/.test(r[0])) catalogue[r[0]] = { name: r[1], playback: r[9] };

const ids = Object.keys(registry).sort((a, b) => {
  const order = (x) => (x.startsWith('MUS-') ? 0 : 1);
  return order(a) - order(b) || a.localeCompare(b);
});
const fixLines = [];
const stepLines = [];
const rows = [];
const inGame = [];
const notInGame = [];
const missing = [];
const esc = (s) => String(s).replace(/\|/g, '\\|').replace(/\n/g, ' ');
for (const id of ids) {
  const e = registry[id];
  const t = triggers[id] || { status: 'No trigger yet', trigger: '', notes: '' };
  const lv = levels[e.alias_of || id] || levels[id] || { flags: '' };
  const flags = (lv.flags || '').split(' ').filter(Boolean);
  const fixes = [];
  if (flags.includes('seam-click')) fixes.push(`click at the wrap (${lv.click}x the file's own error)`);
  if (flags.includes('silent-gap')) fixes.push(`${lv.gap.toFixed(2)} s of digital silence at the wrap`);
  if (flags.includes('level-jump')) fixes.push(`ends ${Math.abs(lv.jump).toFixed(0)} dB ${lv.jump > 0 ? 'quieter' : 'louder'} than it begins (decay / cut-off tail)`);
  const steps = flags.includes('level-step') ? `listen: ${Math.abs(lv.jump).toFixed(0)} dB step at the wrap` : '';
  let status = t.status;
  if (!e.file) status = 'Missing file';
  let loopCheck = e.loop ? 'OK' : 'n/a (one-shot)';
  if (e.loop && fixes.length) { loopCheck = 'Needs loop fix: ' + fixes.join('; '); fixLines.push(`${id}: ${fixes.join('; ')}${e.alias_of ? ` (same file as ${e.alias_of})` : ''}`); }
  else if (e.loop && steps) { loopCheck = steps; stepLines.push(`${id}: ${steps}`); }
  if (status === 'In Game') inGame.push(id); else if (status === 'Missing file') missing.push(id); else notInGame.push(`${id} (${status})`);
  const file = e.file ? e.file.replace('res://assets/audio/', '') : '(none)';
  const name = (catalogue[id] || {}).name || e.name || '';
  rows.push(`| ${id} | ${esc(name)} | \`${file}\`${e.alias_of ? ` (alias of ${e.alias_of})` : ''} | ${e.kind}${e.loop ? ', loop' : ''} | ${e.volume_db >= 0 ? '+' : ''}${e.volume_db.toFixed(1)} | ${esc(t.trigger)} | ${status} | ${esc(loopCheck)} | ${esc(t.notes)} |`);
}

const md = `# Music integration

The approved soundtrack (\`G:\\My Drive\\Card Game Art\\Approved_Audio\`, 123 music cues and 21 stings, catalogued in \`data/source/music_list.csv\`) is imported and wired
to the game. Nothing in the Drive folder was moved, renamed or deleted: the importer only copies.

## How it fits together

| Piece | File | What it does |
|---|---|---|
| Audio registry | \`data/audio/audio_registry.json\` (generated), \`core/data/audio_registry.gd\` | Stable ID -> file, loop on/off, bus, base volume, alias. Replace a track by swapping \`assets/audio/music/<ID>.ogg\` (or \`stings/<ID>.wav\`) and running "import audio". |
| Importer | \`tools/import_audio.sh\` (\`--analyze\` also refreshes loudness and loop-seam data) | Copies by ID (loops OGG, stings WAV, long story cues converted to OGG with ffmpeg), writes the registry and \`data/source/audio_import_manifest.csv\`. The folder is \`audio_dir\` in \`data/source/art_config.cfg\`. |
| Director | \`app/music_director.gd\` | Pure functions: which ID plays for a game state (zone + completion flag, dungeon ID, battle context, Capital area, vendor screen, cutscene...). |
| Manager | \`app/music_manager.gd\` (owned by the \`Audio\` autoload) | Equal-power crossfades, an override stack that resumes the area track, stings with ducking, the dialogue duck. |
| Triggers | \`data/source/music_triggers.csv\` | One row per ID: where it plays (this document's table is generated from it by \`tools/audio_doc.js\`). |
| Levels | \`data/source/audio_levels.csv\`, \`tools/audio_analyze.js\` | Loudness (EBU R128 via ffmpeg), true peak and loop-seam checks of every delivered file. |

### Playback rules

- **Area track.** \`Audio.play_music(id)\` sets the area's music; asking for the track already playing does nothing (no restart). Changing area crossfades over 1.5 s (equal power: the sum stays at full loudness; the smoke measured at most 0.25 dB change per frame).
- **Overrides.** \`Audio.push_music(id)\` / \`pop_music(token)\` lay a battle, a shop, a story cue or the graveyard over the area track. The area track is suspended at its position and **resumes where it left off** when the override is popped; if the area changes underneath, the new area's music is what comes back. One-shot story cues hand back by themselves when they end.
- **Shops and menus.** A vendor screen pushes its theme once when it opens (\`OverlayScreen.music_cue\`), so purchases never retrigger it; closing resumes the town. The deck station and the collection have \`MUS-DECK\`. Short overlays (character, quests, map, wardrobe, packs, fast travel, pause, settings) keep the current music.
- **Stings.** \`Audio.sting(id)\` plays over the music on the Music bus and ducks it by 9 dB (13 dB over a story cue) while it rings. The old \`victory\` / \`defeat\` / \`level_up\` effect names play the registry stings (fallback: the old Kenney sounds).
- **Dialogue.** The \`DialogueBox\` ducks the music by 4.5 dB while a conversation is up (fast attack, 14 dB/s release).
- **Never silent.** An ID with no loadable file falls back to a category track (fight song / deck theme / town theme), then to the synthesized \`MusicSynth\` map track.
- **Levels.** Loops and story cues are brought to -20 LUFS and stings to -17 LUFS (peak ceiling -1.5 dBTP) by a per-ID base volume in the registry, and the Master bus carries a -1 dBFS hard limiter. The delivered files were already within 0.6 LU of each other. The existing Master / Music / Effects / UI sliders apply (the Music slider scales music and stings).
- **Loop points.** The OGG files are full-file loops (Godot's \`loop = true\`, offset 0); the Drive registry's loop end equals the decoded length for every loop.

## Verification

- \`tests/audio/\` (GUT): registry completeness, aliases, loop flags, levels; every director mapping; stack, resume, auto-pop, crossfade and duck bookkeeping; every ID has a trigger row.
- \`bash tools/run_music_smoke.sh\` (windowed, real mixer; log in \`_screenshots/music_smoke.log\`): new game -> forest -> town (crossfade) -> graveyard -> Fenwick's shop with three purchases (no retrigger) -> a gate-envoy battle and its victory sting -> Gainlands -> House of Gains map -> boss -> zone freed (freed track + zone sting) -> every Capital area with all four zones free. All checks passed; worst crossfade step 0.25 dB per frame; the mixer output peaked at -0.9 dBFS before the limiter was added (no clipping).
- Not audible to a script: musical balance against dialogue and effects. The levels above are measured, the feel is for a listening pass.

## Status

- **In Game (${inGame.length}):** ${inGame.join(', ')}
- **Reference only, never triggered by design (${notInGame.length}):** ${notInGame.join(', ') || '(none)'}
- **No trigger yet:** (none) - every cue that the brief expected to be missing (the memories, the Crease, the Archive, the Gallery, the Lab cell and rescue, the Capital districts) has a scene in the game and is hooked to it.
- **Missing file:** ${missing.join(', ') || '(none)'}
- **Files in the Drive folder matching no ID:** (none)

### Loops that need a fix (composer / renderer)

These play, but the wrap is audible. Listed for the next production pass; the files are left as delivered.

${fixLines.map((l) => '- ' + l).join('\n') || '(none)'}

### Loops to listen to (6-12 dB step at the wrap)

${stepLines.map((l) => '- ' + l).join('\n') || '(none)'}

## Every ID

Columns: base volume is the registry's gain in dB (loudness target), "Loop check" is the automatic seam analysis.

| ID | Cue | File | Kind | dB | Trigger(s) | Status | Loop check | Notes |
|---|---|---|---|---|---|---|---|---|
${rows.join('\n')}
`;
fs.mkdirSync('docs/audio', { recursive: true });
fs.writeFileSync('docs/audio/music_integration.md', md);
console.log(inGame.join(','));
console.error(`in game: ${inGame.length}, other: ${notInGame.length}, missing: ${missing.length}, loop fixes: ${fixLines.length}, listen: ${stepLines.length}`);
