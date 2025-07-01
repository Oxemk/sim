extends Node
class_name UserData

signal user_changed
signal character_changed

var current_user: Dictionary = {}
var selected_character: Dictionary = {}

# Set current user (after login)
func set_user(user_data: Dictionary) -> void:
	current_user = user_data
	selected_character = {}  # Reset character on user change
	emit_signal("user_changed")

# Get current username safely
func get_username() -> String:
	return current_user.get("username", "")

# Set selected character (after character selection)
func set_character(character_data: Dictionary) -> void:
	selected_character = character_data
	emit_signal("character_changed")

# Get selected character ID
func get_character_id() -> String:
	return selected_character.get("id", "")

# Clear all user data (e.g. on logout)
func reset() -> void:
	current_user = {}
	selected_character = {}
	emit_signal("user_changed")
	emit_signal("character_changed")

# Is a user currently logged in?
func is_logged_in() -> bool:
	return current_user != {}

# Is a character selected?
func has_selected_character() -> bool:
	return selected_character != {}
