class_name PromptText
extends RefCounted
## Controller support (Oct 26): button prompts that switch between keyboard keys and controller buttons by themselves. A control bound with
## `PromptText.bind(control, template)` shows `render(template)` and re-renders whenever the player switches device (`InputDevice`).
## Template words: "{open_deck}" -> the action's first key or pad button ("B" / "X"), "{hint:interact}" -> all its keys ("E / Space" / "A"),
## "{back}" / "{confirm}" -> the menus' back / confirm key, and the old literal spellings still in many screens: "(Esc)" -> "(B)", "[E]" -> "[A]".

const GROUP: StringName = &"pad_prompt"
const META_TEMPLATE: StringName = &"prompt_template"
const META_PROPERTY: StringName = &"prompt_property"
const META_PAD: StringName = &"prompt_pad_template"


## The template with every prompt word replaced for the device in use.
static func render(template: String) -> String:
	var text: String = template
	if text.contains("(Esc)"):
		text = text.replace("(Esc)", "(%s)" % Keybinds.back_key())
	if text.contains("[E]"):
		text = text.replace("[E]", Keybinds.prompt(&"interact"))
	if not text.contains("{"):
		return text
	text = text.replace("{back}", Keybinds.back_key()).replace("{confirm}", Keybinds.confirm_key())
	var start: int = text.find("{")
	while start >= 0:
		var end: int = text.find("}", start)
		if end < 0:
			break
		var word: String = text.substr(start + 1, end - start - 1)
		var replacement: String = ""
		if word.begins_with("hint:"):
			replacement = Keybinds.hint(StringName(word.trim_prefix("hint:")))
		elif not Keybinds.entry(StringName(word)).is_empty():
			replacement = Keybinds.first_key(StringName(word))
		else:
			start = text.find("{", end)
			continue
		text = text.substr(0, start) + replacement + text.substr(end + 1)
		start = text.find("{", start + replacement.length())
	return text


## Shows `template` on `control` (its `property`: "text" or "tooltip_text") and keeps it in step with the device. `pad_template`, when given, is
## used instead while a controller is in use (a hint line whose wording differs: "Left stick: move"). Returns the rendered text.
static func bind(control: Object, template: String, property: StringName = &"text", pad_template: String = "") -> String:
	var node: Node = control as Node
	if node == null:
		return template
	node.set_meta(META_TEMPLATE, template)
	node.set_meta(META_PROPERTY, property)
	if pad_template.is_empty():
		if node.has_meta(META_PAD):
			node.remove_meta(META_PAD)
	else:
		node.set_meta(META_PAD, pad_template)
	if not node.is_in_group(GROUP):
		node.add_to_group(GROUP)
	var text: String = _render_node(node)
	node.set(property, text)
	return text


static func _render_node(node: Node) -> String:
	if InputDevice.using_pad() and node.has_meta(META_PAD):
		return render(str(node.get_meta(META_PAD)))
	return render(str(node.get_meta(META_TEMPLATE, "")))


## Re-renders every bound control (on a device switch, and after a rebind).
static func refresh_all(tree: SceneTree) -> void:
	if tree == null:
		return
	for node: Node in tree.get_nodes_in_group(GROUP):
		if node.has_meta(META_TEMPLATE):
			node.set(StringName(node.get_meta(META_PROPERTY, &"text")), _render_node(node))
