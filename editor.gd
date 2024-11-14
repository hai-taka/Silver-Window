extends PopupMenu

@export var graph_edit: GraphEdit = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("Hide All Examples", 0)
#	add_check_item("Hide Graph Nodes", 1)
	add_separator("", 2)
	add_item("Run", 3)
	add_separator("", 4)
#	add_item("Clear Connections", 5)
#	add_item("Clear Nodes", 6)
	add_item("Reset Colors/Widths", 7)


func _on_id_pressed(id):
	match id:
		0: # Hide All Examples
			graph_edit.hide_examples()
#		1: # Hide Graph Nodes
#			toggle_item_checked(get_item_index(1))
#			graph_edit.hide_graph_nodes()
		3: # Run JSON
			graph_edit.run_json()
#		5: # Clear Connections
#			graph_edit.clear_all_connections()
#		6: # Clear Nodes
#			graph_edit.prompt_to_clear_nodes()
		7: # Reset Colors/Widths
			graph_edit.reset_colors_widths()
