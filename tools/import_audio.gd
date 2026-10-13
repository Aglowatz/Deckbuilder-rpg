extends SceneTree
## The audio importer: `bash tools/import_audio.sh` ("import audio"). Copies the Drive folder in art_config.cfg (`audio_dir`, read-only) to
## assets/audio/music and assets/audio/stings by stable ID, regenerates data/audio/audio_registry.json and reports IDs with files, IDs missing a
## file and files that match no ID.


func _init() -> void:
	var source: String = AudioRegistry.source_dir()
	if source.is_empty() or not DirAccess.dir_exists_absolute(source):
		print("Error: audio source folder not found: '%s'" % source)
		quit(1)
		return
	var result: AudioRegistry.Result = AudioRegistry.import_from_source(source)
	print("Source: %s" % source)
	print("Copied or converted: %d (unchanged: %d)" % [result.copied, result.unchanged])
	print("Converted WAV -> OGG: %s" % (", ".join(result.converted) if not result.converted.is_empty() else "(none)"))
	print("Compatibility aliases (play the target's file): %s" % (", ".join(result.aliases) if not result.aliases.is_empty() else "(none)"))
	print("IDs with files (%d): %s" % [result.with_file.size(), ", ".join(result.with_file)])
	print("IDs missing a file (%d): %s" % [result.missing.size(), ", ".join(result.missing) if not result.missing.is_empty() else "(none)"])
	print("Files matching no ID: %s" % (", ".join(result.unknown) if not result.unknown.is_empty() else "(none)"))
	for problem: String in result.errors:
		print("Error: %s" % problem)
	quit(0)
