extends Control
# This is just a fullscreen black panel for fading

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate = Color(0, 0, 0, 0)  # start transparent
	visible = false
