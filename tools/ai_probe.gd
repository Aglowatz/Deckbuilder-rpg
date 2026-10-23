extends SceneTree
## Battle AI upgrade (Oct 23): a hand-built position for reading the AI's candidate scores (AICombat.debug). Edit the board below,
## run `Godot --headless --path . -s res://tools/ai_probe.gd` and read the printout. Not a test; a magnifying glass.


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	CardSet.load_all()
	var game: GameState = GameFactory.blank_game(5)
	GameFactory.add_infrastructure_cards(game, 0, 3)
	GameFactory.add_infrastructure_cards(game, 1, 5, Affinity.Type.NECROCRAT)
	game.players[0].hp = 11
	game.players[1].hp = 5
	var militia: CardInstance = GameFactory.add_to_field(game, 0, CardSet.card("C-02"))
	var brawler: CardInstance = GameFactory.add_to_field(game, 0, CardSet.card("C-06"))
	var ripper: CardInstance = GameFactory.add_to_field(game, 0, CardSet.card("B-06"))
	var mmz: CardInstance = GameFactory.add_to_field(game, 1, CardSet.card("N-23"))
	mmz.exhausted = true
	var mortimer: CardInstance = GameFactory.add_to_field(game, 1, CardSet.card("N-33"))
	mortimer.summoning_sick = true
	var temp: CardInstance = GameFactory.add_to_field(game, 1, TokenRegistry.data("T-10"))
	temp.summoning_sick = true
	var clerk: CardInstance = GameFactory.add_to_field(game, 1, CardSet.card("N-01"))
	clerk.summoning_sick = true
	ResourceRules.create(game, 1, ResourceKind.Kind.RED_TAPE, 1)
	ResourceRules.create(game, 0, ResourceKind.Kind.IRON, 3)
	print("board: ", [militia.uid, brawler.uid, ripper.uid, mmz.uid, mortimer.uid, temp.uid, clerk.uid])
	var ai: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	ai.deterministic = true
	print("eval before: %.2f" % ai.evaluate(game, 0))
	var steps: int = 0
	while game.active == 0 and not game.is_over() and steps < 20:
		steps += 1
		if game.phase == GameState.Phase.COMBAT and game.combat_step == GameState.CombatStep.DECLARE_ATTACKERS:
			ai._combat.debug = true
		var action: GameAction = ai.choose_action(game)
		print("%s (%.0f ms)" % [action.describe(), ai.last_think_ms])
		ai._combat.debug = false
		if not game.apply_action(action):
			print("ILLEGAL")
			break
	quit(0)
