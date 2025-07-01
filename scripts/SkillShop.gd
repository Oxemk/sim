extends Control

@onready var pack_list         = $VBoxContainer/ScrollContainer2/PackList
@onready var description_label = $VBoxContainer/DescriptionLabel
@onready var unlock_button     = $VBoxContainer/UnlockButton
@onready var skill_list        = $VBoxContainer/ScrollContainer/SkillList

var player: Node = null
var inventory: Node = null

var current_user_data: Dictionary = {}
var selected_pack_id: String = ""
var selected_pack: Dictionary = {}

var skill_manager := SkillPackManager  # Autoload

func _ready():
	player = _find_node_recursive(get_tree().root, "Player")
	if player:
		inventory = player.get_node_or_null("Inventory")

	LoginManager.load_users()
	current_user_data = LoginManager.get_user(Global.current_username)

	if current_user_data.is_empty():
		printerr("❌ No current user found.")
		return

	_populate_shop()

	pack_list.item_selected.connect(_on_pack_selected)
	unlock_button.pressed.connect(_on_unlock_pack_pressed)

func _find_node_recursive(root: Node, name: String) -> Node:
	if root.name == name:
		return root
	for c in root.get_children():
		if c is Node:
			var found = _find_node_recursive(c, name)
			if found:
				return found
	return null

func _populate_shop():
	pack_list.clear()

	# Creation packs
	for id in skill_manager.get_creation_skill_packs().keys():
		var p = skill_manager.creation_packs[id]
		pack_list.add_item("[Creation] %s" % p["name"])
		pack_list.set_item_metadata(pack_list.get_item_count() - 1, {
			"type": "creation", "id": id
		})

	# Shop packs (standard, premium)
	for category in skill_manager.get_shop_skill_packs().keys():
		for p in skill_manager.shop_packs[category]:
			var pid = p["id"]
			var label = "[Shop:%s] %s" % [category.capitalize(), p["name"]]
			pack_list.add_item(label)
			pack_list.set_item_metadata(pack_list.get_item_count() - 1, {
				"type": "shop", "category": category, "id": pid
			})

func _on_pack_selected(idx: int):
	var meta = pack_list.get_item_metadata(idx)
	if not meta.has("id"):
		return

	selected_pack_id = meta["id"]

	if meta["type"] == "creation":
		selected_pack = skill_manager.creation_packs[selected_pack_id]
	else:
		selected_pack = {}
		for p in skill_manager.shop_packs[meta["category"]]:
			if p["id"] == selected_pack_id:
				selected_pack = p
				break

	if selected_pack.is_empty():
		description_label.text = "❌ Pack not found."
		unlock_button.disabled = true
		_clear_skill_list()
		return

	description_label.text = "%s\n\n%s\n\nCost: %d %s" % [
		selected_pack.get("name", "???"),
		selected_pack.get("description", ""),
		selected_pack.get("cost", 0),
		selected_pack.get("currency", "XP")
	]

	unlock_button.disabled = selected_pack_id in current_user_data.get("unlocked_packs", [])
	_show_skills()

func _clear_skill_list():
	for c in skill_list.get_children():
		c.queue_free()

func _show_skills():
	_clear_skill_list()

	for skill_id in selected_pack.get("skills", []):
		var owned = skill_id in current_user_data.get("owned_skills", [])
		var status = "✓" if owned else "(Buy)"
		var btn = Button.new()
		btn.text = "%s %s" % [skill_id.capitalize(), status]
		btn.disabled = owned
		btn.pressed.connect(func(): _on_buy_skill(skill_id))
		skill_list.add_child(btn)

func _on_buy_skill(skill_id: String):
	if not player or not inventory:
		description_label.text = "❌ Player or Inventory missing."
		return

	var cost = 0
	if selected_pack.has("skills_data"):
		cost = selected_pack["skills_data"].get(skill_id, {}).get("cost", 0)

	if player.unlock_skill_box(cost):
		current_user_data["owned_skills"].append(skill_id)
		inventory.add_item({"type": "skill", "id": skill_id})
		LoginManager.update_user(current_user_data)
		_show_skills()
	else:
		description_label.text = "❌ Not enough XP"

func _on_unlock_pack_pressed():
	if not player:
		description_label.text = "❌ Player missing."
		return

	var cost = selected_pack.get("cost", 0)
	if player.unlock_skill_box(cost):
		current_user_data["unlocked_packs"].append(selected_pack_id)
		LoginManager.update_user(current_user_data)
		unlock_button.disabled = true
		description_label.text += "\n✓ Pack unlocked!"
	else:
		description_label.text = "❌ Not enough XP"
