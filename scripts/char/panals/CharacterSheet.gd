extends Control
class_name CharacterSheet

# UI Nodes
@onready var name_label: Label               = $Panel/VBoxContainer/NameLabel
@onready var rank_label: Label               = $Panel/VBoxContainer/RankLabel
@onready var health_label: Label             = $Panel/VBoxContainer/HealthLabel
@onready var stamina_label: Label            = $Panel/VBoxContainer/StaminaLabel
@onready var mana_label: Label               = $Panel/VBoxContainer/ManaLabel
@onready var xp_label: Label                 = $Panel/VBoxContainer/XPLabel
@onready var currency_label: Label           = $Panel/VBoxContainer/CurrencyLabel
@onready var stat_label: Label               = $Panel/VBoxContainer/StatLabel
@onready var skills_label: VBoxContainer     = $Panel/VBoxContainer/HBoxContainer/ScrollContainer2/SkillsLabel
@onready var equipped_label: VBoxContainer   = $Panel/VBoxContainer/HBoxContainer/ScrollContainer/EquippedLabel
@onready var close_button: Button            = $Panel/VBoxContainer/CloseButton

# Dependencies
@onready var skill_db: Node                  = get_node("/root/SkillDB")
@onready var inventory: Node                 = get_node("/root/Inventory")
@onready var rank_manager: Node              = get_node("/root/RankManager")

# Player reference
var player: Node = null

func _ready() -> void:
	close_button.pressed.connect(hide)

# Assign the player and bind signals
func set_player(p: Node) -> void:
	player = p

	if player.has_signal("stats_changed"):
		player.stats_changed.connect(_update_stats)
	if player.has_signal("xp_changed"):
		player.xp_changed.connect(_update_xp)
	if player.has_signal("currencies_changed"):
		player.currencies_changed.connect(_update_currency)

	if inventory.has_signal("equipment_changed"):
		inventory.equipment_changed.connect(_update_equipped_skills)

	_refresh()

# Open UI and refresh content
func open() -> void:
	if player == null:
		push_warning("⚠ No player assigned to CharacterSheet")
		return
	show()
	_refresh()

# === Refresh all UI ===
func _refresh() -> void:
	_update_basic_info()
	_update_xp()
	_update_currency()
	_update_stats()
	_update_owned_skills()
	_update_equipped_skills()

# === Update Sections ===
func _update_basic_info() -> void:
	name_label.text = "Name: %s" % Global.current_character.get("name", "Unknown")
	rank_label.text = "Rank: %s" % player.ranks[player.rank_index]
	health_label.text = "Health: %d" % player.health
	stamina_label.text = "Stamina: %d" % player.stamina
	mana_label.text = "Mana: %d" % player.mana

func _update_xp() -> void:
	xp_label.text = "XP: %d / %d" % [player.get_available_xp(), player.xp_to_next]

func _update_currency() -> void:
	var text: String = ""
	for k in player.currencies.keys():
		var amount: int = player.currencies[k]
		text += "%s: %d\n" % [k.capitalize(), amount]
	currency_label.text = "Currency:\n" + text

func _update_stats() -> void:
	var stat_text: String = ""
	var stats: Array[String] = [
		"strength", "endurance", "dexterity", "intellect",
		"spirit", "charisma", "luck", "adaptability"
	]
	for stat in stats:
		var base: int = player.get(stat)
		var total: int = player.get_stat(stat)
		var bonus: int = total - base
		stat_text += "%s: %d (+%d)\n" % [stat.capitalize(), base, bonus]
	stat_label.text = stat_text

func _update_owned_skills() -> void:
	clear_container(skills_label)
	var owned: Array[String] = Global.current_user.get("owned_skills", [])
	for skill_id in owned:
		var row: HBoxContainer = create_skill_row(skill_id)
		skills_label.add_child(row)

func _update_equipped_skills() -> void:
	clear_container(equipped_label)
	for slot in inventory.equipped_skills.keys():
		var row: HBoxContainer = HBoxContainer.new()

		var slot_label: Label = Label.new()
		slot_label.text = "%s:" % slot.capitalize()
		row.add_child(slot_label)

		var skill_id: Variant = inventory.equipped_skills[slot]
		var skill_name: String = "Empty"
		if skill_id != null:
			skill_name = skill_db.get_skill_name(skill_id)

		var name_label: Label = Label.new()
		name_label.text = skill_name
		row.add_child(name_label)

		equipped_label.add_child(row)

# === Helpers ===
func clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

func create_skill_row(skill_id: String) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()

	var tex: Texture2D = skill_db.get_skill_icon(skill_id)
	if tex:
		var icon: TextureRect = TextureRect.new()
		icon.texture = tex
		icon.custom_minimum_size = Vector2(32, 32)
		row.add_child(icon)

	var label: Label = Label.new()
	label.text = skill_db.get_skill_name(skill_id)
	row.add_child(label)

	return row
