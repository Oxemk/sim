extends Control
class_name InventoryPanel

@onready var inventory_grid   = $Panel/VBoxContainer/ScrollContainer/InventoryGrid
@onready var equipped_grid    = $Panel/VBoxContainer/EquippedGrid
@onready var close_button     = $Panel/VBoxContainer/CloseButton
@onready var title_label      = $Panel/VBoxContainer/TitleLabel

const SLOT_SIZE = Vector2i(64, 64)
const COLUMNS = 5
const EQUIP_SLOTS = ["slot_1", "slot_2", "slot_3", "slot_4"]

func _ready():
	close_button.pressed.connect(func(): hide())
	Inventory.inventory_updated.connect(_refresh_inventory)
	_refresh_inventory()
	hide()

func _refresh_inventory():
	# Clear inventory grid
	for child in inventory_grid.get_children():
		child.queue_free()
	inventory_grid.columns = COLUMNS

	# Clear equipped grid
	for child in equipped_grid.get_children():
		child.queue_free()
	equipped_grid.columns = 4

	# Create skill items in inventory
	for item in Inventory.items:
		if item.get("type") == "skill":
			var slot = _create_inventory_slot(item)
			inventory_grid.add_child(slot)

	# Create equipped skill buttons
	for slot_name in EQUIP_SLOTS:
		var skill_id = Inventory.get_equipped_skills()[slot_name]
		var button = TextureButton.new()
		button.custom_minimum_size = SLOT_SIZE
		button.tooltip_text = "Empty (%s)" % slot_name.capitalize()

		if skill_id:
			var found = Inventory.items.filter(func(i): return i.get("id") == skill_id)
			if found.size() > 0:
				var skill = found[0]
				if skill.has("icon"):
					button.texture_normal = load(skill["icon"])
				button.tooltip_text = "%s (%s)" % [skill.get("name", "?"), slot_name.capitalize()]
			else:
				button.tooltip_text = "Unknown Skill (%s)" % slot_name

		button.pressed.connect(func(): _on_equipped_slot_pressed(slot_name))
		equipped_grid.add_child(button)

func _create_inventory_slot(item: Dictionary) -> Control:
	var button := TextureButton.new()
	button.custom_minimum_size = SLOT_SIZE

	if item.has("icon"):
		button.texture_normal = load(item["icon"])
	else:
		button.text = item.get("name", "?")

	button.tooltip_text = item.get("name", "Unknown Item")
	button.pressed.connect(func(): _on_item_pressed(item))
	return button

func _on_item_pressed(item: Dictionary) -> void:
	# Equip logic (assign to first empty slot)
	for slot_name in EQUIP_SLOTS:
		if Inventory.get_equipped_skills()[slot_name] == null:
			if Inventory.equip_skill(slot_name, item["id"]):
				print("Equipped %s to %s" % [item["name"], slot_name])
				return
	print("All slots are full!")

func _on_equipped_slot_pressed(slot_name: String) -> void:
	Inventory.unequip_skill(slot_name)
	print("Unequipped slot %s" % slot_name)
