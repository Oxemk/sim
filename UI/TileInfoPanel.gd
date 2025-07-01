extends Control
class_name TileInfoPanel

@onready var name_lbl    = $Panel/VBoxContainer/TileNameLabel
@onready var type_lbl    = $Panel/VBoxContainer/TileTypeLabel
@onready var desc_lbl    = $Panel/VBoxContainer/TileDescriptionLabel
@onready var actions_ct  = $Panel/VBoxContainer/ActionsContainer
@onready var close_btn   = $Panel/VBoxContainer/CloseButton

signal action_selected(action_name: String, tile)

var _current_tile: Tile = null

func _ready():
	close_btn.pressed.connect(_on_close)
	hide()

# Pass in both the info dict and the tile instance
func show_info(data: Dictionary, tile: Tile) -> void:
	_current_tile = tile
	name_lbl.text = data.get("name", "Unknown")
	type_lbl.text = "Type: %s" % data.get("type", "Unknown")
	desc_lbl.text = data.get("description", "No description.")
	
	# Clear old buttons
	for child in actions_ct.get_children():
		child.queue_free()

	# Create a button for each action, capturing both action name and tile
	for action_name in data.get("available_actions", []):
		var btn = Button.new()
		btn.text = action_name
		btn.pressed.connect(Callable(self, "_on_action_pressed").bind(action_name))
		actions_ct.add_child(btn)

	show()

func show_warning(msg: String) -> void:
	_current_tile = null
	name_lbl.text = "⚠️ Warning"
	type_lbl.text = ""
	desc_lbl.text = msg

	# Remove any old action buttons
	for child in actions_ct.get_children():
		child.queue_free()

	show()

func _on_action_pressed(action_name: String) -> void:
	# Emit both the action and the tile back to the world/manager
	emit_signal("action_selected", action_name, _current_tile)
	hide()

func _on_close() -> void:
	hide()
