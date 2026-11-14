// Fable Nov 14 (owner's playtest list, Part 1): the story fixes as importer rows.
//   node docs/dialogue/fable_nov14_rows.js            writes docs/dialogue/fable_nov14.csv + fable_nov14_ids.txt from a fresh export
//   node tools/apply_dialogue_pass.js --csv=docs/dialogue/fable_nov14.csv [--apply]
//   node tools/apply_dialogue_pass.js --revert=docs/dialogue/fable_nov14_ids.txt
// Facts (docs/prompts/fable_nov14_owner_list.md): the cell has bars, not glass; Maren worked at the castle, studied the Paths and tutored
// the royal children; she never made the bars or blew glass; she is going blind; after the second Path she half-suspects and denies it;
// after the fourth she no longer says she knew all along. The Old Service Tunnels' boss is Enforcer Sergeant Scuff, sent by Spotless.
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const { root, parseCsv, csvq } = require('../../tools/dialogue_ids');

const I = 'data/story/intro_story.tres::';
const C = 'data/story/capital_story.tres::';
const S = 'data/story/story_scenes.json::';
const D = 'data/dungeons/dungeon_content.json::';
const B = 'data/encounters/boss_intros.json::Enforcer Sergeant Scuff/';
const E = 'data/encounters/encounter_scripts.json::Enforcer Sergeant Scuff/';

const ROWS = {
	// 1.1 The Old Service Tunnels: Enforcer Sergeant Scuff
	[D + 'dungeon.dg_s_cap_boss.before::0']: "A grate lets in light from a perfect city. Under it a young Enforcer sergeant stands to attention in a puddle, reading his orders off a card, in the only muddy boots the regime owns.",
	[D + 'dungeon.dg_s_cap_boss.before::1']: "'HALT, please. Sergeant Scuff, Enforcers. Captain Spotless sent me to check the service tunnels in case anyone tried to sneak into the city this way, and I'm sorry to report that someone has. It's you.'",
	[D + 'dungeon.dg_s_cap_boss.after::0']: "Sergeant Scuff sits down on a barrel and takes off his helmet. 'My gran laid pipe down here,' he says. 'She said these tunnels used to be full of people. I put that in a report once, and the Captain had me write it again.'",
	[D + 'dungeon.dg_s_cap_boss.after::1']: "'All four Paths, shoulder to shoulder, and nobody measuring anybody. I'll tell the Captain I found nothing down here, which is what he says there is. Go on. The grate isn't locked.'",
	[B + 'title::0']: "Sub-Inspector of Tunnels That Do Not Exist",
	[B + 'line::0']: "HALT, please. Captain Spotless says nobody is to be down here, and that includes me, so let us be quick about it.",
	[E + '0/text::0']: "On his 5th turn Scuff holds an inspection, just as the Captain taught him: your strongest ready unit stands to attention (exhausted) and cannot block.",
	[E + '0/warn::0']: "Next turn: Scuff holds an inspection (your strongest unit cannot block).",
	[E + '0/line::0']: "INSPECTION! The Captain wants heights, he wants smudges, and he wants every smile at the regulation angle!",
	[E + '1/text::0']: "Near the end Scuff notices the mud on his own boots: his units get -1/-0 while he scrubs.",
	[E + '1/line::0']: "Mud. On the boots. The Captain will see it from all the way up there, I know he will.",
	[E + '1/banner::0']: "Scuff scrubs his boots: his units get -1/-0.",

	// 1.2 Fragment 2: bars, not glass
	[I + 'memory.2.fragment::1']: "There are bars on every side of me, and behind the bars there are faces in white coats, taking notes.",
	[I + 'memory.2.after::0']: "Bars, and white coats, and 'again.' So that is where they had you, all those years.",
	[I + 'memory.3.after::0']: "A man in white and gold, who knelt and then stood up. And before that, those rooms of yours with bars on every side.",
	[C + 'cutscene.primm_end.3::1']: "You took my mother and father. Then you kept me behind bars for ten years, and every morning someone said 'again'. I remember that word better than I remember their faces.",
	[C + 'cutscene.primm_end.3.rushed::1']: "You took my mother and father. Then you kept me behind bars for ten years, and every morning someone said 'again'. I remember that word better than I remember their faces.",

	// 1.3 Elder Maren: her eyes
	[I + 'cave_mouth.maren::1']: "Come closer, dearie; my eyes aren't what they were. ...Well, look at the state of you. I told her I'd help whoever she sent along, but I never agreed to take in a half-drowned stray who can barely stand.",
	[I + 'town.elder.stage.0::0']: "I still can't make you out, dearie, and that's only partly my eyes, which see as far as a pie and not much further. But you need feeding a good deal more than you need questioning, so sit yourself down.",
	[I + 'memory.1.intro::0']: "Even with my eyes I can see you've gone as pale as flour. Sit down, sit down. Something has come back to you, hasn't it?",
	// after the second Path: she half-suspects, nearly says it, and talks herself out of it
	[I + 'memory.2.after::1']: "The way you said that... I taught the royal children at the castle once, and there was a boy who asked his questions just that way. For a moment I thought... No. That boy is ten years dead, and I'm a foolish old tortoise.",
	[I + 'memory.2.after::2']: "You've earned some truth in return: I'm not only an old tortoise who bakes. There's a resistance in this kingdom, and I'm its contact here in {town}. A woman called Wren leads it, from a hideout inside the Capital itself.",
	[I + 'town.elder.stage.2::0']: "Somebody on the square says you've a look of the old court about you. 'With my eyes I couldn't say,' I told them, 'but I know a damp young man with good posture when one drips on my floor.' Don't look so startled, dearie.",
	// after the third Path: the castle, the Paths, the children she taught; no glass
	[I + 'memory.3.after::1']: "I knew that throne room, dearie. I worked at the castle once, studying the Paths, and of an afternoon I taught the royal children their letters. I began that study for the best of reasons, the way people generally do.",
	[I + 'memory.3.after::2']: "{villain} took my study and built those cells out of it. I never forged a bar of them, but every one stands on something I wrote down. The best student I ever had stayed on to run the place for him, and I ran.",
	[I + 'memory.3.after::3']: "I have been hiding here ever since with my hands in pie dough, where nobody would think to ask what those hands used to write.",
	// after the fourth Path: no Warden, no "I knew all along"
	[I + 'memory.4.after::0']: "{prince}. {prince} {royal_house}. I taught a boy by that name his letters. The first day he hid behind his mother's cloak, and he asked me why tortoises carry their houses about with them.",
	[I + 'memory.4.after::2']: "And you have sat at my table all these weeks, and I didn't know you. My eyes have been going for years, and I had been told that boy was dead, and whenever my heart said otherwise I told it to hush.",
	[I + 'memory.4.after::3']: "Four signs in a ring, the same as the ones carved on this stick of mine. The Queen gave it to me the day I began teaching you, and I have leaned on it for ten years and never told a soul why.",
	[I + 'memory.4.after::4']: "And my study, my life's work, was the thing they used on that boy. It was used on you, and I ran, and I never once asked who was behind those bars. Forgive me, if you ever can. I would understand it if you couldn't.",
	[I + 'memory.4.reply::1']: "You ran, Maren. You also gave me a bed and a pie when you still thought I might be a spy. I know which of those I'm keeping.",
	[I + 'memory.4.after_known::1']: "I should have known you myself. I taught you your letters. But my eyes have been going for years, and I had been told that boy was dead, and I was too frightened to hope I'd been told wrong.",
	[I + 'memory.4.after_known::2']: "So hear it from somebody who held your hand at court: you are {prince_full}, and I am so very sorry for what was done to you with the things I wrote.",
	// others who mention her past
	[S + 'scenes/maren_after_capture/steps/1::2']: "I knew whose daughter she was the day she sent you through my cave. Her father was the best student I ever had, and I held what he became against her for far too long. I was wrong to do it.",
	[S + 'scenes/maren_after_capture/steps/4::1']: "Back where she came from, I expect: somewhere with bars on the doors and no windows. That's one door I can't open for you, dearie. Not yet.",
	[C + 'dungeon.pc_ward.before::3']: "The oldest note, at the far end, is in a different hand: careful, rounded, familiar. 'Year 1. I am told the subject is a child, and that he asks for his mother. A child is not a specimen. I will not stay to see it. M.'",
};

const OUT = path.resolve(root, 'docs/dialogue/fable_nov14.csv');
const BASE = path.resolve(root, '_logs/nov14/base_rows.csv');
fs.mkdirSync(path.dirname(BASE), { recursive: true });
execFileSync('node', [path.resolve(root, 'tools/export_dialogue.js'), '--out=' + BASE], { stdio: 'ignore' });
const base = parseCsv(fs.readFileSync(BASE, 'utf8'));
const byId = new Map(base.map((r) => [r.ID, r]));
const ledgerPath = OUT.replace(/\.csv$/, '') + '/applied_ledger.json';
const ledger = fs.existsSync(ledgerPath) ? JSON.parse(fs.readFileSync(ledgerPath, 'utf8')) : {};
const head = ['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'];
const out = [head.map(csvq).join(',')];
const ids = [];
for (const [id, text] of Object.entries(ROWS)) {
	const row = byId.get(id);
	if (!row) { console.error('NO SUCH ID', id); process.exitCode = 1; continue; }
	if (text.length > 240) { console.error('TOO LONG', text.length, id); process.exitCode = 1; }
	out.push([id, row['Zone/Area'], row.Speaker, row["When it's heard"], row['Current line'], text].map(csvq).join(','));
	ids.push(id);
}
fs.writeFileSync(OUT, '﻿' + out.join('\r\n') + '\r\n');
fs.writeFileSync(OUT.replace(/\.csv$/, '_ids.txt'), ids.join('\n') + '\n');
console.log(ids.length, 'rows ->', path.relative(root, OUT), Object.keys(ledger).length ? '(ledger present)' : '');
