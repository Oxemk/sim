extends Node
class_name SkillManager

@export var skills_path := "res://data/skills.json"

var skills_data: Dictionary = {}
var owned_packs: Array = []

func _ready():
	skills_data = _load_json(skills_path).get("AllSkills", {})

func _load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open %s" % path)
		return {}
	var content = file.get_as_text()
	var parsed = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON in %s" % path)
		return {}
	return parsed

func can_equip_skill(skill_id: String, inv: Inventory, player_stats: Dictionary) -> bool:
	if not skills_data.has(skill_id):
		return false
	var skill = skills_data[skill_id]
	# Check if player owns skill in inventory
	if not inv.has_skill(skill_id):
		return false
	# Check stat requirements
	if skill.has("stat_requirements"):
		for stat in skill.stat_requirements.keys():
			if player_stats.get(stat, 0) < skill.stat_requirements[stat]:
				return false
	return true

func cast_skill(skill_id: String, pos: Vector3) -> void:
	if not skills_data.has(skill_id):
		push_warning("Unknown skill: %s" % skill_id)
		return
	print("Casting %s at %s" % [skill_id, pos])

func get_skill_info(skill_id: String) -> Dictionary:
	return skills_data.get(skill_id, {})

func get_skill_rank(skill_id: String) -> String:
	var skill = get_skill_info(skill_id)
	return skill.get("skill_rank", "Unknown")
