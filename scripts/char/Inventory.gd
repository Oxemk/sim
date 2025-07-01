extends Node


signal inventory_updated

var items: Array = []
var equipped_skills := {
	"slot_1": null,
	"slot_2": null,
	"slot_3": null,
	"slot_4": null
}

var currency := {"Coins":100, "gold":10}

func add_item(item: Dictionary) -> bool:
	if items.size() >= 30: return false
	items.append(item)
	inventory_updated.emit()
	return true

func has_skill(skill_id: String) -> bool:
	for i in items:
		if i.type == "skill" and i.id == skill_id:
			return true
	return false

func get_equipped_skills() -> Dictionary:
	return equipped_skills

func equip_skill(slot: String, skill_id: String) -> bool:
	if not has_skill(skill_id):
		return false
	equipped_skills[slot] = skill_id
	inventory_updated.emit()
	return true

func unequip_skill(slot: String) -> void:
	equipped_skills[slot] = null
	inventory_updated.emit()

func remove_currency(type: String, amount: int) -> bool:
	if currency.has(type) and currency[type] >= amount:
		currency[type] -= amount
		return true
	return false

func add_currency(type: String, amount: int) -> void:
	currency[type] = currency.get(type, 0) + amount

func get_currency(type: String) -> int:
	return currency.get(type, 0)
