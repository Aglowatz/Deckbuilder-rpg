// Builds docs/audio/sfx_inventory.md from docs/audio/sfx_inventory.tsv (the table to paste into a Google Sheet) and the sound names the game uses
// today (app/audio_catalog.gd, the synthesized names of app/music_synth.gd, and how often each is called). Usage: node tools/sfx_doc.js
const fs = require('fs');
const path = require('path');
const tsv = fs.readFileSync('docs/audio/sfx_inventory.tsv', 'utf8').trim().split('\n').map((l) => l.split('\t'));
const head = tsv[0];
const rows = tsv.slice(1);
const count = (key, value) => rows.filter((r) => r[head.indexOf(key)] === value).length;
const esc = (s) => s.replace(/\|/g, '\|');
const catalog = fs.readFileSync('app/audio_catalog.gd', 'utf8');
const names = [...catalog.matchAll(/&"([a-z_]+)": \[([^\]]*)\]/g)].map((m) => [m[1], (m[2].match(/"[^"]+"/g) || []).length]);
const synth = [...fs.readFileSync('app/music_synth.gd', 'utf8').matchAll(/^\t\t&"([a-z_]+)":$/gm)].map((m) => m[1]);
function walk(dir, out) {
  for (const f of fs.readdirSync(dir)) {
    const p = path.join(dir, f);
    if (['addons', '_asset_library', '.godot', 'tests', 'tools'].includes(f)) continue;
    if (fs.statSync(p).isDirectory()) walk(p, out); else if (p.endsWith('.gd')) out.push(p);
  }
}
const files = [];
for (const d of ['app', 'core', 'ui', 'world']) walk(d, files);
const uses = {};
for (const f of files) for (const m of fs.readFileSync(f, 'utf8').matchAll(/Audio\.sfx\(&"([a-z_]+)"/g)) uses[m[1]] = (uses[m[1]] || 0) + 1;
const used = Object.keys(uses).sort((a, b) => uses[b] - uses[a]);
const md = `# Sound effects inventory

What the game plays today and what it lacks (music and stings are in \`music_integration.md\`). **To paste into a Google Sheet:** open
\`docs/audio/sfx_inventory.tsv\` (tab separated, one header row) and paste it into cell A1, or use Data > Split text to columns on this table.

- ${rows.length} rows: ${count('Current status', 'exists')} exist (Kenney CC0 packs), ${count('Current status', 'placeholder')} are placeholders (a stand-in sound is reused), ${count('Current status', 'missing')} are missing.
- Priority 1 = needed next (every playthrough hears it or it carries the feel of an area), 2 = clearly improves the game, 3 = polish.
- ID convention: \`SFX-<GROUP>-<NAME>\` for one-shots, \`AMB-<PLACE>\` for loops (ambience, weather, water). Keep the ID when a file is replaced, like the music IDs.
- Footsteps today use the grass sound everywhere; there is no ambience at all (the old synthesized music tracks carried a little wind, birds and mains hum; the
  new music has none of that), no weather, and no spatial water.
- Not covered: voices, and the card-specific sound of each of the 300+ cards (the table asks for a handful of categories first).

| ${head.join(' | ')} |
|${head.map(() => '---').join('|')}|
${rows.map((r) => '| ' + r.map(esc).join(' | ') + ' |').join('\n')}

## Sound names the game uses today

\`Audio.sfx(&"name")\` calls (count in code), from \`app/audio_catalog.gd\` (Kenney packs: UI audio, interface sounds, impact sounds, RPG audio, casino audio, music jingles; licenses in \`CREDITS.md\`)
and \`app/music_synth.gd\` (synthesized, original):

| Name | Calls | Source |
|---|---|---|
${used.map((n) => `| \`${n}\` | ${uses[n]} | ${names.find((x) => x[0] === n) ? `catalog (${names.find((x) => x[0] === n)[1]} file${names.find((x) => x[0] === n)[1] > 1 ? 's' : ''})` : synth.includes(n) ? 'synthesized' : 'not defined (silent)'} |`).join('\n')}

Names that route to a music sting when its file is present (\`AudioManager.STING_ALIASES\`): \`victory\` (STG-VICTORY), \`defeat\` (STG-DEFEAT), \`level_up\` (STG-LEVEL).
`;
fs.writeFileSync('docs/audio/sfx_inventory.md', md);
console.log(`rows ${rows.length}; names used ${used.length}; undefined: ${used.filter((n) => !names.find((x) => x[0] === n) && !synth.includes(n)).join(',') || 'none'}`);
