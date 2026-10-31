// Oct 31: how a row of a one-file edit CSV (tools/export_dialogue.js, the sheet's Dialogue Edit tab) becomes the line to apply.
// Columns: ID, Zone/Area, Speaker, When it's heard, Current line, New line, and optionally the critic pass's "Critic suggestion" and
// "Accept (Y)" (docs/dialogue/critic_suggestions_oct31.csv merged into the sheet). An explicit New line always wins; a row with an empty
// New line takes the critic suggestion only when Accept is Y or y.

const accepted = (value) => /^\s*y\s*$/i.test(value || '');

// One sheet row -> { id, speaker, key, current_text, new_text, from_critic, snapshot, area }.
function editRow(r, snapshot) {
	const own = r['New line'] ?? '';
	const critic = r['Critic suggestion'] ?? '';
	const fromCritic = !own.trim() && accepted(r['Accept (Y)']) && !!critic.trim();
	return {
		id: r.ID,
		speaker: r.Speaker,
		key: (r.ID || '').split('::')[1] || '',
		current_text: r['Current line'] ?? '',
		new_text: fromCritic ? critic : own,
		from_critic: fromCritic,
		snapshot: snapshot ? snapshot[r.ID] : undefined,
		area: (r['Zone/Area'] || '').split(' / ')[0],
	};
}

module.exports = { editRow, accepted };
