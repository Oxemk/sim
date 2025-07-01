extends Node
@export var fade_layer_scene: PackedScene
@export var loading_screen_scene: PackedScene

var current_scene: Node = null
var fade_layer: Control = null
var loading_screen: Control = null

# Call this to switch scenes with optional fade and loading
func switch_to(path: String, use_fade: bool = true, use_loading: bool = false) -> void:
	if not FileAccess.file_exists(path):
		push_error("Scene not found: %s" % path)
		return

	if use_fade:
		await _fade_out()

	if use_loading:
		_show_loading_screen()

	if current_scene:
		current_scene.queue_free()
		await get_tree().process_frame


	var new_scene := (load(path) as PackedScene).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene = new_scene

	if use_loading:
		_hide_loading_screen()

	if use_fade:
		await _fade_in()

	print("[SceneManager] Switched to scene: %s" % path)

#───── Fade Support ────────────────────────
func _fade_out() -> void:
	_ensure_fade_layer()
	fade_layer.visible = true
	fade_layer.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fade_layer, "modulate:a", 1.0, 0.5)
	await tween.finished

func _fade_in() -> void:
	_ensure_fade_layer()
	fade_layer.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_layer, "modulate:a", 0.0, 0.5)
	await tween.finished
	fade_layer.visible = false

func _ensure_fade_layer() -> void:
	if fade_layer == null or not is_instance_valid(fade_layer):
		fade_layer = fade_layer_scene.instantiate()
		get_tree().root.add_child(fade_layer)
		fade_layer.set_z_as_relative(false)
		fade_layer.z_index = 999
		fade_layer.visible = false

#───── Loading Screen Support ─────────────
func _show_loading_screen() -> void:
	if loading_screen_scene == null:
		return
	if loading_screen != null:
		return
	loading_screen = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_screen)
	loading_screen.set_z_as_relative(false)
	loading_screen.z_index = 998

func _hide_loading_screen() -> void:
	if loading_screen != null:
		loading_screen.queue_free()
		loading_screen = null
