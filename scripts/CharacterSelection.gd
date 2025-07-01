# CharacterSelection.gd
extends Control

const MAX_START_CHARACTERS = 2

@onready var character_list = $VBoxContainer/CharacterList
@onready var status_label   = $VBoxContainer/StatusLabel
@onready var btn_select     = $VBoxContainer/SelectButton
@onready var btn_create     = $VBoxContainer/CreateButton
@onready var btn_delete     = $VBoxContainer/DeleteButton

var characters: Array = []
var ranks: Array = [
	"F","D-","D","D+","C-","C","C+",
	"B-","B","B+","A-","A","A+","S","SS","X"
]

func _ready() -> void:
	btn_select.pressed.connect(_on_select_pressed)
	btn_create.pressed.connect(_on_create_pressed)
	btn_delete.pressed.connect(_on_delete_pressed)
	_load_characters()

func _load_characters() -> void:
	# Refresh from disk
	LoginManager.load_users()

	character_list.clear()
	characters.clear()

	var user = LoginManager.get_user(Global.current_username)
	if typeof(user) != TYPE_DICTIONARY or user.size() == 0:
		status_label.text = "No user found."
		btn_create.disabled = false  # or true if you want to block
		return
	status_label.text = ""

	var chars = user.get("characters", [])
	btn_create.disabled = chars.size() >= MAX_START_CHARACTERS

	if typeof(chars) != TYPE_ARRAY or chars.size() == 0:
		status_label.text = "No characters. Tap Create to make one!"
		return

	for c in chars:
		var idx  = c.get("rank_index", 0)
		var rank = ranks[idx] if idx < ranks.size() else "D-"
		var name = c.get("name","?")
		character_list.add_item("%s (Rank %s)" % [name, rank])
		characters.append(c)

func _save_characters() -> void:
	var user = LoginManager.get_user(Global.current_user_id)
	if typeof(user) != TYPE_DICTIONARY or user.size() == 0:
		return
	user["characters"] = characters
	LoginManager.update_user(user)

func _on_select_pressed() -> void:
	var sel = character_list.get_selected_items()
	if sel.size() == 0:
		return
	Global.current_character = characters[sel[0]]
	CharacterManager.load_character(Global.current_character)

func _on_create_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/CharacterCreation.tscn")

func _on_delete_pressed() -> void:
	var sel = character_list.get_selected_items()
	if sel.size() == 0:
		return
	characters.remove_at(sel[0])
	_save_characters()
	_load_characters()
