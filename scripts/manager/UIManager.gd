extends Node
class_name UIManager

@onready var character_button     = $HBoxContainer/CharacterButton
@onready var character_sheet      = $CharacterSheet

@onready var rank_up_button       = $HBoxContainer/RankUpButton
@onready var rank_up_panel        = $RankUpPanel

@onready var stat_tree_button     = $HBoxContainer/StatTreeButton
@onready var stat_tree_panel      = $SkillPathUI

@onready var inventory_button     = $HBoxContainer/InventoryButton
@onready var inventory_panel      = $InventoryPanel

@onready var skill_shop_button    = $HBoxContainer/SkillShopButton
@onready var skill_shop_panel     = $SkillShopPanel

@onready var tile_info_button     = $HBoxContainer/TileInfoButton
@onready var tile_info_panel      = $TileInfoPanel

@onready var map_button           = $HBoxContainer/MapButton
@onready var settings_button      = $HBoxContainer/SettingsButton

func _ready() -> void:
	# Connect UI button signals
	character_button.pressed.connect(_on_character_button_pressed)
	rank_up_button.pressed.connect(_on_rank_up_button_pressed)
	stat_tree_button.pressed.connect(_on_stat_tree_button_pressed)
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	skill_shop_button.pressed.connect(_on_skill_shop_button_pressed)
	tile_info_button.pressed.connect(_on_tile_info_button_pressed)
	map_button.pressed.connect(_on_map_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)

	tile_info_panel.action_selected.connect(_on_tile_action_selected)

	# Hide all panels at start
	_hide_all_panels()

# === Button Press Handlers ===

func _on_character_button_pressed():
	character_sheet.visible = !character_sheet.visible

func _on_rank_up_button_pressed():
	rank_up_panel.visible = !rank_up_panel.visible

func _on_stat_tree_button_pressed():
	stat_tree_panel.visible = !stat_tree_panel.visible

func _on_inventory_button_pressed():
	inventory_panel.visible = !inventory_panel.visible

func _on_skill_shop_button_pressed():
	skill_shop_panel.visible = !skill_shop_panel.visible

func _on_tile_info_button_pressed():
	tile_info_panel.visible = !tile_info_panel.visible

func _on_map_button_pressed():
	Global.switch_scene("res://scenes/WorldMap.tscn")

func _on_settings_button_pressed():
	print("Settings toggled (not implemented yet)")

# === Tile Info Handling ===

func show_tile_info(info: Dictionary, tile: Tile) -> void:
	tile_info_panel.show_info(info, tile)

func _on_tile_action_selected(action_name: String, tile: Tile) -> void:
	if tile == null:
		push_warning("No tile selected for action.")
		return

	match action_name:
		"Enter":
			if tile.enter_scene != "" and FileAccess.file_exists(tile.enter_scene):
				Global.switch_scene(tile.enter_scene)
			else:
				push_error("Invalid or missing enter_scene: " + tile.enter_scene)
		"Harvest":
			var result = tile.harvest_resource()
			if result:
				print("Harvested:", result)
			else:
				print("Resource still on cooldown.")
		"Claim Tile":
			print("Claiming tile not yet implemented.")

# === Panel Control Methods ===

func show_rank_up(rank: String) -> void:
	rank_up_panel.show()
	rank_up_panel.update_rank(rank)

func open_stat_tree() -> void:
	stat_tree_panel.show()

func hide_stat_tree() -> void:
	stat_tree_panel.hide()

func show_warning(msg: String) -> void:
	tile_info_panel.show_warning(msg)

func _hide_all_panels() -> void:
	character_sheet.hide()
	rank_up_panel.hide()
	stat_tree_panel.hide()
	inventory_panel.hide()
	skill_shop_panel.hide()
	tile_info_panel.hide()
