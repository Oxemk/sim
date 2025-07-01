extends Node

var day_time := 0.0
var world_day := 0
var ecosystem_tiles := []
var ai_memory_tree := {}
const DAY_LENGTH := 300.0

func _ready():
	ecosystem_tiles = get_tree().get_nodes_in_group("TileMap")
	_load_memory_tree()

func _process(delta):
	day_time += delta
	if day_time >= DAY_LENGTH:
		day_time = 0
		world_day += 1
		_on_new_day()

func _on_new_day():
	_update_ecosystem()
	_trigger_world_events()
	_adapt_factions()
	_evolve_creatures()
	_save_memory_tree()

func _update_ecosystem():
	for tile in ecosystem_tiles:
		tile.update_ecosystem(1.0)

func _evolve_creatures():
	for tile in ecosystem_tiles:
		if tile.radiation_level > 50:
			print("⚠️ Mutation at %s" % tile.tile_name)

func _trigger_world_events():
	if world_day % 14 == 0:
		print("🌑 Eclipse begins!")
	if randf() < 0.1:
		print("👹 Roaming boss spawned!")

func _adapt_factions():
	# stub
	pass

func _load_memory_tree():
	if FileAccess.file_exists("user://memory_tree.json"):
		var f = FileAccess.open("user://memory_tree.json", FileAccess.READ)
		ai_memory_tree = JSON.parse_string(f.get_as_text()).result
	else:
		ai_memory_tree = {"FactionA": {}, "Outcasts": {}}

func _save_memory_tree():
	var f = FileAccess.open("user://memory_tree.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(ai_memory_tree, "  "))
