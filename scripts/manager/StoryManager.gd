extends Node

signal story_updated(id)

var current_story_id: String = ""
var completed_stories: Array = []
var story_flags: Dictionary = {}
var story_data: Dictionary = {}

func _ready():
	load_story_data()

func load_story_data():
	var f = FileAccess.open("res://data/story_data.json", FileAccess.READ)
	story_data = JSON.parse_string(f.get_as_text()).result

func start_story(id: String):
	current_story_id = id
	emit_signal("story_updated", id)

func complete_current_story():
	completed_stories.append(current_story_id)
	var next = story_data[current_story_id].get("next_steps", [])
	if next.size() > 0:
		start_story(next[0])

func set_flag(name: String, val: bool): story_flags[name] = val
func has_flag(name: String) -> bool: return story_flags.get(name, false)
func has_completed(id: String) -> bool: return id in completed_stories
