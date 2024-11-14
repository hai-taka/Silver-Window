extends Node

var current_scene = null
var preserved_scene = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().root
	
	# Current scene is the last child of root
	current_scene = root.get_child(root.get_child_count() - 1)


func go_to_scene(path):
	# Defer the load to a later time, when we can be sure that no code
	# from the current scene is running
	call_deferred("_deferred_go_to_scene", path)


func _deferred_go_to_scene(path):
	# It is now safe to remove the current scene.
	current_scene.free()
	
	# Load the new scene.
	var s = ResourceLoader.load(path)
	
	# Instance the new scene.
	current_scene = s.instantiate()
	
	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)
	
	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene


func preserve_and_go_to_scene(path):
	# Switches scene without losing the current one.
	call_deferred("_deferred_preserve_and_go_to_scene", path)


func _deferred_preserve_and_go_to_scene(path):
	# Remove current scene without freeing it.
	preserved_scene = current_scene
	get_tree().root.remove_child(current_scene)
	
	# Load the new scene.
	var s = ResourceLoader.load(path)
	
	# Instance the new scene.
	current_scene = s.instantiate()
	
	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)
	
	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene


func go_to_preserved():
	# Free current scene and return to preserved one.
	call_deferred("_deferred_go_to_preserved")


func _deferred_go_to_preserved():
	# It is now safe to remove the current scene.
	current_scene.free()
	
	# Instance the new scene.
	current_scene = preserved_scene
	
	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)
	
	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene

