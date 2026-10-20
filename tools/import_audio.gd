extends SceneTree
## The audio importer: `bash tools/import_audio.sh` ("import audio"). Copies the Drive folder in art_config.cfg (`audio_dir`, read-only) to
## assets/audio/music and assets/audio/stings by stable ID, regenerates data/audio/audio_registry.json and reports IDs with files, IDs missing a
## file and files that match no ID.
## Overnight Oct 19-20 (Part 7): a new or changed LOOP goes through the drop-in pipeline (MusicDropIn: loop points, two-pass loudnorm to -20 LUFS,
## OGG Vorbis q5) when ffmpeg is found. Flags after `--`: `--dry-run` (report what would be copied / processed, write nothing), `--no-process`
## (copy loops verbatim, the pre-Oct 19 behaviour).


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var dry_run: bool = args.has("--dry-run")
	var options: Dictionary = {"dry_run": dry_run, "process": not args.has("--no-process")}
	var source: String = AudioRegistry.source_dir()
	if source.is_empty() or not DirAccess.dir_exists_absolute(source):
		print("Error: audio source folder not found: '%s'" % source)
		quit(1)
		return
	var result: AudioRegistry.Result = AudioRegistry.import_from_source(source, options)
	var tool: String = AudioRegistry.ffmpeg_path()
	print("Source: %s%s" % [source, " (DRY RUN: nothing written)" if dry_run else ""])
	print("ffmpeg: %s" % (tool if not tool.is_empty() else "(not found: new loops are copied verbatim)"))
	print("Copied or converted: %d (unchanged: %d)" % [result.copied, result.unchanged])
	print("Converted WAV -> OGG: %s" % (", ".join(result.converted) if not result.converted.is_empty() else "(none)"))
	print("Drop-in pipeline (loop points, loudnorm, OGG q5): %s" % ("; ".join(result.processed) if not result.processed.is_empty() else "(none)"))
	if dry_run:
		print("Would do (%d): %s" % [result.planned.size(), "; ".join(result.planned) if not result.planned.is_empty() else "(nothing)"])
	print("Compatibility aliases (play the target's file): %s" % (", ".join(result.aliases) if not result.aliases.is_empty() else "(none)"))
	print("IDs with files (%d): %s" % [result.with_file.size(), ", ".join(result.with_file)])
	print("IDs missing a file (%d): %s" % [result.missing.size(), ", ".join(result.missing) if not result.missing.is_empty() else "(none)"])
	print("IDs with a file but no trigger row in music_triggers.csv (nothing plays them yet): %s" % (", ".join(result.unassigned) if not result.unassigned.is_empty() else "(none)"))
	print("Files matching no ID: %s" % (", ".join(result.unknown) if not result.unknown.is_empty() else "(none)"))
	for problem: String in result.errors:
		print("Error: %s" % problem)
	quit(0)
