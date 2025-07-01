extends Control

@onready var username_input = $VBoxContainer/Username
@onready var password_input = $VBoxContainer/Password
@onready var status_label = $VBoxContainer/StatusLabel


func _on_confirm_button_pressed() -> void:
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	if username == "" or password == "":
		status_label.text = "Username and password cannot be empty."
		return

	if LoginManager.register_user(username, password):
		status_label.text = "Account created!"
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://UI/LoginScreen.tscn")
	else:
		status_label.text = "Username already exists."


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/LoginScreen.tscn")
