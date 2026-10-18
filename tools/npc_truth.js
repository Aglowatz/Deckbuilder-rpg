// Overnight Oct 17, Part 11: builds the one NPC source of truth.
//   node tools/npc_truth.js
// Reads data/npcs/npcs.json (the sheet import), data/source/npc_list.csv (the sheet export), data/npcs/npc_game_map.json (extra NPCs),
// data/vendors/vendor_screens.json, tools/npc_truth_input.json (barks, descriptions, missing species) and _logs/npc_dump.json (quest
// givers resolved by the game: Godot --headless --path . -s res://tools/npc_dump_run.gd), checks the portrait and world-sprite files, and
// writes back data/npcs/npcs.json (every NPC with id, name, location, role, species, description, personality, speech style, sample line,
// barks, quest/vendor links and art status), docs/design/npc_registry.csv (the sheet's column order, extra columns after it) and
// docs/art/npc_image_requests.md (ChatGPT-ready prompts in batches of 20 for every NPC whose art is missing or does not match).
const fs = require('fs');
const path = require('path');
const root = path.join(__dirname, '..');
const read = (p) => fs.readFileSync(path.join(root, p), 'utf8');

function parseCsv(text) {
	const rows = []; let row = [], f = '', q = false;
	for (let i = 0; i < text.length; i++) {
		const c = text[i];
		if (q) { if (c === '"') { if (text[i + 1] === '"') { f += '"'; i++; } else q = false; } else f += c; }
		else if (c === '"') q = true; else if (c === ',') { row.push(f); f = ''; } else if (c === '\n') { row.push(f); rows.push(row); row = []; f = ''; } else if (c !== '\r') f += c;
	}
	if (f.length || row.length) { row.push(f); rows.push(row); }
	return rows;
}
const csvCell = (v) => { const s = String(v ?? ''); return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s; };
const firstSentence = (s, max) => { const t = String(s || '').replace(/\s+/g, ' ').trim(); const m = t.match(/^(.+?[.!?])(\s|$)/); let r = m ? m[1] : t; if (r.length > max) r = r.slice(0, max - 3).replace(/\s+\S*$/, '') + '...'; return r; };

const npcs = JSON.parse(read('data/npcs/npcs.json'));
const map = JSON.parse(read('data/npcs/npc_game_map.json'));
const input = JSON.parse(read('tools/npc_truth_input.json'));
const vendors = JSON.parse(read('data/vendors/vendor_screens.json'));
const dumpPath = path.join(root, '_logs/npc_dump.json');
const dump = fs.existsSync(dumpPath) ? JSON.parse(fs.readFileSync(dumpPath, 'utf8')) : { quests: [] };
const rows = parseCsv(read('data/source/npc_list.csv'));
const headerIndex = rows.findIndex((r) => r[0] === 'NPC ID');
const header = rows[headerIndex];
const sheet = {};
for (const r of rows.slice(headerIndex + 1)) if (r[0] && /^(NPC|V)-/.test(r[0])) sheet[r[0]] = r;
const col = (name) => header.indexOf(name);

// Extra NPCs the game adds on top of the sheet.
for (const extra of map.extra_npcs || []) if (!npcs.some((n) => n.id === extra.id)) npcs.push(Object.assign({ art_status: '', expressions: [], portrait_id: extra.id, sprite_status: '' }, extra));

const spriteDir = path.join(root, 'assets/art/world_test/sprites');
const aliases = { 'NPC-ROLLO': 'GUS', 'NPC-DOPPEL': 'ESCOFFINA', 'NPC-TOWNSFOLK': 'CITIZEN' };
const human = (s) => /^human/i.test(s || '');
for (const npc of npcs) {
	const row = sheet[npc.id] || [];
	const get = (name) => (col(name) >= 0 ? row[col(name)] || '' : '');
	npc.species_type = npc.species_type || input.species[npc.id] || '';
	npc.personality = get('Personality & Interesting Traits') || npc.personality || '';
	npc.speech_style = get('Voice & Speech Style') || npc.speech_style || '';
	npc.game_function = get('Game Function') || npc.game_function || '';
	npc.description = (input.descriptions || {})[npc.id] || npc.description || firstSentence(npc.personality || npc.role, 140);
	npc.barks = (input.barks || {})[npc.id] || npc.barks || [];
	npc.sample_line = npc.barks.length ? npc.barks[0] : (npc.sample_line || firstSentence(npc.speech_style, 120));
	npc.quest_links = dump.quests.filter((q) => q.giver === npc.id || q.turn_in === npc.id).map((q) => q.title);
	npc.vendor_links = Object.entries(vendors).filter(([, v]) => v.portrait_id === npc.portrait_id).map(([id, v]) => `${id}: ${firstSentence(v.goods, 90)}`);
	const portraitFile = path.join(root, 'assets/art/portraits', (npc.portrait_id || npc.id) + '.webp');
	npc.portrait_status = fs.existsSync(portraitFile) ? 'OK' : 'missing';
	const key = aliases[npc.id] || npc.id.slice(npc.id.indexOf('-') + 1);
	const hasSprite = fs.existsSync(path.join(spriteDir, key));
	const needsSprite = !/^n\/a$/i.test(npc.sprite_status || '') && !/^(Boss|Final boss|Late)/i.test(npc.role || '');
	npc.world_sprite_status = hasSprite ? 'OK' : (needsSprite ? 'missing' : 'n/a');
	// A missing world sprite means a stand-in 3D humanoid: a mismatch when the portrait is not human.
	if (npc.portrait_status === 'missing') npc.art_check = 'missing';
	else if (npc.world_sprite_status === 'missing' && npc.species_type && !human(npc.species_type)) npc.art_check = 'mismatch';
	else if (npc.world_sprite_status === 'missing') npc.art_check = 'missing';
	else npc.art_check = 'OK';
}

// npcs.json: one object per line group, keys in a fixed order (hand-formatted style, tabs).
const order = ['id', 'name', 'location', 'role', 'species', 'species_type', 'description', 'personality', 'speech_style', 'sample_line', 'barks', 'game_function',
	'quest_links', 'vendor_links', 'portrait_id', 'portrait_status', 'expressions', 'art_status', 'portrait_action', 'sprite_set', 'sprite_status', 'world_sprite_status', 'art_check', 'rel_height', 'notes'];
const ordered = npcs.map((n) => { const o = {}; for (const k of order) if (k in n) o[k] = n[k]; for (const k of Object.keys(n)) if (!(k in o)) o[k] = n[k]; return o; });
fs.writeFileSync(path.join(root, 'data/npcs/npcs.json'), JSON.stringify(ordered, null, '\t') + '\n');

// docs/design/npc_registry.csv: the sheet's columns in its order, then the new ones.
const extra = ['Short Description', 'Sample Line', 'Barks', 'Quest Links', 'Vendor Links', 'Portrait File', 'World Sprite', 'Art Check'];
const out = [header.concat(extra).map(csvCell).join(',')];
for (const npc of ordered) {
	const row = (sheet[npc.id] || []).slice(0, header.length);
	while (row.length < header.length) row.push('');
	row[col('NPC ID')] = npc.id; row[col('Name')] = row[col('Name')] || npc.name; row[col('Role / Type')] = row[col('Role / Type')] || npc.role;
	row[col('Location')] = row[col('Location')] || npc.location; row[col('Personality & Interesting Traits')] = npc.personality;
	row[col('Voice & Speech Style')] = npc.speech_style; row[col('Portrait Image ID')] = row[col('Portrait Image ID')] || npc.portrait_id;
	row[col('Species / Type (final)')] = npc.species_type;
	out.push(row.concat([npc.description, npc.sample_line, npc.barks.join(' / '), npc.quest_links.join('; '), npc.vendor_links.join('; '), npc.portrait_status, npc.world_sprite_status, npc.art_check]).map(csvCell).join(','));
}
fs.writeFileSync(path.join(root, 'docs/design/npc_registry.csv'), out.join('\n') + '\n');

// docs/art/npc_image_requests.md
const lockRow = rows.find((r) => r[0] === 'PORTRAIT STYLE LOCK');
const portraitLock = lockRow ? lockRow[1].replace(/^Paste before every Portrait Art Direction: /, '').replace(/^"|"$/g, '') : '';
const spriteLock = 'Painted 2.5D storybook game sprite matching the existing Crosspath townsfolk: clean bold shapes, soft cel-shaded painting, warm rich colours, a soft dark outline, lit from the upper left. One full-body character standing on nothing, feet at the bottom edge, transparent background (PNG), no shadow on the ground, no text. Four frames on one sheet, left to right: FRONT_IDLE (facing the viewer), FRONT_TALK (same pose, mouth open, one hand gesturing), SIDE_IDLE (facing right), BACK_IDLE (facing away). Same scale and baseline in every frame. The character must match the dialogue portrait exactly (species, colours, outfit, props).';
const needs = ordered.filter((n) => n.art_check !== 'OK' && n.id !== 'NPC-PLAYER');
const lines = ['# NPC image requests', '', `Generated by \`node tools/npc_truth.js\` from \`data/npcs/npcs.json\` (Overnight Oct 17, Part 11). ${needs.length} NPCs need new or fixed art: a missing portrait, a missing world sprite, or a world stand-in that does not match the portrait (a human 3D model for an animal, undead or creature). Batches of 20, ready to paste into ChatGPT. Save files with the IDs given; "import portraits" / the sprite importer pick them up.`, '',
	'**Portrait style lock** (paste first for every portrait):', '', '> ' + portraitLock, '', '**World sprite style lock** (paste first for every sprite sheet):', '', '> ' + spriteLock, ''];
for (let b = 0; b < needs.length; b += 20) {
	lines.push(`## Batch ${b / 20 + 1}`, '');
	for (const n of needs.slice(b, b + 20)) {
		const row = sheet[n.id] || [];
		const direction = (col('Portrait Art Direction (subject; paste the Portrait Style Lock first)') >= 0 ? row[col('Portrait Art Direction (subject; paste the Portrait Style Lock first)')] : '') || `${n.name}, ${n.species_type || 'human'}, ${n.role}. ${n.description}`;
		const key = (aliases[n.id] || n.id.slice(n.id.indexOf('-') + 1));
		lines.push(`### ${n.id} - ${n.name}`, '', `- Species: ${n.species_type || '(unset)'}; role: ${n.role}; status: portrait ${n.portrait_status}, world sprite ${n.world_sprite_status} (${n.art_check})`);
		if (n.portrait_status !== 'OK') lines.push(`- **Portrait** \`${n.portrait_id || n.id}.png\`: ${direction}`);
		if (n.world_sprite_status !== 'OK') lines.push(`- **World sprite sheet** \`SPR-${key}.png\`: ${direction} ${n.portrait_status === 'OK' ? 'Match the approved portrait ' + (n.portrait_id || n.id) + ' exactly.' : 'Make it together with the portrait so the two match.'}`);
		lines.push('');
	}
}
fs.writeFileSync(path.join(root, 'docs/art/npc_image_requests.md'), lines.join('\n'));
const count = (k) => ordered.filter((n) => n.art_check === k).length;
const species = { human: ordered.filter((n) => human(n.species_type)).length, animal: ordered.filter((n) => /^animal/i.test(n.species_type)).length, other: ordered.filter((n) => n.species_type && !human(n.species_type) && !/^animal/i.test(n.species_type)).length };
console.log(`npc_truth: ${ordered.length} NPCs; art OK ${count('OK')}, missing ${count('missing')}, mismatch ${count('mismatch')}; species ${JSON.stringify(species)}; ${needs.length} image requests`);
