extends Control
class_name RankUpPanel

@onready var current_rank_label = $Panel/VBoxContainer/CurrentRankLabel
@onready var next_rank_label    = $Panel/VBoxContainer/NextRankLabel
@onready var xp_label           = $Panel/VBoxContainer/XPLabel
@onready var confirm_button     = $Panel/VBoxContainer/ConfirmButton
@onready var close_button       = $Panel/VBoxContainer/closeButton

func _ready():
	visible = false
	confirm_button.pressed.connect(_on_confirm_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _process(_delta):
	if visible:
		update_rank_display()

func update_rank_display():
	var current_xp = Global.get_current_character_xp()
	var can_rank = RankManager.can_rank_up(current_xp)

	current_rank_label.text = "Current Rank: %s" % RankManager.get_current_rank()
	next_rank_label.text = "Next Rank: %s" % RankManager.get_next_rank_name()
	xp_label.text = "Total XP: %d" % current_xp
	confirm_button.disabled = not can_rank

func _on_confirm_pressed():
	if RankManager.can_rank_up(Global.get_current_character_xp()):
		RankManager.rank_up()
	Global.current_character["rank"] = RankManager.get_current_rank()
	update_rank_display()

func _on_close_pressed():
	hide()
