extends Node

# Loaded skill boxes grouped by path -> branch -> boxes
var skill_boxes: Dictionary = {}

# Player learned boxes IDs (strings)
var learned_boxes: Array = []

# XP pools by type, e.g. {"survivor": 500, "hunter": 300, ...}
var xp_pools: Dictionary = {}

# Signals
signal box_learned(box_id: String)

func _ready():
	_load_skill_boxes()

# Load skill boxes from JSON file into nested dictionary structure
func _load_skill_boxes():
	var file_path := "res://data/skill_path.json"
	if not FileAccess.file_exists(file_path):
		push_error("SkillPathManager: skill_path.json not found")
		return

	var file := FileAccess.open(file_path, FileAccess.READ)
	var text := file.get_as_text()
	var parsed: Array = JSON.parse_string(text)

	if parsed.size() != 2:
		push_error("SkillPathManager: Unexpected JSON parse result")
		return

	var err_code: int = parsed[0]
	var result: Variant = parsed[1]

	if err_code != OK:
		push_error("SkillPathManager: JSON parse error code: %d" % err_code)
		return

	if typeof(result) != TYPE_ARRAY:
		push_error("SkillPathManager: JSON result is not an array")
		return

	# Convert array of boxes into nested dict path -> branch -> [boxes]
	skill_boxes.clear()
	for box in result:
		if typeof(box) != TYPE_DICTIONARY:
			continue
		var path: String = box.get("path", "")
		var branch: String = box.get("branch", "")
		if not skill_boxes.has(path):
			skill_boxes[path] = {}
		if not skill_boxes[path].has(branch):
			skill_boxes[path][branch] = []
		skill_boxes[path][branch].append(box)

# Returns the box Dictionary by ID or null if not found
func find_box(box_id: String):
	for path in skill_boxes.values():
		for branch in path.values():
			for box in branch:
				if box.get("id", "") == box_id:
					return box
	return null

# Returns true if box is already learned
func is_box_learned(box_id: String) -> bool:
	return box_id in learned_boxes

# Checks if player has enough XP in box's xp_type to learn it
func can_learn_box(box_id: String) -> bool:
	var box = find_box(box_id)
	if box == null:
		return false
	if is_box_learned(box_id):
		return false

	# Check XP requirement
	var xp_type: String = box.get("xp_type", "")
	var required: int = box.get("required_xp", 0)
	var current_xp: int = xp_pools.get(xp_type, 0)
	if current_xp < required:
		return false

	# Check other requirements (simplified)
	for req in box.get("requirements", []):
		if not _check_requirement(req):
			return false

	return true

# Dummy requirement check (expand as needed)
func _check_requirement(req: Dictionary) -> bool:
	# Example: check if another box is learned or a stat threshold
	# For now, always true
	return true

# Learn a box, deduct XP, add stat bonuses, emit signal
func learn_box(box_id: String) -> bool:
	if not can_learn_box(box_id):
		return false

	var box = find_box(box_id)
	if box == null:
		return false

	# Deduct XP
	var xp_type: String = box.get("xp_type", "")
	var required: int = box.get("required_xp", 0)
	xp_pools[xp_type] = max(0, xp_pools.get(xp_type, 0) - required)

	# Add to learned
	learned_boxes.append(box_id)

	emit_signal("box_learned", box_id)
	return true

# Returns total stat bonuses from all learned boxes
func get_total_stat_bonuses() -> Dictionary:
	var total_stats := {
		"strength": 0, "endurance": 0, "dexterity": 0,
		"intellect": 0, "spirit": 0, "charisma": 0,
		"luck": 0, "adaptability": 0
	}
	for box_id in learned_boxes:
		var box = find_box(box_id)
		if box == null:
			continue
		var bonuses = box.get("stat_bonuses", {})
		for stat in bonuses.keys():
			if total_stats.has(stat):
				total_stats[stat] += int(bonuses[stat])
	return total_stats

# Add XP of a specific type
func add_xp(xp_type: String, amount: int) -> void:
	if xp_type == "":
		return
	xp_pools[xp_type] = xp_pools.get(xp_type, 0) + amount

# Get current XP pool of a type
func get_xp(xp_type: String) -> int:
	return xp_pools.get(xp_type, 0)

# Reset all learned boxes and XP pools (for respec)
func reset_all() -> void:
	learned_boxes.clear()
	xp_pools.clear()
