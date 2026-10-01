class_name ZoneStoryText
extends Resource
## Every line of dialogue, signage, memo, poster and quiz text in the D.N.A. zone (Department of
## Necrotic Affairs - the Necrocrats' office, run by Afterlife Services and Labor), kept in one
## place so it can be rewritten without touching code. Loaded from data/story/dna_story.tres
## (which only needs to point at this script; the defaults below are the text).
##
## Keys: "npc.<id>.<situation>", "quest.<quest id>.<offer|active|ready|done>", "sign.<id>",
## "memo.<id>", "poster.<id>", "fx.<id>" (interactable results), "puzzle.*", "quiz.*", "match.*".
## Each value is an Array of lines (one dialogue box each, or one line of a sign).
## The quiz questions live in `quiz_questions`; every answer is findable on a sign/memo/NPC line
## here (see the "Quiz source" notes) - if you rewrite a source line, rewrite the question too.

const PATH: String = "res://data/story/dna_story.tres"


@export var lines: Dictionary = {
	# ---- Signage (the quiz answers hide in here) ------------------------------------------------
	"sign.lobby_main": ["DEPARTMENT OF NECROTIC AFFAIRS", "A Division of Afterlife Services and Labor"],  # Quiz source 1
	"sign.motto": ["OUR MOTTO:", "\"Your Death, Our Priority.\""],  # Quiz source 2
	"sign.take_number": ["DECEASED?", "TAKE A NUMBER."],
	"sign.now_serving": ["NOW SERVING:", "ONE (since 1291)"],
	"sign.elevator_rule": ["RECORDS BASEMENT ELEVATOR", "Form 13-B required. No form, no floor."],  # Quiz source 3
	"sign.fun_day": ["MANDATORY FUN DAY - THIS FRIDAY", "Attendance is compulsory for all staff, including the undead.", "Cake provided. Cake will not be eaten."],  # Quiz source 4
	"sign.exit": ["ELEVATOR TO SURFACE", "(Town. Sunlight not guaranteed.)"],
	"sign.heal_couch": ["BREAKROOM COUCH", "Eternal rest, 15 minute limit."],
	"sign.requisitions": ["REQUISITIONS", "Cards, in triplicate. Souls, in quadruplicate."],
	"sign.cubicle_farm_a": ["CUBICLE FARM A", "Please do not personalize your cubicle. Yes, haunting counts."],
	"sign.cubicle_farm_b": ["CUBICLE FARM B", "Hot-desking is permitted. Hot-desking has been banned. See memo."],
	"sign.filing_maze": ["FILING DEPARTMENT", "If you are lost, you are in the correct place."],
	"sign.records": ["RECORDS BASEMENT", "Every life, filed under 'Pending'."],
	"sign.mailroom": ["MAIL ROOM", "All souls routed by pneumatic tube. Souls routed incorrectly will be re-routed. Eventually."],
	"sign.executive": ["EXECUTIVE FLOOR", "Staff beyond this point are dead. Executives were dead before it was fashionable."],
	"sign.elevator_bank": ["ELEVATOR BANK", "Floors served: Lobby, Records, Quarterly Reviews, Under Renovation."],
	"sign.main_dungeon": ["UNDER RENOVATION", "PLEASE HOLD.", "Your call is important to us. Estimated wait: 400 years."],
	"sign.mini_dungeon": ["SUB-BASEMENT 3: QUARTERLY REVIEWS", "Three meetings. Mandatory. No snacks."],
	"sign.time_clock": ["PUNCH IN. PUNCH OUT.", "(Punching other employees is not covered by your plan.)"],
	"sign.suggestion_box": ["SUGGESTIONS", "All suggestions are read by a committee that has been dead since 1979."],
	"sign.printer": ["PRINTER", "Out of toner. Out of body. Please contact IT (deceased)."],
	"sign.coffee": ["COFFEE MACHINE", "For living staff only. Undead: use the Decaf Crypt."],
	"sign.matching": ["THE REC ROOM", "Please do not feed the Top 8."],
	"sign.quiz": ["COMPLIANCE TESTING", "Annual re-certification: 4 questions. Failure is not an option. It is a form."],
	"sign.puzzle": ["PNEUMATIC SOUL ROUTING", "Set every junction. Send the souls. Do not send them to Accounts Payable."],
	"poster.safety": ["SAFETY FIRST", "You are already dead. Please do not make it worse."],
	"poster.performance": ["ETERNAL PERFORMANCE REVIEWS", "Review 1 of 4,000,000. Self-assessment due yesterday."],
	"poster.hang_in_there": ["HANG IN THERE!", "(The poster is a skeleton on a branch. It has been there since 1650.)"],
	"poster.synergy": ["SYNERGY", "Together Everyone Achieves More. Eventually. Posthumously."],
	"poster.wellness": ["WELLNESS WEDNESDAY", "Breathe in. Breathe out. (Optional for you.)"],
	"memo.coffee": ["MEMO: THE COFFEE MACHINE", "For living staff only. Undead staff, please use the Decaf Crypt.", "This is the fourth memo."],
	"memo.cubicle_coffin": ["MEMO: CUBICLE 12-C", "Whoever put a coffin in 12-C: you may keep it.", "Please stop billing it as 'ergonomic seating'."],
	"memo.hr": ["HR REMINDER", "'Rest in Peace' is not an approved out-of-office message."],
	"memo.parking": ["FACILITIES", "Parking Lot D has been renamed Parking Lot Dead. Please stop asking why."],
	"memo.fun_day": ["MEMO: MANDATORY FUN DAY", "Reminder: Mandatory Fun Day is mandatory.", "Fun that is not mandatory will not be counted as fun."],  # Quiz source 4 (again)
	"memo.reorg": ["REORG NOTICE", "Due to a restructuring, you will now report to the person who reports to you.", "Both of you have been dead since Tuesday."],
	"memo.lunch": ["BREAKROOM REMINDER", "Labelled lunches are not safe. Unlabelled lunches are not safe. Lunches are not safe."],
	"memo.records": ["RECORDS NOTICE", "To access the Records Basement, bring Form 13-B.", "Form 13-B is available from Form 13-A. Form 13-A is available from nobody."],  # Quiz source 3 (again)
	"memo.motto": ["ALL-HANDS REMINDER", "Our motto is \"Your Death, Our Priority.\" Please stop saying \"Your Death, Our Problem.\""],  # Quiz source 2 (again)
	# ---- Roaming enemies ------------------------------------------------------------------------
	"enemy.manager": ["Wants a quick sync. It has wanted one since 1994."],
	"enemy.intern": ["Unpaid. Undead. Eager to make a good impression."],
	"enemy.courier": ["Urgent delivery. Signature required. Signature will be taken."],
	"fx.hit": ["Delivery! Signature taken. (-2 life)"],
	"fx.wake": ["You wake up in the Lobby, on a couch with a 15-minute limit.", "A form is already filled out in your name."],
	# ---- Hub NPCs and quests --------------------------------------------------------------------
	"npc.dolores.intro": [
		"Welcome to the Department of Necrotic Affairs. Name? ...Doesn't matter, you're in the system as 'Pending'.",
		"I'm Dolores, front desk. Deceased since 1987, employee of the month since 1987. Nobody else qualified.",
		"Take a number. We're serving number one. Have been for seven hundred years. He's very thorough.",
		"If you're going to wander the floors, mind the staff. They're a bit... dead-set on their routines.",
	],
	"npc.dolores.return": [
		"Back again? You know, loyalty is rewarded here. Not with money. With more work.",
		"Records Basement needs Form 13-B for the elevator. I don't have one. Nobody does. It builds character.",
	],
	"npc.barnaby.intro": [
		"Oh! A customer! Barnaby, breakroom barista. I make coffee for people who can't taste it. It's very freeing.",
		"The machine in the corner is temperamental. Half the time it's a miracle. The other half, it's a different kind of miracle.",
		"New hires always have to do onboarding. Punch the clock, grab a cup. Easy. Compulsory. Same thing.",
	],
	"npc.barnaby.return": [
		"Cream? I have none. Sugar? None. Hope? Out of stock, but we're expecting a shipment in 2090.",
	],
	"npc.pip.intro": [
		"Requisitions! Pip, junior clerk, third class, third time dying. Cards, in triplicate.",
		"Everything here is Necrocrat-issue: authorized, stamped, haunted. The stamp is haunted. The stamp wants a raise.",
		"No returns. No exchanges. No refunds. Exceptions require Form 13-B, which, well. You've heard about 13-B.",
	],
	"npc.pip.return": [
		"Requisition something! Or at least stand near the desk. It makes me look busy.",
	],
	"quest.dna_backlog.offer": [
		"Oh good, a pulse. Well, a presence. I have a backlog. A literal one - it's wandering the floors.",
		"Three of the staff have gone feral over a missed deadline. Would you... process three of them? Gently? Or not?",
	],
	"quest.dna_backlog.active": ["Three of them, remember. Processed, not promoted. Don't confuse the two."],
	"quest.dna_backlog.ready": ["Three? That clears the backlog! Do you know how many forms that closes? Neither do I. Here - your bonus."],
	"quest.dna_backlog.done": ["The backlog is clear. It will be full again by Thursday. It's nice to have a moment."],
	"quest.dna_onboarding.offer": [
		"New to the floor? Then it's mandatory onboarding. Punch in at the time clock, and have a cup from the machine.",
		"Don't skip it. HR will know. HR always knows. HR is in the walls.",
	],
	"quest.dna_onboarding.active": ["Time clock, coffee machine. In that order or the other order. HR isn't picky."],
	"quest.dna_onboarding.ready": ["Punched in, caffeinated, and compliant. Onboarding complete! Here's your welcome kit. The kit is a welcome."],
	"quest.dna_onboarding.done": ["Onboarding complete. You're one of us now. Please don't read the contract."],
	"quest.dna_audit.offer": [
		"Compliance is auditing. They need two things from a fresh pair of hands: pass the re-certification quiz, and find one of the hidden stashes in the filing mazes.",
		"I can't leave the desk. Policy. Also, I can't stand. Policy and anatomy.",
	],
	"quest.dna_audit.active": ["The quiz, and a stash. The stashes are in the corners nobody visits. So, basically, everywhere."],
	"quest.dna_audit.ready": ["You passed the quiz AND found a stash? You're basically middle management. Here's your commendation. Please don't cash it."],
	"quest.dna_audit.done": ["Audit closed. The auditors went home. They live here, but they went to their desks."],
	"fx.heal_couch": ["You sink into the Breakroom Couch. Somehow it is both ice cold and slightly damp. Life restored."],
	# ---- Quiz Master ----------------------------------------------------------------------------
	"npc.quiz.intro": [
		"Ah. A candidate for re-certification. Lethe, Compliance Examiner. I examine. It's all I do. It's all I am.",
		"Four questions about the Necrocrats of Afterlife Services and Labor. All answers are on the premises: signs, memos, the staff.",
		"Answer correctly and you'll be rewarded. Answer incorrectly and you'll be rewarded less. I'm not a monster. I'm an examiner.",
	],
	"npc.quiz.return": ["Back to improve your score? Admirable. Statistically, it means you failed. Statistically, I enjoy it."],
	"quiz.result.0": ["Zero. Impressive in its own way. Nothing for you. Try again; the signs aren't going anywhere."],
	"quiz.result.1": ["One correct. A pulse of competence. Here's a small token of the Department's disinterest."],
	"quiz.result.2": ["Two. Half-credit. Half-credit is the highest honor of the Necrocrats."],
	"quiz.result.3": ["Three! One shy of perfect. Perfect would make me suspicious. Take your reward."],
	"quiz.result.4": ["FOUR. Flawless. You are now Certified Deceased, Class A. The reward is real; the title is imaginary."],
	"quiz.repeat": ["Re-certified again. The Department pays a small processing fee for the paperwork."],
	"quiz.not_passed": ["Not a pass. Study the signs and come back; there is no limit on attempts."],
	# ---- Matching minigame NPC ------------------------------------------------------------------
	"npc.matching.intro": [
		"*krrrshhh... beep-boop-BEEEEEE-krrrrrshhh...* Sorry. That's my greeting. It's how I say hello. It takes forty seconds. Dial-up, baby.",
		"I'm Skylar. Last employee of the month of 2003. My away message still says 'brb, getting a snack'. That was my snack. In 2003.",
		"I've got a top 8 of friends. It's me, me, a guy I met in a chatroom, and five ghosts. The algorithm moved me to number nine.",
		"I owe the video store a fine. Eleven dollars for a movie I returned in 2001. They're still mad. They're also closed.",
		"Wanna play? Flip two cards, match the pair. I burned the cards myself. A mix CD with forty minutes of the same song. It's fine.",
	],
	# Names of the 8 matching pairs, in the order of MatchGame.ICONS.
	"match.pairs": ["Dial-Up Modem", "Top 8 Friends", "Late Fee Receipt", "Virtual Pet (Deceased)", "Flip Phone Text", "Burned Mix CD", "Away Message", "Mix Tape"],
	"match.intro": ["Flip two cards at a time. Find all 8 pairs in 14 moves or fewer. Fewer moves, better stars."],
	"npc.matching.return": [
		"My virtual pet died again. That's seven times this week. It's okay. I'll hatch another one. I always do.",
		"Flip-phone texting, nine taps for one letter, and I still sent you a good message. Anyway: wanna play?",
	],
	"match.win": ["Nice flipping! You're a natural. Better than the Top 8. Much better."],
	"match.first": ["First time clearing it? Here's a bonus. It's not much. It's a memory. Literally, it's a memory game."],
	"match.lose": ["Out of moves. That's fine. My virtual pet lasted longer than that, and it died in an hour."],
	# ---- Puzzle ---------------------------------------------------------------------------------
	"puzzle.intro": [
		"A wall of pneumatic tubes hums and hisses. Eight capsules are queued in the intake, each stamped with its destination department.",
		"Seven junctions sit in the lines. Every junction flips after a capsule passes through it. Set the starting position of each, then send them down.",
	],
	"puzzle.solved": ["Every soul lands in the right department. The tubes cough politely and drop a small, heavy parcel in the tray."],
	"puzzle.already": ["The tubes hum contentedly. Nothing left to route."],
	"puzzle.bins": ["Harvest", "Accounts Payable", "Reaping", "Limbo", "Complaints", "Records", "Haunting", "Pest Control"],
	"puzzle.souls": ["Mr. Hargrove", "Dame Odalys", "Little Timmy B.", "A Very Tired Clerk", "The Mayor (acting)", "Gertrude, 3rd Floor", "Sir Reginald Pent", "Unknown (Please Hold)"],
	"puzzle.hint": ["Every junction flips after a capsule passes. The first capsule only cares about the three junctions on its own path - set those first, then work out the next."],
	# ---- Interactables --------------------------------------------------------------------------
	"fx.coffee_good": ["The coffee machine gurgles and produces something almost drinkable. +life."],
	"fx.coffee_great": ["Perfect brew! The machine seems proud of itself. Full recovery of... something."],
	"fx.coffee_bad": ["The machine screams. The coffee screams. You drink it anyway. -1 life."],
	"fx.coffee_gold": ["A coin rolls out of the dispenser. The machine regrets nothing. +gold."],
	"fx.printer_ok": ["The printer shudders, whines, and hands you a card, still warm. Lawfully yours."],
	"fx.printer_poor": ["PAPER JAM. The printer regrets to inform you that your fee is non-refundable."],
	"fx.punch_in": ["You punch in. The clock says 'Welcome back, Pending.' A small buff glimmers on you."],
	"fx.punch_again": ["You're already punched in. The clock refuses to double-count your suffering."],
	"fx.suggestion": ["You drop a suggestion into the box. A moment later something is dropped back out."],
	"fx.suggestion_empty": ["The suggestion box is empty now. The committee has read your suggestion. It wasn't implemented."],
	"fx.chest": ["A hidden stash!"],
	"hud.objective": ["The D.N.A.: the Lobby and Breakroom are safe. Life does not come back after battles - rest on the Breakroom Couch, or ride up to town."],
}

## Four multiple-choice questions. Each: "q", "a" (4 answers), "correct" (index into "a"), "where"
## (design note: which sign/memo/NPC line gives it away - not shown to the player).
@export var quiz_questions: Array[Dictionary] = [
	{
		"q": "What does the D.N.A. stand for?",
		"a": ["Department of Necrotic Affairs", "Division of Nocturnal Accounting", "Directorate of Newly Arrived", "Department of Neglected Alumni"],
		"correct": 0,
		"where": "sign.lobby_main, Lobby reception wall",
	},
	{
		"q": "What is the Necrocrats' official motto?",
		"a": ["\"Rest in Pieces\"", "\"Your Death, Our Priority.\"", "\"We Never Forget (Your Paperwork)\"", "\"Ask Again Tomorrow\""],
		"correct": 1,
		"where": "sign.motto in the Lobby; memo.motto on the Cubicle Farm B board",
	},
	{
		"q": "Which form is required to ride the elevator to the Records Basement?",
		"a": ["Form 7-Q", "Form 13-B", "Form 99-Z", "Form 1-A"],
		"correct": 1,
		"where": "sign.elevator_rule at the Elevator Bank; memo.records; Dolores' return dialogue",
	},
	{
		"q": "Which mandatory event is held every Friday?",
		"a": ["Mandatory Fun Day", "Mandatory Silence Hour", "Quarterly Haunting", "Casual Friday (Formal)"],
		"correct": 0,
		"where": "sign.fun_day in the Lobby; memo.fun_day in Cubicle Farm A",
	},
]

## LARGE first-pass reward tiers by correct answers (0-4; only 3 and 4 can be a first pass): gold, XP, and an item id ("" = none). Placeholder numbers.
## Small flat reward for every finished attempt after the first pass.
@export var quiz_repeat_reward: Dictionary = {"gold": 10, "xp": 5}

@export var quiz_rewards: Array[Dictionary] = [
	{"gold": 0, "xp": 0, "item": ""},
	{"gold": 10, "xp": 0, "item": ""},
	{"gold": 25, "xp": 10, "item": ""},
	{"gold": 50, "xp": 25, "item": ""},
	{"gold": 100, "xp": 60, "item": "healing_draught"},
]


## The lines for `key`, or a visible placeholder so a missing key is easy to spot in-game.
func get_lines(key: String) -> Array[String]:
	var result: Array[String] = []
	var raw: Variant = lines.get(key)
	if raw is Array:
		for entry: Variant in (raw as Array):
			result.append(str(entry))
	if result.is_empty():
		result.append("[missing text: %s]" % key)
	return result


## All lines of `key` joined for a sign/poster label.
func text(key: String) -> String:
	return "\n".join(get_lines(key))


static var _shared: ZoneStoryText


## The shared instance loaded from the .tres (falls back to the script defaults).
static func shared() -> ZoneStoryText:
	if _shared == null:
		_shared = load(PATH) as ZoneStoryText
		if _shared == null:
			_shared = ZoneStoryText.new()
	return _shared
