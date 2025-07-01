extends Control
class_name SkillPathUI

@onready var tree_container = $Panel/ScrollContainer/tree_container
@onready var close_button = $Panel/CloseButton
@onready var info_label = $Panel/InfoLabel

var player: Node = null
var skill_path_manager: Node = null

func _ready():

	skill_path_manager = get_node("/root/SkillPathManager")

func set_player(p: Node) -> void:
	player = p

func open():
	if player == null or skill_path_manager == null:
		return
	show()
	_build_tree()

func _build_tree():
	tree_container.queue_free_children()

	for path in skill_path_manager.skill_boxes.keys():
		var path_label = Label.new()
		path_label.text = path.capitalize()
		path_label.add_theme_color_override("font_color", Color.GREEN)
		tree_container.add_child(path_label)

		for branch in skill_path_manager.skill_boxes[path].keys():
			var branch_label = Label.new()
			branch_label.text = "- %s" % branch.capitalize()
			tree_container.add_child(branch_label)

			for box in skill_path_manager.skill_boxes[path][branch]:
				var box_btn = Button.new()
				var box_id = box.get("id", "")
				var box_name = box.get("name", "Unknown")
				var box_desc = box.get("description", "")
				var required_xp = box.get("required_xp", 0)
				var xp_type = box.get("xp_type", "")
				var bonuses = box.get("stat_bonuses", {})

				var learned = skill_path_manager.is_box_learned(box_id)
				var can_learn = skill_path_manager.can_learn_box(box_id)

				box_btn.text = box_name + (" (✔)" if learned else "")
				box_btn.tooltip_text = "%s\nXP: %d %s\nBonuses: %s" % [
					box_desc, required_xp, xp_type, JSON.stringify(bonuses)
				]
				box_btn.disabled = learned or not can_learn

				# Ensure the correct box_id is passed
				box_btn.pressed.connect(Callable(self, "_learn_box").bind(box_id))
				tree_container.add_child(box_btn)

func _learn_box(box_id: String) -> void:
	if skill_path_manager.learn_box(box_id):
		info_label.text = "Learned box: %s" % box_id
		_build_tree()
	else:
		info_label.text = "Failed to learn box: %s" % box_id
