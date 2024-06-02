extends PopupMenu

@export var graph_edit: GraphEdit = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("New JSON", 7)
	add_separator("", 8)
	add_item("Save", 0)
	add_item("Save As...", 1)
	add_separator("", 3)
	add_item("Load", 4)
	add_submenu_item("Load Recent", "RecentFiles", 2)
	add_separator("", 5)
	add_item("Quit", 6)


func _on_id_pressed(id):
	match id:
		0: # Save
			graph_edit.save_json(false)
		1: # Save As
			graph_edit.save_json(true)
		4: # Load
			graph_edit.load_json()
		6: # Quit
			graph_edit.quit_editor()
		7: # New JSON
			graph_edit.prompt_to_clear_nodes()
