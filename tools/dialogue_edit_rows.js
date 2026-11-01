// Oct 31: how a row of a one-file edit CSV (tools/export_dialogue.js, the sheet's Dialogue Edit tab) becomes the line to apply.
// Columns: ID, Zone/Area, Speaker, When it's heard, Current line, New line, and optionally the critic pass's "Critic suggestion" and
// "Accept (Y)" (docs/dialogue/critic_suggestions_oct31.csv merged into the sheet).
// Which line wins, first match:
//   1. an explicit New line;
//   2. the critic suggestion, when Accept is Y or y (a Y is the designer's own later decision, so it also takes a critic fix of a line
//      they rewrote);
//   3. a rewrite typed over Current line (the designer's habit): Current line differs from the export snapshot of that row, other than
//      by a spreadsheet's re-encoding (curly quotes, a leading ' that Google Sheets swallows).
// Whenever Current line was typed over, the snapshot is the line the game still says.

const accepted = (value) => /^\s*y\s*$/i.test(value || '');

// The spreadsheet re-encodings that do not count as an edit.
function normalize(s) {
	return String(s ?? '').replace(/[‘’‛]/g, "'").replace(/[“”‟]/g, '"').replace(/…/g, '...')
		.replace(/\s*[—–]\s*/g, ' - ').replace(/ /g, ' ').replace(/ {2,}/g, ' ').trim();
}
const sameLine = (a, b) => {
	const x = normalize(a), y = normalize(b);
	return x === y || (y.startsWith("'") && x === y.slice(1)) || (x.startsWith("'") && y === x.slice(1));
};

// True when the row's Current line is a rewrite typed over the exported line (needs the snapshot).
function typedOver(r, snapshot) {
	const snap = snapshot ? snapshot[r.ID] : undefined;
	return snap !== undefined && !sameLine(r['Current line'] ?? '', snap);
}

// One sheet row -> { id, speaker, key, current_text, new_text, from_critic, typed_over, own_line, snapshot, area }.
function editRow(r, snapshot) {
	const own = r['New line'] ?? '';
	const critic = r['Critic suggestion'] ?? '';
	const typed = typedOver(r, snapshot);
	const fromCritic = !own.trim() && accepted(r['Accept (Y)']) && !!critic.trim();
	const over = !own.trim() && !fromCritic && typed;
	return {
		id: r.ID,
		speaker: r.Speaker,
		key: (r.ID || '').split('::')[1] || '',
		current_text: typed ? snapshot[r.ID] : r['Current line'] ?? '',
		new_text: own.trim() ? own : fromCritic ? critic : over ? r['Current line'] : '',
		from_critic: fromCritic,
		typed_over: over,
		// The designer's typed-over line, when there is one (a critic fix of it is checked against it).
		designer_text: typed ? r['Current line'] : undefined,
		// The designer's own line (New line, or typed over Current line), as opposed to an accepted critic suggestion.
		own_line: !!own.trim() || over,
		snapshot: snapshot ? snapshot[r.ID] : undefined,
		area: (r['Zone/Area'] || '').split(' / ')[0],
	};
}

module.exports = { editRow, accepted, typedOver, sameLine };
