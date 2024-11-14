extends PanelContainer

signal dragged(new_position : Vector2)

var drag_position = null
var draggable = false

@onready var stylebox = get_theme_stylebox("panel")


func _on_gui_input(event):
	if draggable:
		if event is InputEventMouseButton:
			if event.pressed:
				# Start dragging.
				drag_position = get_global_mouse_position() - global_position
				get_parent().move_to_front()
				move_to_front()
			
			else:
				# End dragging.
				drag_position = null
		
		if event is InputEventMouseMotion and drag_position:
			var box_pos = get_global_mouse_position() - drag_position
			
			var graph_edit = get_parent().get_parent()
			var top_left = Vector2(graph_edit.left_margin, graph_edit.top_margin)
			var bottom_right = Vector2(graph_edit.right_margin, graph_edit.bottom_margin)
			
			var max_pos = get_viewport().get_visible_rect().size - size - bottom_right
			var min_pos = top_left
			
			box_pos = snapped(box_pos, Vector2(10, 10))
			box_pos.x = clampi(box_pos.x, min_pos.x, max_pos.x)
			box_pos.y = clampi(box_pos.y, min_pos.y, max_pos.y)
			
			global_position = box_pos
			dragged.emit(global_position)

