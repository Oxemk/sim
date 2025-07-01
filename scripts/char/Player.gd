extends CharacterBody3D
class_name Player

#──── BASE STATS ───────────────────────────────────────────
@export var strength:     int = 5
@export var endurance:    int = 5
@export var dexterity:    int = 5
@export var intellect:    int = 5
@export var spirit:       int = 5
@export var charisma:     int = 5
@export var luck:         int = 5
@export var adaptability: int = 5

#──── XP / RANK SYSTEM ────────────────────────────────────
var total_xp:    int = 0
var spent_xp:    int = 0
var rank_index:  int = 0
@export var xp_to_next: int = 100
var ranks: Array = ["F","D-","D","D+","C-","C","C+","B-","B","B+","A-","A","A+","S","SS","X"]
signal rank_up(new_rank: String)
signal stats_changed
signal xp_changed
signal currencies_changed

#──── PLACEHOLDER PROPS ───────────────────────────────────
var player_name: String = ""
var health: int = 100
var stamina: int = 100
var mana: int = 50
var currencies: Dictionary = {"gold":0}

#──── SYSTEM NODES ────────────────────────────────────────
@onready var inventory           = $Inventory
@onready var skill_manager       = $SkillManager
@onready var skill_path_manager: Node = get_node("/root/SkillPathManager")
var ui_manager_instance: Node = null

#──── MOVEMENT ────────────────────────────────────────────
@export var move_speed: float = 1.0
var target_position: Vector3
var is_moving:      bool = false
var current_tile:   Tile = null

var hex_directions := {
	"up":          Vector3(0,0,-1),
	"up_right":    Vector3(1,0,-1),
	"down_right":  Vector3(1,0,0),
	"down":        Vector3(0,0,1),
	"down_left":   Vector3(-1,0,1),
	"up_left":     Vector3(-1,0,0)
}

func _ready() -> void:
	add_to_group("player")
	connect("rank_up", Callable(self, "_on_rank_up"))

func set_ui_manager(ui_node: Node) -> void:
	ui_manager_instance = ui_node

#──── LOAD FROM JSON CHARACTER DICT ────────────────────────

func load_from_data(data: Dictionary) -> void:
	player_name = data.get("name", "Unknown")
	total_xp = int(data.get("xp", 0))
	spent_xp = 0
	rank_index = ranks.find(data.get("rank", "F").to_upper())
	xp_to_next = int(data.get("xp_to_next", xp_to_next))

	var sdict: Dictionary = data.get("stats", {})
	const ALLOWED_STATS := ["strength", "endurance", "dexterity", "intellect", "spirit", "charisma", "luck", "adaptability"]
	for stat_name in sdict.keys():
		if stat_name in ALLOWED_STATS:
			self.set(stat_name, int(sdict[stat_name]))

	health = endurance * 10
	stamina = endurance * 10
	mana = intellect * 10

	emit_signal("stats_changed")
	emit_signal("xp_changed")
	emit_signal("currencies_changed")

#──── STAT ACCESS WITH SKILL PATH BONUSES ─────────────────
func get_stat(stat_name: String) -> int:
	var base_value: int = get(stat_name)
	var bonus: int = 0
	if skill_path_manager.has_method("get_total_stat_bonuses"):
		bonus = skill_path_manager.get_total_stat_bonuses().get(stat_name, 0)
	return base_value + bonus

#──── XP POOL & RANK METHODS ───────────────────────────────
func get_available_xp() -> int:
	return total_xp - spent_xp

func add_xp(amount: int) -> void:
	total_xp += amount
	emit_signal("xp_changed")
	_check_auto_rank_up()

func _check_auto_rank_up() -> void:
	while get_available_xp() >= xp_to_next and rank_index < ranks.size() - 1:
		perform_rank_up()

func perform_rank_up() -> void:
	spent_xp += xp_to_next
	rank_index += 1
	xp_to_next = _calc_xp_threshold(rank_index)
	emit_signal("rank_up", ranks[rank_index])
	emit_signal("xp_changed")

func _calc_xp_threshold(idx: int) -> int:
	return int(100 * pow(1.5, idx))

func _on_rank_up(new_rank: String) -> void:
	if ui_manager_instance:
		ui_manager_instance.show_rank_up(new_rank)

#──── MOVEMENT & TILE INTERACTIONS ────────────────────────
func _physics_process(delta: float) -> void:
	if is_moving:
		global_transform.origin = global_transform.origin.move_toward(target_position, move_speed * delta)
		if global_transform.origin.distance_to(target_position) < 0.05:
			global_transform.origin = target_position
			is_moving = false
	else:
		_handle_movement()

func _handle_movement() -> void:
	var mv = Vector3.ZERO
	for dir in hex_directions.keys():
		if Input.is_action_just_pressed("move_%s" % dir):
			mv += hex_directions[dir]
	if mv != Vector3.ZERO:
		var next_pos = global_transform.origin + mv.normalized() * move_speed
		var tile = _get_tile_at_position(next_pos)
		if tile:
			target_position = tile.global_transform.origin
			is_moving = true
			_on_enter_tile(tile)

func _get_tile_at_position(pos: Vector3) -> Tile:
	var closest: Tile = null
	var min_d = INF
	for t in get_tree().get_nodes_in_group("TileMap"):
		var tile := t as Tile
		var d = pos.distance_to(tile.global_transform.origin)
		if d < min_d:
			min_d = d
			closest = tile
	return closest if min_d < move_speed * 0.75 else null

func _on_enter_tile(tile: Tile) -> void:
	if tile == current_tile:
		return
	current_tile = tile
	tile.emit_signal("player_entered", tile)
	tile.emit_signal("tile_discovered", tile)

	var info := {
		"name": tile.tile_name,
		"type": tile.tile_type,
		"description": tile.description,
		"recommended_rank": tile.recommended_rank,
		"required_rank": tile.required_rank,
		"controlled_by": tile.controlled_by,
		"claimable": tile.claimable,
		"available_actions": _get_tile_actions(tile)
	}
	if tile.enter_scene != "":
		info["enter_scene"] = tile.enter_scene
	ui_manager_instance.show_tile_info(info, tile)

func _get_tile_actions(tile: Tile) -> Array:
	var actions := []
	if tile.claimable and tile.controlled_by != Global.current_character.get("faction","Outcasts"):
		actions.append("Claim Tile")
	if tile.resource_type != "":
		actions.append("Harvest")
	if tile.enter_scene != "":
		actions.append("Enter")
	return actions
