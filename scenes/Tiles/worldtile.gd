# res://scripts/Tile.gd
extends Node3D
class_name Tile

#── Tile Metadata ───────────────────────────────────────
@export var tile_name        : String = "Unknown"
@export var tile_type        : String = "neutral"     # e.g. "Wilderness", "Resource", "FactionHub"
@export var description      : String = ""
@export var recommended_rank : int    = 0             # warn if player is ≥3 ranks below
@export var required_rank    : int    = 0             # hard lock below this index
@export var controlled_by    : String = "neutral"
@export var claimable        : bool   = false
@export var enter_scene      : String = ""            # e.g. "res://scenes/WorldMap.tscn"

#── Resource Fields ─────────────────────────────────────
@export var resource_type    : String = ""            # e.g. "Wood", leave blank if none
@export var resource_rarity  : String = "common"
@export var resource_cooldown: float  = 300.0         # seconds between harvests
var _last_harvest_time       : float  = 0.0

#── Signals ──────────────────────────────────────────────
signal tile_clicked(tile: Tile)
signal player_warned(tile: Tile, gap: int)
signal player_entered(tile: Tile)
signal tile_discovered(tile: Tile)

var discovered: bool = false

func _ready() -> void:
	add_to_group("TileMap")
	$InteractionArea.input_event.connect(_on_input_event)
	$InteractionArea.body_entered.connect(_on_body_entered)

func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("tile_clicked", self)

func _on_body_entered(body) -> void:
	if not body.is_in_group("player"):
		return

	# First discovery
	if not discovered:
		discovered = true
		emit_signal("tile_discovered", self)

	# Warn if far below recommended
	var gap = recommended_rank - body.rank_index
	if gap >= 3:
		emit_signal("player_warned", self, gap)

	# Hard-lock if below required rank
	if body.rank_index < required_rank:
		return

	# Successful enter
	emit_signal("player_entered", self)


#── Called by your UI when player chooses “Harvest” ──────
func harvest_resource() -> Dictionary:
	var now = Time.get_unix_time_from_system()
	if now - _last_harvest_time < resource_cooldown:
		return {}  # cooldown not yet expired
	_last_harvest_time = now
	return {
		"type":   resource_type,
		"rarity": resource_rarity
	}
