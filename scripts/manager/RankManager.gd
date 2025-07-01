extends Node

var rank_data: Array = []
var current_rank_index: int = 0

func _ready():
	load_rank_data()

func load_rank_data():
	var f = FileAccess.open("res://data/rank_data.json", FileAccess.READ)
	var parsed = JSON.parse_string(f.get_as_text())
	rank_data = parsed if typeof(parsed) == TYPE_ARRAY else []

func get_current_rank() -> String:
	return rank_data[current_rank_index]["rank"]

func get_required_xp() -> int:
	return rank_data[current_rank_index]["xp_required"]

func can_rank_up(current_xp: int) -> bool:
	return current_xp >= get_required_xp()

func rank_up():
	if current_rank_index < rank_data.size() - 1:
		current_rank_index += 1

func get_next_rank_name() -> String:
	return rank_data[current_rank_index + 1]["rank"] if current_rank_index + 1 < rank_data.size() else "MAX"
func get_rank_by_xp(xp: int) -> String:
	var last_rank: String = rank_data[0]["rank"]
	for rank_entry in rank_data:
		if xp < rank_entry["xp_required"]:
			break
		last_rank = rank_entry["rank"]
	return last_rank
