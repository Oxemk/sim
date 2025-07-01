extends Control

@onready var username_input = $VBoxContainer/Username
@onready var password_input = $VBoxContainer/Password
@onready var status_label = $VBoxContainer/StatusLabel


func _on_login_button_pressed() -> void:
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	if LoginManager.authenticate(username, password):
		# ←── Set the global username (and flag) here!
		Global.current_username = username
		Global.is_logged_in = true

		status_label.text = "Login successful!"
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://UI/CharacterSelection.tscn")
	else:
		status_label.text = "Invalid username or password."


func _on_register_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/RegisterScreen.tscn")
