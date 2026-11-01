// Oct 31: the designer's answers to the critic pass inbox (docs/overnight_inbox.md "Dialogue critic pass"), as importer merges.
//   node docs/dialogue/fixes_oct31/fixes.js        writes merges.csv next to this file
//   node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_oct27.csv --merge=docs/dialogue/fixes_oct31/merges.csv [--apply]
// Two lines that swap the literal "Elowen" for {rescuer} cannot go through the importer ({rescuer} has no fixed fill to compare); they
// were hand-edited and are listed in README.md.
const fs = require('fs');
const path = require('path');
const { csvq } = require('../../../tools/dialogue_ids');

const S = 'data/story/';
const rows = [
	// 5. The alone path through the Lab study: the drawing tells him whose father Siphon is.
	[S + 'story_scenes.json::scenes/lab_study_alone/steps/0::1', "The only room in the Lab with a rug. On the desk, a journal in a neat, slanted hand, and a child's drawing: 'For Papa, from {rescuer}.' The last entry is ten years old."],
	[S + 'story_scenes.json::scenes/lab_study_alone/steps/2::1', "Siphon is {rescuer}'s father. He held the door."],
	// 6. He came for her once.
	[S + 'intro_story.tres::postgame.rescuer.freed::0', "You came back for me. Down there, on purpose. I'm going to need a while to stop being cross about it."],
	// 7. The Grand Chef to the faceless cook, before she gives it her name.
	[S + 'gourmand_story.tres::cutscene.wonder.6::1', 'You wore my face for ten years and never once learned to taste. Today you start. Let me give you something to start with.'],
	// 8. Druid Sorrel's lines go to Moss Mulligan (freed, a druid, the herd's raccoon is her favourite).
	[S + 'refusemancer_story.tres::grow.bridge_center.pass::0', 'Moss Mulligan hops up from the bank. "You got Billie\'s herd home? The goat, the pig AND the raccoon? Then the stream owes you a bridge."'],
	[S + 'refusemancer_story.tres::grow.bridge_center.need::0', 'Moss Mulligan tucks her hands behind her back. "Sorry! I only grow bridges for people who have helped the herd, and Billie Muckfoot\'s animals have got out again.'],
	[S + 'refusemancer_story.tres::grow.bridge_center.need::1', 'Round them up for Billie, then come back to me, and I will grow you a way across. No thorns. Promise."'],
	[S + 'refusemancer_story.tres::sign.bridge_center::1', 'Moss Mulligan grows this one for anyone who helps Billie Muckfoot round up the herd.'],
	[S + 'refusemancer_story.tres::quest.heap_herd.done::0', "The herd's home and it's plotting. Thanks! Moss Mulligan at the centre bridge will grow you a crossing now. Tell her I sent you."],
	// 9. Rip's shirt number is 212 (213 is the Wanderer's D.N.A. ticket).
	['data/npcs/npcs.json::NPC-RIP.barks::1', 'Shirt number two hundred and twelve. Very proud of it. Notice my form?'],
	// 10. The Model Room; the Trophy Hall rule text names the token its banner names; the hamster wheels no longer share names with
	// Gerald or the Colonels; parlour.
	[S + 'capital_story.tres::dungeon.pc_model_warden.blurb::0', 'The last guard before the Model Room: a warden whose job is to keep everyone away from the table. (Elite)'],
	[S + 'capital_story.tres::dungeon.pc_boss.title::0', 'The Model Room'],
	[S + 'capital_story.tres::dungeon.pc_boss.before::0', 'The Model Room is round and domed, and in its centre stands a table the size of a house: a perfect miniature of {kingdom}.'],
	['data/encounters/encounter_scripts.json::Trophy Hall Honor Guard/0/text::0', 'At half health a reserve guard steps off a pedestal: a 1/1 Reserve Guard joins.'],
	[S + 'gainlands_story.tres::wheel.wheel_names::1', 'Nugget'],
	[S + 'gainlands_story.tres::wheel.wheel_names::5', 'Big Lou'],
	[S + 'capital_story.tres::prop.parlor::0', 'PELL FAMILY PARLOUR'],
	[S + 'capital_story.tres::sign.grave_waiting::1', 'The deceased are asked to remain in their parlours until a permit has been approved. Please do not wander.'],
	['core/quests/zone_quest_definitions.gd::_cap_burial::1', "Widow Pell's husband has sat in the family parlour for three years because his burial permit loops forever. It needs the Stamp of Final Approval, somewhere in Grave Row."],
	// 11. The freed loudspeaker is Plume.
	[S + 'capital_story.tres::facade.speaker.1.0.freed::0', 'Attention, citizens. (a cough) The weather is no longer approved. It is just weather. It seems to be managing.'],
	// 13. The tri-Path recipes exist now (core/data/alchemy.gd craft_tri).
	[S + 'capital_story.tres::ending.postgame.line.2::0', "The Alchemist's cauldron now takes three Paths at once: brew their essence into a tri-Path card."],
];
fs.writeFileSync(path.join(__dirname, 'merges.csv'), 'id,new_text\n' + rows.map(([id, text]) => [id, text].map(csvq).join(',')).join('\n') + '\n');
console.log(`merges.csv: ${rows.length} rows`);
