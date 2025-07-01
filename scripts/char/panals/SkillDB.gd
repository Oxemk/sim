extends Node
class_name SkillDB

var skills: Dictionary = {}
var creation_packs: Dictionary = {}
var shop_packs: Dictionary = {}

func _ready() -> void:
	var path = "res://data/skills.json"
	var f = FileAccess.open(path, FileAccess.READ)
	var raw = f.get_as_text()
	f.close()

	var parsed = JSON.parse_string(raw)
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("result") and typeof(parsed["result"]) == TYPE_DICTIONARY:
		var data = parsed["result"]
		skills = data.get("skills", {})
		creation_packs = data.get("creation_packs", {})
		shop_packs = data.get("shop_packs", {})
	else:
		skills = {}
		creation_packs = {}
		shop_packs = {}

func get_skill(skill_id: String) -> Dictionary:
	return skills.get(skill_id, {})

func get_skill_name(skill_id: String) -> String:
	return get_skill(skill_id).get("name", skill_id)

func get_skill_icon(skill_id: String) -> Texture:
	var icon_path = get_skill(skill_id).get("icon", "")
	if icon_path == "":
		return null
	return load(icon_path)
