extends Control

# UI Nodes
@onready var name_input       = $VBoxContainer/NameInput
@onready var race_select      = $VBoxContainer/RaceSelect  # Cosmetic only
@onready var pack_selector    = $VBoxContainer/PackSelector
@onready var preview_panel    = $VBoxContainer/PackPreview
@onready var create_button    = $VBoxContainer/CreateButton
@onready var status_label     = $VBoxContainer/StatusLabel

# Stat Nodes
@onready var remaining_label  = $StatBox/RemainingLabel
@onready var strength_value   = $StatBox/StrengthBox/Value
@onready var endurance_value  = $StatBox/EnduranceBox/Value
@onready var dexterity_value  = $StatBox/DexterityBox/Value
@onready var intellect_value  = $StatBox/IntellectBox/Value
@onready var spirit_value     = $StatBox/SpiritBox/Value
@onready var charisma_value   = $StatBox/CharismaBox/Value
@onready var luck_value       = $StatBox/LuckBox/Value
@onready var adaptability_value = $StatBox/AdaptabilityBox/Value

# Stat Buttons
@onready var strength_plus      = $StatBox/StrengthBox/PlusButton
@onready var strength_minus     = $StatBox/StrengthBox/MinusButton
@onready var endurance_plus     = $StatBox/EnduranceBox/PlusButton
@onready var endurance_minus    = $StatBox/EnduranceBox/MinusButton
@onready var dexterity_plus     = $StatBox/DexterityBox/PlusButton
@onready var dexterity_minus    = $StatBox/DexterityBox/MinusButton
@onready var intellect_plus     = $StatBox/IntellectBox/PlusButton
@onready var intellect_minus    = $StatBox/IntellectBox/MinusButton
@onready var spirit_plus        = $StatBox/SpiritBox/PlusButton
@onready var spirit_minus       = $StatBox/SpiritBox/MinusButton
@onready var charisma_plus      = $StatBox/CharismaBox/PlusButton
@onready var charisma_minus     = $StatBox/CharismaBox/MinusButton
@onready var luck_plus          = $StatBox/LuckBox/PlusButton
@onready var luck_minus         = $StatBox/LuckBox/MinusButton
@onready var adaptability_plus  = $StatBox/AdaptabilityBox/PlusButton
@onready var adaptability_minus = $StatBox/AdaptabilityBox/MinusButton

# Constants
const MAX_START_CHARACTERS = 2
const STAT_POINTS          = 30

# State
var stats = {
	"strength":     5,
	"endurance":    5,
	"dexterity":    5,
	"intellect":    5,
	"spirit":       5,
	"charisma":     5,
	"luck":         5,
	"adaptability": 5
}
var remaining_points = STAT_POINTS
var selected_skill_pack: String = ""

# Autoload managers
var rank_manager = RankManager
var pack_manager = SkillPackManager

func _ready():
	# Populate race dropdown (cosmetic only)
	for race in ["Human","Celestial","Purgatory","Hellborn"]:
		race_select.add_item(race)

	# Connect stat buttons
	strength_plus.pressed.connect(func(): _modify_stat("strength", +5))
	strength_minus.pressed.connect(func(): _modify_stat("strength", -5))
	endurance_plus.pressed.connect(func(): _modify_stat("endurance", +5))
	endurance_minus.pressed.connect(func(): _modify_stat("endurance", -5))
	dexterity_plus.pressed.connect(func(): _modify_stat("dexterity", +5))
	dexterity_minus.pressed.connect(func(): _modify_stat("dexterity", -5))
	intellect_plus.pressed.connect(func(): _modify_stat("intellect", +5))
	intellect_minus.pressed.connect(func(): _modify_stat("intellect", -5))
	spirit_plus.pressed.connect(func(): _modify_stat("spirit", +5))
	spirit_minus.pressed.connect(func(): _modify_stat("spirit", -5))
	charisma_plus.pressed.connect(func(): _modify_stat("charisma", +5))
	charisma_minus.pressed.connect(func(): _modify_stat("charisma", -5))
	luck_plus.pressed.connect(func(): _modify_stat("luck", +5))
	luck_minus.pressed.connect(func(): _modify_stat("luck", -5))
	adaptability_plus.pressed.connect(func(): _modify_stat("adaptability", +5))
	adaptability_minus.pressed.connect(func(): _modify_stat("adaptability", -5))

	# Load creation-only skill packs into buttons
	_load_creation_packs()

	# Connect create button
	create_button.pressed.connect(_on_create_button_pressed)

	update_ui()

func _load_creation_packs():
	var packs = pack_manager.get_creation_skill_packs()
	print("Loaded packs: ", packs)  # Debug
	for pack_id in packs.keys():
		var data = packs[pack_id]
		var btn = Button.new()
		btn.text = data.name
		btn.icon = load(data.icon)
		# bind the pack_id properly
		btn.pressed.connect(Callable(self, "_on_pack_selected").bind(pack_id))
		pack_selector.add_child(btn)

func _on_pack_selected(pack_id: String):
	selected_skill_pack = pack_id
	_update_pack_preview()

func _update_pack_preview():
	# Clear previous preview
	for child in preview_panel.get_children():
		child.queue_free()

	if not pack_manager.creation_packs.has(selected_skill_pack):
		return

	var data = pack_manager.creation_packs[selected_skill_pack]
	var desc = Label.new()
	desc.text = data.description
	preview_panel.add_child(desc)
	for skill in data.skills:
		var lbl = Label.new()
		lbl.text = skill
		preview_panel.add_child(lbl)

func update_ui():
	remaining_label.text         = "Remaining Points: %d" % remaining_points
	strength_value.text          = str(stats["strength"])
	endurance_value.text         = str(stats["endurance"])
	dexterity_value.text         = str(stats["dexterity"])
	intellect_value.text         = str(stats["intellect"])
	spirit_value.text            = str(stats["spirit"])
	charisma_value.text          = str(stats["charisma"])
	luck_value.text              = str(stats["luck"])
	adaptability_value.text      = str(stats["adaptability"])
	status_label.text            = ""

func _modify_stat(stat_name: String, delta: int):
	if delta > 0 and remaining_points >= 5 and stats[stat_name] + 5 <= 15:
		stats[stat_name] += 5
		remaining_points -= 5
	elif delta < 0 and stats[stat_name] > 5:
		stats[stat_name] -= 5
		remaining_points += 5
	update_ui()

func _on_create_button_pressed():
	var name = name_input.text.strip_edges()
	if name == "":
		status_label.text = "Name is required."
		return
	if remaining_points > 0:
		status_label.text = "Use all stat points."
		return
	if selected_skill_pack == "":
		status_label.text = "Select a skill pack."
		return

	# Build new character
	var creation_packs = pack_manager.get_creation_skill_packs()
	var first_skill = creation_packs[selected_skill_pack].skills[0]
	var new_char = {
		"id": str(Time.get_unix_time_from_system()),
		"name": name,
		"race": race_select.get_selected_id(),  # Cosmetic only
		"rank": rank_manager.get_current_rank(),
		"xp": 0,
		"scene_path": "res://scenes/Prisoncamp/prisoncampmap.tscn",
		"position": [0.0,0.0,0.0],
		"stats": stats.duplicate(),
		"unlocked_skill_packs": [selected_skill_pack],
		"unlocked_skills": [first_skill],
		"inventory": []
	}

	# Fetch and update the current user
	LoginManager.load_users()
	var user = LoginManager.get_user(Global.current_username)
	if typeof(user) == TYPE_DICTIONARY:
		var chars = user.get("characters", [])
		chars.append(new_char)
		user["characters"] = chars
		LoginManager.update_user(user)
		# Finally go back to selection
		get_tree().change_scene_to_file("res://UI/CharacterSelection.tscn")
	else:
		status_label.text = "❌ User record not found."
