extends Control

@onready var name_label = $NameLabel
@onready var rank_label = $RankLabel
@onready var desc_label = $DescriptionLabel
@onready var stats_container = $StatsContainer

func show_skill(skill_data: Dictionary) -> void:
	name_label.text = skill_data.get("name", "Unknown Skill")
	rank_label.text = "Rank: %s" % skill_data.get("skill_rank", "N/A")
	desc_label.text = skill_data.get("description", "No description.")
	
	# Clear old stat requirement labels
	for child in stats_container.get_children():
		child.queue_free()
	
	if skill_data.has("stat_requirements"):
		for stat_name in skill_data.stat_requirements.keys():
			var val = skill_data.stat_requirements[stat_name]
			var lbl = Label.new()
			lbl.text = "%s: %d" % [stat_name.capitalize(), val]
			stats_container.add_child(lbl)
	show()

func hide_tooltip():
	hide()
