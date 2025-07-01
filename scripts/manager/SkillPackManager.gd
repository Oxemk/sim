extends Node

var skill_packs: Dictionary = {}
var creation_packs: Dictionary = {}
var shop_packs: Dictionary = {}

func _ready():
	var path = "res://data/skill_packs.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)

		if typeof(parsed) == TYPE_DICTIONARY:
			skill_packs = parsed

			if skill_packs.has("creation_packs"):
				creation_packs = skill_packs["creation_packs"]

			if skill_packs.has("shop_packs"):
				shop_packs = skill_packs["shop_packs"]

			print("✅ Skill packs loaded.")
		else:
			printerr("❌ Invalid JSON structure in skill_packs.json")
	else:
		printerr("❌ skill_packs.json not found at path: ", path)

func get_creation_skill_packs() -> Dictionary:
	return creation_packs

func get_shop_skill_packs() -> Dictionary:
	return shop_packs
