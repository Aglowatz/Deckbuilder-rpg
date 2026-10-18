extends GutTest
## Overnight Oct 17 (Phase 2 cycle 10): the Music bus carries a gentle leveller before its duck amplifier, so quiet passages of the very dynamic
## tracks stay audible; the ducks still work through the amplifier.


func test_music_bus_has_the_leveller_after_the_duck() -> void:
	AudioMix.ensure_layout()
	var bus: int = AudioServer.get_bus_index(&"Music")
	assert_gte(bus, 0)
	var compressor: AudioEffectCompressor = null
	var amp_index: int = -1
	var compressor_index: int = -1
	for index: int in range(AudioServer.get_bus_effect_count(bus)):
		var effect: AudioEffect = AudioServer.get_bus_effect(bus, index)
		if effect is AudioEffectAmplify:
			amp_index = index
		if effect is AudioEffectCompressor:
			compressor = effect as AudioEffectCompressor
			compressor_index = index
	assert_not_null(compressor)
	assert_almost_eq(compressor.threshold, -30.0, 0.01)
	assert_almost_eq(compressor.ratio, 2.0, 0.01)
	assert_almost_eq(compressor.gain, 6.0, 0.01)
	assert_lt(compressor_index, amp_index, "the leveller first, then the duck (so a duck keeps its full depth)")
	AudioMix.ensure_layout()
	var count: int = 0
	for index: int in range(AudioServer.get_bus_effect_count(bus)):
		if AudioServer.get_bus_effect(bus, index) is AudioEffectCompressor:
			count += 1
	assert_eq(count, 1, "running the layout again adds no second leveller")
