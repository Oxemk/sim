# CharacterManager.gd
extends Node


# Load a character into the world
func load_character(char_data: Dictionary) -> void:
	# Remove old UI/selection screens
	for child in get_tree().root.get_children():
		if child.name in ["CharacterSelection","UI"]:
			child.queue_free()

	# Instantiate the scene
	var scene = load(char_data.scene_path).instantiate()
	get_tree().root.add_child(scene)
	await get_tree().create_timer(0.1).timeout

	# Find the Player node
	var player = scene.get_node_or_null("Player")
	if not player:
		player = find_node_recursive(scene, "Player")

	# Position the player
	if player:
		var pos = char_data.position
		player.global_transform.origin = Vector3(pos[0],pos[1],pos[2])

# Recursively search for a node by name
func find_node_recursive(root: Node, name: String) -> Node:
	if root.name == name:
		return root
	for child in root.get_children():
		if child is Node:
			var found = find_node_recursive(child, name)
			if found:
				return found
	return null

# Save or update a character in the current user's record
func save_character(char_data: Dictionary) -> void:
	# Ensure users are loaded
	LoginManager.load_users()

	# Find the current user’s Dictionary in LoginManager.users
	var user = LoginManager.get_user(Global.current_username)
	if user.size() == 0:
		printerr("❌ save_character: user not found")
		return

	# Get or initialize the characters Array
	var char_array = user.get("characters", [])

	# Look for an existing character with the same id
	var idx = -1
	for i in range(char_array.size()):
		if char_array[i].get("id","") == char_data.get("id",""):
			idx = i
			break

	if idx >= 0:
		# Update existing
		char_array[idx] = char_data
	else:
		# Append new
		char_array.append(char_data)
	user["characters"] = char_array

	# Persist back to disk
	LoginManager.update_user(user)
