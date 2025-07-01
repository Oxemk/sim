extends Node3D
class_name PrisonCamp

@onready var spawn = $SpawnPoint
@onready var player = $Player
@onready var ui_manager = $UIManager
@onready var panel = ui_manager.tile_info_panel

func _ready():
	# Spawn player at spawn point
	player.global_transform.origin = spawn.global_transform.origin
	
	# Pass the UIManager reference to the player
	player.set_ui_manager(ui_manager)

	# Connect tile signals
	for tile in $TileMap.get_children():
		tile.tile_clicked.connect(_on_tile_clicked)
		tile.player_entered.connect(_on_player_entered)
		tile.player_warned.connect(_on_player_warned)
		tile.tile_discovered.connect(_on_tile_discovered)

func _on_tile_clicked(tile):
	panel.show_info({
		"name": tile.tile_name,
		"type": tile.tile_type,
		"description": tile.description,
		"available_actions": ["Enter"]
	})
	panel.action_selected.disconnect_all()
	panel.action_selected.connect(func(action):
		if action == "Enter" and tile.enter_scene != "":
			get_tree().change_scene_to_file(tile.enter_scene)
	)

func _on_player_entered(tile):
	player.global_transform.origin = tile.global_transform.origin

func _on_tile_discovered(tile):
	print("Discovered:", tile.tile_name)

func _on_player_warned(tile, gap):
	ui_manager.show_warning("⚠️ %s recommended for Rank %s+" % [tile.tile_name, tile.recommended_rank])
