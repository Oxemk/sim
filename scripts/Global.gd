extends Node

# Currently active scene (non-autoload)
var current_scene: Node = null

# User session
var current_user_id: String = ""
var current_username: String = ""
var current_character: Dictionary = {}
var player: Node = null
var is_logged_in: bool = false
var has_selected_character: bool = false

const MAX_START_CHARACTERS: int = 2
const BASE_STATS := {
	"strength": 5,
	"endurance": 5,
	"dexterity": 5,
	"intellect": 5,
	"spirit": 5,
	"charisma": 5,
	"luck": 5,
	"adaptability": 5
}

# Clear character data
func clear_character() -> void:
	current_character.clear()
	has_selected_character = false

# Log out user
func logout() -> void:
	current_user_id = ""
	current_username = ""
	is_logged_in = false
	clear_character()

# Safe scene switch (removes old scene)
func switch_scene(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("Global.switch_scene: Scene path does not exist: %s" % path)
		return

	var new_scene: Node = (load(path) as PackedScene).instantiate()
	var root = get_tree().root
	if current_scene:
		root.remove_child(current_scene)
		current_scene.queue_free()
	root.add_child(new_scene)
	current_scene = new_scene
	get_tree().current_scene = new_scene
func get_current_character_xp() -> int:
	return current_character.get("xp", 0)
func add_xp(amount: int) -> void:
	current_character["xp"] = get_current_character_xp() + amount

# Debugging helper: prints the scene tree pretty, deferred
func _debug_tree() -> void:
	get_tree().root.call_deferred("print_tree_pretty")
