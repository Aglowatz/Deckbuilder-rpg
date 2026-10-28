// Oct 27: the dialogue line ids shared by tools/export_dialogue.js (writes the edit CSV) and tools/apply_dialogue_pass.js (applies it).
// An id is <file>::<key>::<index>: one line of a key's list of lines. The key's form depends on the file:
//   data/story/*.tres                  the `lines`/`texts` dictionary key, or an `*_lines` export (index = position in the array)
//   data/npcs/npcs.json                <NPC id>.barks
//   data/story/old_well_story.json     beats.<key>.<n> (index = line of beat n) or text.<key>
//   data/dungeons/dungeon_content.json <text key> (its `text` dictionary), or a JSON path with '/' (dungeons/D-HOG/events/5/body)
//   other JSON files                   a JSON path with '/': scenes/<scene>/steps/<n> (index = position in the step), <boss>/line,
//                                      <foe>/<trigger>/banner; a single string has index 0
//   core/**/*.gd                       <function or const name> (index = n-th player-facing string literal in it, see gdProse)
//   data/loading/*.txt                 lineN (the file's line N)
// locate(id) returns every line of the id's key in order ({start, end, value} spans in the file) and which one the id names.
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');

// ---------- CSV ----------
function parseCsv(t) {
	t = t.replace(/^﻿/, '');
	const rows = []; let row = [], f = '', q = false;
	for (let i = 0; i < t.length; i++) {
		const ch = t[i];
		if (q) { if (ch === '"') { if (t[i + 1] === '"') { f += '"'; i++; } else q = false; } else f += ch; }
		else if (ch === '"') q = true;
		else if (ch === ',') { row.push(f); f = ''; }
		else if (ch === '\n' || ch === '\r') { if (ch === '\r' && t[i + 1] === '\n') i++; row.push(f); rows.push(row); row = []; f = ''; }
		else f += ch;
	}
	if (f || row.length) { row.push(f); rows.push(row); }
	const h = rows.shift();
	return rows.filter((r) => r.length > 1).map((r) => Object.fromEntries(h.map((k, i) => [k, r[i] ?? ''])));
}
const csvq = (s) => `"${String(s).replace(/"/g, '""')}"`;

// ---------- string literals ----------
// String literals of the array starting at text[open] ('['): [{start, end, value}] (start/end include the quotes).
function arrayStrings(text, open) {
	const out = [];
	let i = open + 1;
	while (i < text.length) {
		const ch = text[i];
		if (ch === ']') return out;
		if (ch === '"') {
			let j = i + 1;
			while (text[j] !== '"') j += text[j] === '\\' ? 2 : 1;
			out.push({ start: i, end: j + 1, value: JSON.parse(text.slice(i, j + 1)) });
			i = j + 1;
		} else i++;
	}
	throw new Error('unterminated array');
}

// Position-tracking JSON parse: every string value with its path and span.
function jsonSpans(text) {
	const spans = [];
	let i = 0;
	const ws = () => { while (/\s/.test(text[i])) i++; };
	const str = () => { const s = i; i++; while (text[i] !== '"') i += text[i] === '\\' ? 2 : 1; i++; return { start: s, end: i, value: JSON.parse(text.slice(s, i)) }; };
	function value(p) {
		ws();
		const ch = text[i];
		if (ch === '{') {
			i++; ws();
			if (text[i] === '}') { i++; return; }
			for (;;) { ws(); const k = str().value; ws(); i++; value(p.concat([k])); ws(); if (text[i] === ',') { i++; continue; } i++; return; }
		}
		if (ch === '[') {
			i++; ws();
			if (text[i] === ']') { i++; return; }
			for (let n = 0; ; n++) { value(p.concat([n])); ws(); if (text[i] === ',') { i++; continue; } i++; return; }
		}
		if (ch === '"') { const s = str(); spans.push({ path: p, ...s }); return; }
		while (i < text.length && !/[,\]}\s]/.test(text[i])) i++;
	}
	value([]);
	return spans;
}

// GDScript: every string literal outside comments, with the function or const it sits in and what precedes it on its line.
function gdUnescape(s) {
	return s.replace(/\\(u[0-9a-fA-F]{4}|.)/g, (m, c) => (c[0] === 'u' && c.length === 5 ? String.fromCharCode(parseInt(c.slice(1), 16)) : ({ n: '\n', t: '\t', r: '\r' }[c] ?? c)));
}
function gdLiterals(text) {
	const out = [];
	let scope = '(top)', lineStart = 0;
	for (let i = 0; i < text.length; i++) {
		const ch = text[i];
		if (i === lineStart) {
			const m = text.slice(i, i + 200).match(/^(?:static\s+)?func\s+(\w+)|^const\s+(\w+)|^var\s+(\w+)/);
			if (m) scope = m[1] || m[2] || m[3];
		}
		if (ch === '\n') { lineStart = i + 1; continue; }
		if (ch === '#') { while (i + 1 < text.length && text[i + 1] !== '\n') i++; continue; }
		if (ch === '"' || ch === "'") {
			let j = i + 1;
			while (text[j] !== ch) j += text[j] === '\\' ? 2 : 1;
			out.push({ start: i, end: j + 1, value: gdUnescape(text.slice(i + 1, j)), scope, before: text.slice(lineStart, i) });
			i = j;
		}
	}
	return out;
}
// The literals a player reads: prose (a space and a lower-case letter), or a quest title. Name constants are left out (renaming one breaks
// lookups), and so are bare NPC names passed as arguments.
const GD_SKIP_SCOPES = ['MAREN', 'BRANNOCH', 'VENDORS'];
let npcNames = null;
function gdProse(lit) {
	if (!npcNames) npcNames = new Set(JSON.parse(fs.readFileSync(path.join(root, 'data/npcs/npcs.json'), 'utf8')).map((n) => n.name));
	if (GD_SKIP_SCOPES.includes(lit.scope) || npcNames.has(lit.value)) return false;
	if (/\.title\s*=\s*$|"title":\s*$/.test(lit.before)) return lit.value.length > 0;
	return / /.test(lit.value) && /[a-z]/.test(lit.value) && !/^[a-z_]+\s*:/.test(lit.value);
}

// ---------- file cache ----------
const fileCache = new Map();
const spanCache = new Map();
function fileText(file) {
	if (!fileCache.has(file)) fileCache.set(file, fs.readFileSync(path.join(root, file), 'utf8'));
	return fileCache.get(file);
}
function spansOf(file) {
	if (!spanCache.has(file)) spanCache.set(file, file.endsWith('.gd') ? gdLiterals(fileText(file)) : jsonSpans(fileText(file)));
	return spanCache.get(file);
}
function setFileText(file, text) {
	fs.writeFileSync(path.join(root, file), text);
	fileCache.set(file, text);
	spanCache.delete(file);
}
const same = (a, b) => a.length === b.length && a.every((x, k) => x === b[k]);

// ---------- locating a line ----------
// The lines of an id's key, in order, plus which one the id names: {file, kind, slots: [{start, end, value}], index}.
function locate(id) {
	const parts = id.split('::');
	const file = parts[0], key = parts[1], index = Number(parts[2]);
	const text = fileText(file);
	if (file.endsWith('.tres')) {
		const lines = text.split('\n');
		let offset = 0;
		for (const line of lines) {
			if (line.startsWith(`"${key}":`) || line.startsWith(`${key} = Array[String](`)) {
				const at = line.startsWith('"') ? line.slice(key.length + 3).search(/\S/) + key.length + 3 : line.indexOf('([') + 1;
				if (line[at] === '"') {
					const lit = arrayStrings('[' + line.slice(at) + ']', 0)[0];
					return { file, kind: 'tres', slots: [{ start: offset + at, end: offset + at + lit.end - 1, value: lit.value }], index: 0 };
				}
				if (line[at] !== '[') return null;
				return { file, kind: 'tres', slots: arrayStrings(text, offset + at), index };
			}
			offset += line.length + 1;
		}
		return null;
	}
	if (file.endsWith('.txt')) {
		// Loading tips: lineN is the file's line N (1-based); the slots are every tip line (kind | text).
		const slots = [];
		let offset = 0, n = 0, wanted = -1;
		for (const line of text.split('\n')) {
			n++;
			const m = line.match(/^(\s*(?:@\S+\s+)?[a-z]+\s*\|\s*)(.*?)(\r?)$/);
			if (m && !line.trim().startsWith('#')) {
				if (n === Number(key.replace('line', ''))) wanted = slots.length;
				slots.push({ start: offset + m[1].length, end: offset + m[1].length + m[2].length, value: m[2] });
			}
			offset += line.length + 1;
		}
		return { file, kind: 'txt', slots, index: wanted };
	}
	if (file.endsWith('.gd')) {
		const slots = spansOf(file).filter((l) => l.scope === key && gdProse(l));
		return slots.length ? { file, kind: 'gd', slots, index } : null;
	}
	const spans = spansOf(file);
	let prefix = null;
	if (key.includes('/')) {
		const want = key.split('/');
		const found = spans.filter((s) => s.path.length >= want.length && s.path.length <= want.length + 1 && want.every((seg, k) => String(s.path[k]) === seg));
		if (!found.length) return null;
		const single = found.length === 1 && found[0].path.length === want.length;
		return { file, kind: 'json', slots: single ? found : found.filter((s) => s.path.length === want.length + 1), index: single ? 0 : index, byPosition: !single };
	}
	if (file.endsWith('npcs.json')) {
		const m = key.match(/^(.*)\.(barks)$/);
		const n = m && spans.find((s) => s.path.length === 2 && s.path[1] === 'id' && s.value === m[1]);
		if (!n) return null;
		prefix = [n.path[0], 'barks'];
	} else if (file.endsWith('old_well_story.json')) {
		let m = key.match(/^beats\.(.*)\.(\d+)$/);
		if (m) prefix = ['beats', m[1], Number(m[2]), 'lines'];
		else if ((m = key.match(/^text\.(.*)$/))) prefix = ['text', m[1]];
	} else {
		prefix = ['text', key];
	}
	if (!prefix) return null;
	const slots = spans.filter((s) => s.path.length >= prefix.length && same(s.path.slice(0, prefix.length), prefix) && s.path.length <= prefix.length + 1);
	if (slots.length === 0) return null;
	return { file, kind: 'json', slots, index: slots.length === 1 && slots[0].path.length === prefix.length ? 0 : index };
}

// The slot an id names, for a JSON path key whose index is the array position (a story scene step's [speaker, line, line...]).
function namedSlot(loc) {
	if (!loc) return null;
	if (loc.byPosition) return loc.slots.find((s) => s.path[s.path.length - 1] === loc.index) || null;
	return loc.slots[loc.index] || null;
}

function encode(kind, text) {
	if (kind === 'txt') return text;
	return JSON.stringify(text); // also Godot's .tres and GDScript string escaping for one plain line
}

module.exports = { root, parseCsv, csvq, arrayStrings, jsonSpans, gdLiterals, gdProse, fileText, spansOf, setFileText, locate, namedSlot, encode, same };
