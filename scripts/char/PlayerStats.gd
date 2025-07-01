# res://managers/PlayerStats.gd
extends Node
class_name PlayerStats

@export var rank_manager: RankManager

signal rank_up_ready
signal rank_up_confirmed(new_rank:String)

var current_xp: int = 0
var can_rank_up: bool = false
var unspent_stat_points: int = 0

func add_xp(amount:int):
	current_xp += amount
	if rank_manager.can_rank_up(current_xp):
		can_rank_up = true
		emit_signal("rank_up_ready")

func confirm_rank_up():
	if not can_rank_up: return
	current_xp -= rank_manager.get_required_xp()
	rank_manager.rank_up()
	can_rank_up = false
	unspent_stat_points += 5
	emit_signal("rank_up_confirmed", rank_manager.get_current_rank())
