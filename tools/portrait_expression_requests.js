// Overnight Oct 18, Part 5: the portrait expression images the dialogue presentation plan needs. Reads data/npcs/npcs.json, the
// portraits that exist in assets/art/portraits and the line counts of tools/dialogue_audit.js; writes
// docs/art/portrait_expression_requests.md and .csv (one row per missing image, batches of 20). Generates no art.
// Usage: node tools/portrait_expression_requests.js
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const root = path.join(__dirname, '..');
const audit = JSON.parse(execFileSync(process.execPath, [path.join(__dirname, 'dialogue_audit.js')], { encoding: 'utf8', maxBuffer: 1 << 24 }));
const npcs = JSON.parse(fs.readFileSync(path.join(root, 'data/npcs/npcs.json'), 'utf8'));
const byId = Object.fromEntries(npcs.map((n) => [n.id, n]));

// The standard set and the families of character-specific expressions that fill each slot (a tag like [happy] on Sable shows SABLE_PLEASED).
const FAMILIES = {
	HAPPY: ['happy', 'pleased', 'delighted', 'warm', 'proud', 'excited', 'cheering', 'grinning', 'approving', 'impressed', 'hopeful', 'relieved', 'laughing', 'smiling', 'hyped', 'showbiz', 'playful', 'serene', 'cackling', 'gracious', 'freed', 'selling'],
	SAD: ['sad', 'worried', 'tearful', 'exhausted', 'disappointed', 'frail', 'doubtful', 'soft', 'nostalgic', 'defeated', 'broken'],
	ANGRY: ['angry', 'stern', 'furious', 'enraged', 'outraged', 'indignant', 'disapproving', 'unimpressed', 'exasperated', 'barking', 'fierce', 'defiant', 'shouting', 'corrupted'],
	SURPRISED: ['surprised', 'oops', 'shocked', 'horrified', 'overwhelmed', 'panicked', 'sweating', 'nervous', 'slip-up (frightened)', 'awakened', 'revealed'],
	THINKING: ['thinking', 'confused', 'suspicious', 'scheming', 'conspiratorial', 'calculating', 'mysterious', 'sly', 'smug', 'fascinated', 'smarmy', 'denying', 'ominous', 'spinning', 'disguised'],
};
const STANDARD = ['HAPPY', 'SAD', 'ANGRY', 'SURPRISED', 'THINKING'];
const FACE = {
	HAPPY: 'a warm, open smile, eyes bright and slightly crinkled, shoulders relaxed',
	SAD: 'brows drawn up in the middle, eyes lowered and glistening, mouth turned down, shoulders a little slumped',
	ANGRY: 'brows pulled down hard, eyes narrowed, jaw set, mouth tight or bared, leaning slightly forward',
	SURPRISED: 'eyebrows shot up, eyes wide, mouth open in a small "oh", head pulled back a touch',
	THINKING: 'one brow raised, eyes glancing up and to the side, lips pressed, a hand or claw near the chin',
};
// Story leads and the most frequent speakers get the full set; vendors and quest givers three; bosses and hosts their own extras.
const HIGH = new Set(['NPC-PLAYER', 'NPC-ELDER', 'NPC-PRIMM', 'NPC-ELOWEN', 'NPC-WREN', 'NPC-GATEKEEPER', 'NPC-BELLOWS', 'NPC-FLEX', 'NPC-HOB', 'NPC-SPOTLESS', 'NPC-ESCOFFINA', 'NPC-COMPOSTELLA', 'NPC-AGNES', 'NPC-KESTREL']);
const SKIP = new Set(['V-FIGSLY', 'NPC-TOWNSFOLK', 'NPC-VILLAGER']); // black market (never touched); shared/strolling townsfolk speak in barks only
const MEDIUM_SET = ['HAPPY', 'ANGRY', 'SURPRISED'];
// The look the existing base portrait already shows (not requested again).
const BASE_IS = { 'NPC-CITIZEN': 'smiling', 'NPC-BRONSON': 'corrupted', 'NPC-PALLOR': 'corrupted', 'NPC-GRAVOIS': 'corrupted', 'NPC-MULLIGAN': 'corrupted', 'NPC-DOPPEL': 'disguised' };
const MEDIUM_IDS = new Set(['NPC-CITIZEN']);

function familyOf(expr) {
	for (const [slot, words] of Object.entries(FAMILIES)) if (words.includes(expr)) return slot;
	return '';
}

const rows = [];
const perCharacter = [];
for (const a of audit) {
	const n = byId[a.id];
	if (!n || SKIP.has(a.id)) continue;
	const have = new Set(a.have.filter((h) => h !== 'BASE').map((h) => h.toLowerCase()));
	const hasBase = a.have.includes('BASE');
	const planned = (n.expressions || []).map((e) => e.toLowerCase()).filter((e) => e !== 'neutral' && e !== BASE_IS[a.id]);
	const speaks = a.lines + a.barks;
	const tier = HIGH.has(a.id) ? 'High' : MEDIUM_IDS.has(a.id) || speaks >= 2 && /vendor|quest|leader|guard|master|host|resistance/i.test(n.role) ? 'Medium' : 'Low';
	const wanted = []; // [expression name, slot, why]
	const covered = new Set();
	for (const e of planned) {
		const slot = familyOf(e);
		if (slot) covered.add(slot);
		wanted.push([e, slot || 'EXTRA', 'character-specific (npcs.json)']);
	}
	const standard = tier === 'High' ? STANDARD : tier === 'Medium' ? MEDIUM_SET : [];
	for (const slot of standard) if (!covered.has(slot)) wanted.push([slot.toLowerCase(), slot, 'standard set']);
	const missing = wanted.filter(([e]) => !have.has(e.replace(/ \(.*\)/, '').replace(/ /g, '_')));
	perCharacter.push({ id: a.id, name: n.name, tier, speaks, have: a.have, planned, missing: missing.map((m) => m[0]) });
	for (const [e, slot, why] of missing) {
		const exprId = e.replace(/ \(.*\)/, '').replace(/[ -]/g, '_').toUpperCase();
		const shortId = a.id.replace(/^(NPC|V)-/, '');
		const face = FACE[slot] || `the "${e}" look the story calls for`;
		const identity = `${n.name.replace(/ \(.*?\)$/, '')} (${n.species || n.species_type || 'character'}): ${n.description}`;
		const desc = hasBase
			? `Use the attached current portrait ${n.portrait_id}.webp as the exact reference: same character, same face, species, colours, outfit, props, framing, scale and lighting. Change only the expression to ${e.toUpperCase()}: ${face}. ${identity}`
			: `Make this after the base portrait ${n.portrait_id} (docs/art/npc_image_requests.md) exists, and use it as the exact reference: same character, outfit, framing and lighting. Expression ${e.toUpperCase()}: ${face}. ${identity}`;
		rows.push({ asset: `PORT-${shortId}-${exprId}`, file: `${n.portrait_id}_${exprId}.png`, id: a.id, character: n.name, expression: exprId, slot, priority: tier, why, base: hasBase ? 'yes' : 'missing', lines: speaks, desc });
	}
}
const order = { High: 0, Medium: 1, Low: 2 };
rows.sort((x, y) => order[x.priority] - order[y.priority] || y.lines - x.lines || x.asset.localeCompare(y.asset));

const totals = { High: 0, Medium: 0, Low: 0 };
for (const r of rows) totals[r.priority] += 1;
const styleLock = 'Stylized fantasy character portrait for a visual-novel style dialogue screen, painterly digital art with clean bold shapes and soft cel-shaded lighting, matching a whimsical, expressive young-adult indie RPG card game. A single character shown from the waist up, centered, turned three-quarters toward the viewer, expressive face and clear readable silhouette, soft key light from the upper left. Same framing and scale for every character: top of the head about 8% from the top edge. Fully transparent background (PNG); if transparency isn\'t possible, use a plain flat light-gray background with nothing else. No text, no dialogue box, no frame, no border. 2:3 portrait, 1024x1536.';
const md = [];
md.push('# Portrait expression requests (Overnight Oct 18, Part 5)', '');
md.push(`Generated by \`node tools/portrait_expression_requests.js\` from data/npcs/npcs.json, the portraits in assets/art/portraits and the line counts of \`tools/dialogue_audit.js\`. Plan: docs/design/dialogue_presentation_plan.md. Nothing here is generated yet.`, '');
md.push(`**Totals: ${rows.length} images** - High ${totals.High}, Medium ${totals.Medium}, Low ${totals.Low}; ${rows.filter((r) => r.base === 'missing').length} of them wait for a base portrait that does not exist yet. ${Math.ceil(rows.length / 20)} batches of 20.`, '');
md.push('Save each file under the **File** name (the Portrait Image ID + `_` + expression) into the Drive `Approved_Characters` folder; "import portraits" copies it into the game, where a line tagged `[expression]` (or a family member, see the plan) picks it up. The Asset ID is the tracking name.', '');
md.push('**Portrait style lock** (paste first for every image, then attach the character\'s current portrait):', '', '> ' + styleLock, '');
md.push('| Character | Tier | Lines (approx) | Have today | Requested |', '|---|---|---:|---|---|');
for (const c of perCharacter.sort((x, y) => order[x.tier] - order[y.tier] || y.speaks - x.speaks)) {
	if (c.missing.length === 0 && c.tier === 'Low') continue;
	md.push(`| ${c.name} (\`${c.id}\`) | ${c.tier} | ${c.speaks} | ${c.have.join(', ') || 'no portrait'} | ${c.missing.join(', ') || '-'} |`);
}
md.push('');
for (let b = 0; b * 20 < rows.length; b += 1) {
	md.push(`## Batch ${b + 1}`, '');
	for (const r of rows.slice(b * 20, b * 20 + 20)) {
		md.push(`### ${r.asset} - ${r.character}, ${r.expression}`, '');
		md.push(`- File \`${r.file}\`; priority ${r.priority} (${r.why}${r.base === 'missing' ? '; base portrait still missing' : ''})`);
		md.push(`- Prompt: ${r.desc}`, '');
	}
}
fs.writeFileSync(path.join(root, 'docs/art/portrait_expression_requests.md'), md.join('\n') + '\n');
const esc = (s) => '"' + String(s).replace(/"/g, '""') + '"';
const csv = ['batch,asset_id,file,npc_id,character,expression,standard_slot,priority,base_portrait,approx_lines,description'];
rows.forEach((r, i) => csv.push([Math.floor(i / 20) + 1, r.asset, r.file, r.id, r.character, r.expression, r.slot, r.priority, r.base, r.lines, r.desc].map(esc).join(',')));
fs.writeFileSync(path.join(root, 'docs/art/portrait_expression_requests.csv'), csv.join('\n') + '\n');
console.log(JSON.stringify({ total: rows.length, ...totals, waiting_on_base: rows.filter((r) => r.base === 'missing').length, batches: Math.ceil(rows.length / 20) }));
