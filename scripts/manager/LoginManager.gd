# LoginManager.gd
extends Node


const USERS_FILE := "user://data/users.json"
var users: Array = []

func _ready() -> void:
	load_users()

func load_users() -> void:
	if not FileAccess.file_exists(USERS_FILE):
		users = []
		return
	var f    = FileAccess.open(USERS_FILE, FileAccess.READ)
	var text = f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	# In Godot 4, parse_string returns the raw Variant.
	# If your file is an Array of users, typeof(parsed)==TYPE_ARRAY
	if typeof(parsed) == TYPE_ARRAY:
		users = parsed
	else:
		users = []

func save_users() -> void:
	var dir = "user://data"
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_absolute(dir)
	var f = FileAccess.open(USERS_FILE, FileAccess.WRITE)
	f.store_string(JSON.stringify(users, "\t"))
	f.close()

func authenticate(username: String, password: String) -> bool:
	for u in users:
		if u.get("username", "") == username and u.get("password", "") == password:
			return true
	return false

func register_user(username: String, password: String) -> bool:
	for u in users:
		if u.get("username", "") == username:
			return false
	var new_user = {
		"username": username,
		"password": password,
		"characters": [],
		"owned_skills": [],
		"unlocked_packs": []
	}
	users.append(new_user)
	save_users()
	return true

func get_user(username: String) -> Dictionary:
	for u in users:
		if u.get("username", "") == username:
			return u
	return {}

func update_user(updated_user: Dictionary) -> void:
	for i in range(users.size()):
		if users[i].get("username", "") == updated_user.get("username", ""):
			users[i] = updated_user
			save_users()
			return
	# not found → append
	users.append(updated_user)
	save_users()
