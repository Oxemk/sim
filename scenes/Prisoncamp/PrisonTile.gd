
extends Node3D


@export var tile_name: String        = "Unknown"
@export var tile_type: String        = "neutral"
@export var description: String      = ""
@export var recommended_rank: String = "f"
@export var required_rank: String    = "f"
@export var controlled_by: String    = "neutral"
@export var claimable: bool          = true

# Export as PackedScene without arguments
@export var enter_scene: PackedScene

signal tile_clicked(tile)
signal player_warned(tile, gap)
signal player_entered(tile)
signal tile_discovered(tile)
signal tile_claimed(tile, new_owner)

var discovered: bool = false

# Encounters
@export var encounter_rate: float       = 0.0
@export var creature_pool: Array[String] = []

# Resources
@export var resource_type: String    = ""
@export var resource_rarity: String  = "common"
@export var resource_cooldown: float = 300.0
var last_harvest_time: float         = 0.0

# Ecosystem
var species: Array   = []
var radiation_level: float = 0.0
@export var biome: String = "plains"

func _ready():
	add_to_group("TileMap")
	apply_biome_defaults()
	$InteractionArea.input_event.connect(_on_input_event)
	$InteractionArea.body_entered.connect(_on_body_entered)

func apply_biome_defaults():
	var file = FileAccess.open("res://data/tile_types.json", FileAccess.READ)
	var defs = JSON.parse_string(file.get_as_text())
	if typeof(defs) == TYPE_DICTIONARY and defs.has(biome):
		var data = defs[biome]
		radiation_level   = data.get("base_radiation", 0)
		resource_cooldown = data.get("resource_cooldown", resource_cooldown)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("tile_clicked", self)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	# Discovery
	if not discovered:
		discovered = true
		emit_signal("tile_discovered", self)

	# Rank check
	var req_idx = body.ranks.find(required_rank)
	if req_idx < 0 or body.rank_index < req_idx:
		emit_signal("player_warned", self, required_rank)
		return

	# Encounters (stub)
	_try_random_encounter(body)
	emit_signal("player_entered", self)

	# Scene transition
	if enter_scene:
		var scene_path = enter_scene.resource_path
		if scene_path != "":
			get_tree().change_scene_to_file(scene_path)

func _try_random_encounter(player):
	# TODO: implement random encounter logic
	pass

func harvest_resource():
	var now = Time.get_unix_time_from_system()
	if now - last_harvest_time < resource_cooldown:
		return null
	last_harvest_time = now
	return {
		"type":   resource_type,
		"rarity": resource_rarity
	}
