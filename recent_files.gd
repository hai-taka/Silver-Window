extends PopupMenu

@export var graph_edit: GraphEdit = null


# Called when the node enters the scene tree for the first time.
func _ready():
	for path in graph_edit.file_tracker.recent_files:
		add_item(path)
	
	add_separator()
	add_item("Clear")


func _on_graph_edit_recent_files_updated():
	clear()
	
	for path in graph_edit.file_tracker.recent_files:
		add_item(path)
	
	add_separator()
	add_item("Clear")


func _on_index_pressed(index):
	if index == item_count - 1:
		graph_edit.file_tracker.recent_files.clear()
		ResourceSaver.save(graph_edit.file_tracker, "res://resources/Data/visual_editor_recent_files.tres")
		clear()
		add_separator()
		add_item("Clear")
	else:
		graph_edit.load_json(get_item_text(index))
