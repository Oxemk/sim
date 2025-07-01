extends Node3D
class_name World

@onready var spawn      = $SpawnPoint
@onready var player     = $Player
@onready var ui_manager = $UIManager
@onready var panel      = ui_manager.tile_info_panel

# remember the tile the user last clicked
var _last_clicked_tile: Tile = null

func _ready():
	player.global_transform.origin = spawn.global_transform.origin
	player.set_ui_manager(ui_manager)

	# hook up all the tile signals
	for tile in $TileMap.get_children():
		tile.tile_clicked.connect(_on_tile_clicked)
		tile.player_entered.connect(_on_player_entered)
		tile.player_warned.connect(_on_player_warned)
		tile.tile_discovered.connect(_on_tile_discovered)

	# listen for whatever action the user picks in the panel
	panel.action_selected.connect(_on_panel_action)

func _on_tile_clicked(tile: Tile) -> void:
	_last_clicked_tile = tile

	panel.show_info({
		"name":              tile.tile_name,
		"type":              tile.tile_type,
		"description":       tile.description,
		"available_actions": ["Enter"]
	})

func _on_panel_action(action_name: String) -> void:
	if action_name == "Enter" and _last_clicked_tile:
		var path = _last_clicked_tile.enter_scene
		if path != "" and FileAccess.file_exists(path):
			# Free current manually added scene
			if get_parent():
				queue_free()
				await get_tree().process_frame

			# Manual load and add with explicit type
			var new_scene: Node = load(path).instantiate()
			get_tree().root.add_child(new_scene)
			get_tree().current_scene = new_scene  # Optional but helpful
		else:
			push_error("World: cannot enter scene '%s'" % path)

	_last_clicked_tile = null

func _on_player_entered(tile: Tile) -> void:
	player.global_transform.origin = tile.global_transform.origin

func _on_tile_discovered(tile: Tile) -> void:
	print("Discovered tile:", tile.tile_name)

func _on_player_warned(tile: Tile, gap: int) -> void:
	ui_manager.show_warning("⚠️ %s recommended %d ranks higher" % [tile.tile_name, tile.recommended_rank])
