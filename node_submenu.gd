extends PopupMenu

@export var graph_edit: GraphEdit = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("New Dialogue Node", 0)
	add_item("New Picture Node", 1)
	#add_item("New Change Node", 4)
	add_item("New Update Node", 2)
	add_item("New Transition Node", 3)


func _on_id_pressed(id):
	match id:
		0: # New Dialogue Node
			if graph_edit.right_click_location != null:
				graph_edit.new_dialogue_node(true, graph_edit.right_click_location)
				graph_edit.right_click_location = null
			else:
				graph_edit.new_dialogue_node()
		1: # New Picture Node
			if graph_edit.right_click_location != null:
				graph_edit.new_picture_node(true, graph_edit.right_click_location)
				graph_edit.right_click_location = null
			else:
				graph_edit.new_picture_node()
		2: # New Move Node
			if graph_edit.right_click_location != null:
				graph_edit.new_move_node(true, graph_edit.right_click_location)
				graph_edit.right_click_location = null
			else:
				graph_edit.new_move_node()
		3: # New Transition Node
			if graph_edit.right_click_location != null:
				graph_edit.new_transition_node(true, graph_edit.right_click_location)
				graph_edit.right_click_location = null
			else:
				graph_edit.new_transition_node()
#		4: # New Change Node
#			if graph_edit.right_click_location != null:
#				graph_edit.new_change_node(true, graph_edit.right_click_location)
#				graph_edit.right_click_location = null
#			else:
#				graph_edit.new_change_node()
