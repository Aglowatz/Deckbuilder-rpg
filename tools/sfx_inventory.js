#!/usr/bin/env node
// Writes docs/audio/sfx_inventory.md and .tsv (the sound-effects inventory) after the sound pass: every row of the original audit with its final
// status and the bank events that now play it, then every event in the bank (data/audio/sfx_bank.json) with its bus, layers and variants.
//   node tools/sfx_inventory.js
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const BANK = JSON.parse(fs.readFileSync(path.join(ROOT, "data", "audio", "sfx_bank.json"), "utf8"));
const TSV = path.join(ROOT, "docs", "audio", "sfx_inventory.tsv");
const MD = path.join(ROOT, "docs", "audio", "sfx_inventory.md");

// Original ID -> [status, events or profiles, note]. Status: done (a real sound for it plays in the game), partial (some of the ideal, or a stand-in
// from the new family), not added (nothing new; why).
const FINAL = {
	"SFX-CARD-DRAW": ["done", "card_draw", "6 card slides; quieter for the opponent and the opening hand"],
	"SFX-CARD-PLAY-UNIT": ["done", "card_play_cheap, card_play, card_play_heavy, summon_*", "by weight (snap / snap + thud + dust / heavy thud), then the Path's summon as it lands"],
	"SFX-CARD-PLAY-SPELL": ["done", "spell_cast, spell_cast_big", "a paper whoosh with a glint; bigger from cost 4"],
	"SFX-CARD-PLAY-ITEM": ["done", "tool_attach, card_play*", "Tools land by weight; attaching one is leather and a clink"],
	"SFX-CARD-HOVER": ["done", "card_hover", "5 paper breaths, the quietest battle sound"],
	"SFX-CARD-DISCARD": ["done", "card_discard", "4 card shoves and a dust tail"],
	"SFX-CARD-SHUFFLE": ["done", "card_shuffle, battle_start", "4 riffles; a longer riffle opens each battle"],
	"SFX-CARD-RETURN": ["done", "card_return", "a reversed slide and a breath"],
	"SFX-RES-BEEF": ["done", "iron_gain, iron_spend", "a gym plate clank"],
	"SFX-RES-GOUR": ["done", "ingredient_gain, ingredient_spend", "a sizzle and a pan tap"],
	"SFX-RES-NECRO": ["done", "redtape_gain/spend, contract_gain/spend", "a rubber stamp and a tape rip; Contracts a quill scratch"],
	"SFX-RES-REF": ["done", "garbage_gain, garbage_spend", "a rattle of cans"],
	"SFX-RES-NEUTRAL": ["done", "land_play, resource_gain", "a card thud; a coin for a resource with no Path"],
	"SFX-ENERGY-SPEND": ["done", "energy_tick, energy_gain", "one rising glassy tick per point"],
	"SFX-ATTACK-DECLARE": ["done", "attack_declare, attack_lunge", "cloth as attackers step up; a whoosh on each lunge"],
	"SFX-BLOCK": ["done", "block", "a plate catching the blow"],
	"SFX-DAMAGE-LIGHT": ["done", "hit_light", "punch + cloth body"],
	"SFX-DAMAGE-HEAVY": ["done", "hit_medium, hit_heavy", "a deeper hit with a generated low thump; dips the music"],
	"SFX-DAMAGE-METAL": ["done", "hit_metal, block", "metal on metal"],
	"SFX-DAMAGE-PLAYER": ["done", "hit_player, low_hp", "a body blow; a heartbeat once the hero is below a third"],
	"SFX-HEAL": ["done", "heal", "a warm rising pair of glass notes with a breath"],
	"SFX-DEATH-UNIT": ["done", "death_*", "a torn card turning to dust with the Path's tail"],
	"SFX-TRAP-SET": ["done", "trap_set", "a latch and a hidden creak"],
	"SFX-TRAP-TRIGGER": ["done", "trap_spring", "a spring snap, a plate, a whoosh and a thump; dips the music"],
	"SFX-TOOL-USE": ["partial", "tool_attach", "Tools attaching are covered; per-category potion/charm sounds were not added (no separate use moment)"],
	"SFX-TOOL-EQUIP": ["done", "tool_equip, tool_unequip", "leather and a buckle in the character screen"],
	"SFX-STAT-UP": ["done", "buff, debuff, keyword_gain", "a rising (or falling) two-note glint"],
	"SFX-TOKEN": ["done", "token_create", "a small poof"],
	"SFX-TURN-START": ["done", "turn_start_player, turn_start_enemy", "a softer warm bell; lower for the enemy"],
	"SFX-END-TURN": ["done", "turn_end", "a card-stack tap"],
	"SFX-BATTLE-START": ["done", "battle_start", "a riffle and a whoosh"],
	"SFX-REFUSE-PILE": ["done", "refuse_open", "papers sliding and a folder opening"],
	"SFX-UI-CLICK": ["done", "ui_click (every button, UiSounds)", "a light wooden tap with a paper tick"],
	"SFX-UI-HOVER": ["done", "ui_hover (every button)", "a breath of card edge"],
	"SFX-UI-CONFIRM": ["done", "ui_confirm", "two wooden taps rising"],
	"SFX-UI-BACK": ["done", "ui_back", "a card sliding away"],
	"SFX-UI-ERROR": ["done", "ui_error", "a muted double knock on wood"],
	"SFX-UI-OPEN": ["done", "ui_open", "a folder opening (3 variants)"],
	"SFX-UI-CLOSE": ["done", "ui_close", "the mirror (3 variants)"],
	"SFX-UI-TOGGLE": ["done", "ui_toggle", "a small brass catch"],
	"SFX-UI-TICK": ["done", "ui_tick", "a paper tick"],
	"SFX-UI-SELECT": ["done", "ui_select", "a brighter tap"],
	"SFX-UI-TOAST": ["done", "notify", "a soft paper-and-glass notice (coins only where gold is gained)"],
	"SFX-UI-SLIDER": ["done", "ui_slider (every slider)", "a notch tick for the player's own drags"],
	"SFX-UI-PAGE": ["done", "book, ui_tab", "page turns; tabs turn a page too"],
	"SFX-DIALOGUE-BLIP": ["done", "dialogue, dialogue_airy", "a woody tok pitched per speaker kind; breathy for ghosts"],
	"SFX-NPC-TALK": ["partial", "ui_open, dialogue", "the box opens like a folder and the voice is per speaker; no recorded 'hm?' voices"],
	"SFX-NPC-INTERACT-PROP": ["done", "sign_read, lever_clunk", "a wooden creak and a page for signs; an iron lever"],
	"SFX-QUEST-ACCEPT": ["done", "quest_accept, quest_complete", "a quill and a rising motif; a stamp and a bright pair"],
	"SFX-STEP-GRASS": ["done", "step_grass", "on the walk cycle's contacts; no run variant (the hero has no sprint)"],
	"SFX-STEP-COBBLE": ["done", "step_cobble, step_stone", "boots on cobbles; stone and concrete"],
	"SFX-STEP-DIRT": ["done", "step_dirt", "dry dirt with grit"],
	"SFX-STEP-WOOD": ["done", "step_wood", "planks: bridges, rafts, the Buffet hub"],
	"SFX-STEP-TILE": ["done", "step_tile, step_marble, step_pastel, step_carpet", "tile and linoleum, marble halls, the pastel plaza, carpet"],
	"SFX-STEP-METAL": ["done", "step_metal", "grating"],
	"SFX-STEP-GRAVEL": ["done", "step_gravel, step_junk, step_ash, step_mashed", "gravel; junk gravel with the odd can; ash; mashed potato"],
	"SFX-STEP-WATER": ["not added", "-", "the hero never wades (water is a hazard or a raft)"],
	"SFX-JUMP": ["not added", "-", "the hero has no jump; throws and bounces have their own sounds"],
	"SFX-HERO-HURT": ["done", "hero_hurt", "a body blow and cloth"],
	"SFX-HERO-FAINT": ["not added", "-", "the faint is a story moment with its own music"],
	"SFX-ENEMY-ALERT": ["partial", "enemy_alert", "one alert for every enemy as it engages (not per enemy kind)"],
	"SFX-ENEMY-DEFEAT-WORLD": ["not added", "-", "the victory sting and its layer carry it"],
	"SFX-DOOR": ["done", "door, dungeon_enter, portal_enter, gate_cross", "doors, dungeon entrances, zone portals, the Capital gate"],
	"SFX-TRANSITION": ["done", "zone_transition", "a gust between areas"],
	"SFX-GATE-OPEN": ["done", "gate_big, gate_cross", "the great gate winds open with a boom (the first return after the gate battle)"],
	"SFX-LADDER": ["not added", "-", "ladders and the service shaft use their door sounds"],
	"SFX-RIFT-EXPRESS": ["done", "rift_open", "a tearing riser and crackles"],
	"SFX-RIFT-NEAR": ["done", "spot/rift_hum emitters, amb/rift_crackle", "the castle and the crystals hum; rifts crackle outside"],
	"SFX-RIFT-SEAL": ["done", "rift_seal", "an implosion under the rift sting"],
	"SFX-CHEST-OPEN": ["done", "chest_open, chest_iron", "a wooden lid, latch and glint; iron chests in the dungeons"],
	"SFX-CHEST-GIANT": ["done", "chest_giant", "a big creak, a spring and a cheeky pop"],
	"SFX-COINS": ["done", "coins, shop_buy", "coins; a fuller pile for purchases"],
	"SFX-PICKUP": ["partial", "pickup", "the event exists (chime and bag); the game's pickups still use their chest or coin sounds"],
	"SFX-HEAL-SPOT": ["done", "heal", "the warm chime"],
	"SFX-LEVER": ["done", "lever_clunk", "a recorded lever and a clink"],
	"SFX-VAULT-GRIND": ["done", "vault_grind", "a real stone slab and a boom"],
	"SFX-SMOKE-BOMB": ["done", "smoke_bomb", "a poof and a ping"],
	"SFX-SPLASH": ["done", "splash", "a real splash"],
	"SFX-BOING": ["done", "boing", "a jaw-harp boing"],
	"SFX-PACK-TEAR": ["done", "pack_tear", "a card pack torn open and a crisp rip"],
	"SFX-PACK-WHOOSH": ["done", "pack_whoosh", "a swoosh and a card fan"],
	"SFX-PACK-FLIP": ["done", "pack_flip", "a snap, higher per rarity"],
	"SFX-PACK-CHIME-UNCOMMON": ["done", "pack_reveal_uncommon/rare/legend", "glass and bell glints under the rare and legendary stings"],
	"SFX-CRAFT-BREW": ["done", "craft_brew", "bubbling and a rising glint"],
	"SFX-VENDOR-REACT": ["not added", "-", "needs recorded voices"],
	"SFX-ARENA-CROWD": ["partial", "arena_cheer", "the crowd cheers a win; no crowd bed (the arena is a battle board)"],
	"SFX-MINIGAME-TICK": ["partial", "ding, ui_tick", "a glass pair for right answers; misses keep the interface error"],
	"SFX-PUZZLE-CLICK": ["partial", "ui sounds", "the dungeon puzzles use the interface family"],
	"AMB-FOREST": ["done", "forest", "pines and birds; birdsong, gusts, a woodpecker"],
	"AMB-TOWN": ["done", "town", "a village murmur; birds, chatter, chimes, a far bell; the fountain"],
	"AMB-GRAVEYARD": ["not added", "-", "the town has one profile everywhere"],
	"AMB-GAINLANDS": ["done", "gainlands", "warm wind; grunts, cheers, weights; the hamster wheel"],
	"AMB-BUFFET": ["done", "buffet", "kitchen bustle and sizzle; pots, gravy, a bell; the gravy river"],
	"AMB-DNA": ["done", "dna", "office hum, fluorescent buzz, a clock; typewriters, stamps, whispers, papers"],
	"AMB-DUMP": ["done", "heap", "crickets; goats, frogs, windmill, junk; a drone and a pulse toward the Rotheart"],
	"AMB-CAPITAL-OUT": ["done", "capital_out", "hollow wind and ash; rift crackles, debris, a crow"],
	"AMB-CAPITAL-IN": ["done", "capital_in, capital_<district>_<state>, capital_restored", "an unnatural quiet, a perfect fountain, chimes, one looping bird; every district broken or restored"],
	"AMB-CREASE": ["not added", "-", "the Crease plays the Capital's inside profile"],
	"AMB-CAVE": ["not added", "-", "dungeons are node maps (no ambience)"],
	"AMB-HOUSE-OF-GAINS": ["not added", "-", "node map"],
	"AMB-TEST-KITCHEN": ["not added", "-", "node map"],
	"AMB-HALL-OF-APPROVALS": ["not added", "-", "node map"],
	"AMB-ROTHEART": ["partial", "spot/rotheart, amb/rot_pulse", "its pulse is heard in the Dump; the dungeon itself is a node map"],
	"AMB-CASTLE": ["partial", "spot/rift_hum", "the castle's rift hum from the approach; the dungeon is a node map"],
	"AMB-LAB": ["not added", "-", "node map"],
	"AMB-ARENA": ["not added", "-", "battle board"],
	"AMB-WEATHER-WIND": ["done", "amb/meadow_wind, amb/waste_wind, amb/forest_bed", "per place, as beds"],
	"AMB-WEATHER-RAIN": ["not added", "-", "no rain in the game"],
	"AMB-WEATHER-ASH": ["done", "amb/ash_hiss", "a papery hiss outside the Capital"],
	"AMB-WATER-STREAM": ["partial", "spot/fountain", "the fountains; no streams with sound"],
	"AMB-WATER-SOUP": ["done", "spot/gravy, amb/gravy_bubble", "the gravy river bubbles"],
};

function cell(text) {
	return String(text).replace(/\t/g, " ").replace(/\|/g, "/");
}

function main() {
	const rows = fs.readFileSync(TSV, "utf8").trim().split(/\r?\n/).map((l) => l.split("\t"));
	const header = rows.shift();
	const idx = Object.fromEntries(header.map((h, i) => [h, i]));
	const out = [];
	const counts = { done: 0, partial: 0, "not added": 0 };
	for (const r of rows) {
		const id = r[idx["Suggested ID"]];
		const final = FINAL[id] || ["not added", "-", "(not reviewed)"];
		counts[final[0]] = (counts[final[0]] || 0) + 1;
		out.push({ id, event: r[idx["Event"]], area: r[idx["Area"]], before: r[idx["Current status"] ?? idx["Status before the pass"]], status: final[0], plays: final[1], note: final[2], priority: r[idx["Priority"]] });
	}
	const tsvHeader = ["Suggested ID", "Event", "Area", "Status before the pass", "Final status", "Bank events / profiles", "What plays now", "Priority"];
	const tsv = [tsvHeader.join("\t"), ...out.map((o) => [o.id, o.event, o.area, o.before, o.status, o.plays, o.note, o.priority].map(cell).join("\t"))].join("\n") + "\n";
	fs.writeFileSync(TSV, tsv);
	const events = Object.entries(BANK.events).sort(([a], [b]) => a.localeCompare(b));
	const lines = [
		"# Sound effects inventory",
		"",
		"Every sound the game plays outside its music and stings, after the sound-effects pass (docs/audio/sound_direction.md). Generated by",
		"`node tools/sfx_inventory.js`. **To paste into a Google Sheet:** open `docs/audio/sfx_inventory.tsv` (tab separated) and paste it into A1.",
		"",
		`- The original audit's ${out.length} rows: **${counts.done} done**, **${counts.partial} partial**, **${counts["not added"]} not added** (each with the reason).`,
		`- The bank now has ${events.length} events over ${Object.keys(BANK.sets).length} sets and ${Object.values(BANK.sets).reduce((n, l) => n + l.length, 0)} files (every file's source in \`sfx_sources.md\`).`,
		"- No event is silent and every name the code plays has a sound (`tests/audio/test_battle_sounds.gd` scans the code; `tools/run_sfx_check.sh` plays them all windowed).",
		"- Levels: every event within 2 dB of its role's target (`node tools/sfx_mix_report.js`); none peaks above -1 dBFS on its bus.",
		"",
		"## The original audit, final status",
		"",
		"| ID | Event | Area | Before | Final | Plays now | Notes | Pri. |",
		"|---|---|---|---|---|---|---|---|",
		...out.map((o) => `| ${o.id} | ${cell(o.event)} | ${o.area} | ${o.before} | **${o.status}** | \`${cell(o.plays)}\` | ${cell(o.note)} | ${o.priority} |`),
		"",
		"## Every event in the bank",
		"",
		"Bus, level (dB), layers (set x variants, delay), 3D range when it plays in the world. Defined in `data/source/sfx_events.csv`.",
		"",
		"| Event | Bus | Level | Layers | 3D |",
		"|---|---|---|---|---|",
		...events.map(([name, e]) => `| \`${name}\` | ${e.bus} | ${e.volume} | ${e.layers.map((l) => `${l.set} x${(BANK.sets[l.set] || []).length}${l.delay ? ` @${Math.round(l.delay * 1000)}ms` : ""}${l.chance ? ` (${Math.round(l.chance * 100)} %)` : ""}`).join(" + ")} | ${e.spatial ? `${e.range || 28} m` : ""} |`),
		"",
		"## Ambience profiles",
		"",
		"Beds, one-shots and acoustics per place are in `core/audio/ambience_profiles.gd`; landmark loops in `world/audio/zone_soundscape.gd`.",
		"",
	];
	fs.writeFileSync(MD, lines.join("\n"));
	console.log(`inventory: ${out.length} audit rows (${JSON.stringify(counts)}), ${events.length} events`);
}

main();
