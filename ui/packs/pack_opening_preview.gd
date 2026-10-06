class_name PackOpeningPreview
extends Control
## Developer scene for screenshots and visual review of the pack opening. It grants one pack, optionally searches for a seed that
## rolls a Legendary (`--legendary`) or owns four copies of the rolled cards so they convert (`--extras`), then drives the real
## `PackOpeningScreen` to a stage and says it is ready for the screenshot.
##   --pack=<pack id> (default path_beefcake)   --stage=pack|torn|reveal1|reveal_all|legendary|summary
##   --legendary   --extras   --seed=<n>

var _pack_id: String = "path_beefcake"
var _stage: String = "summary"
var _want_legendary: bool = false
var _extras: bool = false
var _seed: int = 1
var _screen: PackOpeningScreen
var _ready_for_shot: bool = false


func screenshot_prepare(args: Dictionary) -> void:
	_pack_id = str(args.get("pack", _pack_id))
	_stage = str(args.get("stage", _stage))
	_want_legendary = args.has("legendary")
	_extras = args.has("extras")
	_seed = int(args.get("seed", _seed))


func screenshot_ready() -> bool:
	return _ready_for_shot


func _ready() -> void:
	Session.save_enabled = false
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var pack: PackData = PackCatalog.find(_pack_id)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _seed
	if _want_legendary:
		for candidate: int in range(1, 4000):
			rng.seed = candidate
			var rolled: Array[CardData] = PackRoller.roll(pack, Session.content, rng)
			if rolled.any(func(card: CardData) -> bool: return card.rarity == CardEnums.Rarity.LEGENDARY):
				rng.seed = candidate
				break
	var preview: Array[CardData] = PackRoller.roll(pack, Session.content, _clone(rng))
	if _extras:
		for card: CardData in preview.slice(0, 2):
			for i: int in range(DeckValidator.MAX_COPIES):
				Session.add_cards([card] as Array[CardData])
		Session.profile.essence.clear()
	Session.add_pack(_pack_id, 2)
	var opening: PackOpening = Session.open_pack(_pack_id, rng)
	_screen = PackOpeningScreen.new()
	_screen.opening = opening
	_screen.packs_left = Session.pack_count(_pack_id)
	add_child(_screen)
	_drive.call_deferred()


func _clone(source: RandomNumberGenerator) -> RandomNumberGenerator:
	var copy: RandomNumberGenerator = RandomNumberGenerator.new()
	copy.seed = source.seed
	copy.state = source.state
	return copy


func _drive() -> void:
	await get_tree().create_timer(1.0).timeout
	if _stage == "pack":
		_done()
		return
	_screen._advance()
	await get_tree().create_timer(0.45).timeout
	if _stage == "torn":
		_done()
		return
	await get_tree().create_timer(2.1).timeout
	if _stage == "reveal1":
		_screen._advance()
		await get_tree().create_timer(1.1).timeout
		_done()
		return
	if _stage == "legendary":
		var count: int = _screen.opening.entries.size()
		for index: int in range(count):
			var rarity: int = int(_screen.opening.entries[index].card.rarity)
			_screen._advance()
			if rarity >= 3:
				await get_tree().create_timer(2.1).timeout
				_done()
				return
			await get_tree().create_timer(1.0).timeout
		_done()
		return
	for index: int in range(_screen.opening.entries.size()):
		_screen._advance()
		await get_tree().create_timer(0.9).timeout
		while _screen._busy:
			await get_tree().create_timer(0.3).timeout
	if _stage == "reveal_all":
		await get_tree().create_timer(1.2).timeout
		_done()
		return
	_screen._advance()
	await get_tree().create_timer(1.2).timeout
	_done()


func _done() -> void:
	_ready_for_shot = true
