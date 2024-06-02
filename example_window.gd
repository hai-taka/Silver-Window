extends PanelContainer

signal dragged(new_position : Vector2)
signal position_changed(new_position : Vector2)

var drag_position = null
var draggable = true
var center_x = false
var center_y = false

var auto_paired = false
var paired_offset = Vector2(10, 10)
var auto_type = 0 # 0 left, 1 right, 2 top left, 3 top right

@onready var ExamplePaired = get_parent().get_node("ExamplePaired")
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
			var max_pos = Vector2()
			var min_pos = Vector2()
			
			var top_margin = get_parent().get_parent().top_margin
			var bottom_margin = get_parent().get_parent().bottom_margin
			var left_margin = get_parent().get_parent().left_margin
			var right_margin = get_parent().get_parent().right_margin
			
			var top_left = Vector2(left_margin, top_margin)
			var bottom_right = Vector2(right_margin, bottom_margin)
			
			if not auto_paired:
				max_pos = get_viewport().get_visible_rect().size - size - bottom_right
				min_pos = top_left
			
			else:
				if auto_type == 0: # Left
					max_pos = get_viewport().get_visible_rect().size - size - bottom_right
					
					min_pos.x = ExamplePaired.size.x + paired_offset.x + top_left.x
					min_pos.y = ExamplePaired.size.y - size.y + top_left.y
				
				elif auto_type == 1: # Right
					max_pos.x = get_viewport().get_visible_rect().size.x - ExamplePaired.size.x - size.x - paired_offset.x - bottom_right.x
					max_pos.y = get_viewport().get_visible_rect().size.y - size.y - bottom_right.y
					
					min_pos.x = top_left.x
					min_pos.y = ExamplePaired.size.y - size.y + top_left.y
				
				elif auto_type == 2: # Top left
					max_pos = get_viewport().get_visible_rect().size - size - bottom_right
					
					min_pos.x = top_left.x
					min_pos.y = ExamplePaired.size.y + paired_offset.y + top_left.y
				
				elif auto_type == 3: # Top right
					max_pos = get_viewport().get_visible_rect().size - size - bottom_right
					
					min_pos.x = top_left.x
					min_pos.y = ExamplePaired.size.y + paired_offset.y + top_left.y
			
			box_pos = snapped(box_pos, Vector2(10, 10))
			
			if !center_x:
				box_pos.x = clampi(box_pos.x, min_pos.x, max_pos.x)
			
			else:
				if not auto_paired:
					box_pos.x = (get_viewport().get_visible_rect().size.x - size.x) / 2
				
				elif auto_type == 0:
					box_pos.x = (get_viewport().get_visible_rect().size.x - (size.x + paired_offset.x + ExamplePaired.size.x)) / 2 + ExamplePaired.size.x + paired_offset.x
				
				elif auto_type == 1:
					box_pos.x = (get_viewport().get_visible_rect().size.x - (size.x + paired_offset.x + ExamplePaired.size.x)) / 2
				
				else:
					box_pos.x = (get_viewport().get_visible_rect().size.x - size.x) / 2
			
			if !center_y:
				box_pos.y = clampi(box_pos.y, min_pos.y, max_pos.y)
			else:
				box_pos.y = (get_viewport().get_visible_rect().size.y - size.y) / 2
			
			global_position = box_pos
			dragged.emit(global_position)
