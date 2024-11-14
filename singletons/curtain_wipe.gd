extends Control

signal curtain_closed
signal curtain_opened

@onready var right_curtain = %RightCurtain
@onready var left_curtain = %LeftCurtain
@onready var top_curtain = %TopCurtain
@onready var bottom_curtain = %BottomCurtain
@onready var right_static_lines = %RightStaticLines
@onready var left_static_lines = %LeftStaticLines
@onready var top_static_lines = %TopStaticLines
@onready var bottom_static_lines = %BottomStaticLines


func _ready():
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	hide()
	hide_left_right_static_lines()
	hide_top_bottom_static_lines()


func hide_left_right_static_lines() -> void:
	for child in right_static_lines.get_children():
		child.hide()
	
	for child in left_static_lines.get_children():
		child.hide()


func hide_top_bottom_static_lines() -> void:
	for child in bottom_static_lines.get_children():
		child.hide()
	
	for child in top_static_lines.get_children():
		child.hide()


func open_vertical(frames: int = 16) -> void:
	top_curtain.position.y = 0
	bottom_curtain.position.y = -100
	top_curtain.show()
	bottom_curtain.show()
	top_static_lines.show()
	bottom_static_lines.show()
	right_curtain.hide()
	left_curtain.hide()
	
	var duration = 1180.0 / float(frames)
	duration = duration / 60.0
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(bottom_curtain, "position:y", 1080, duration).from(-100)
	tween.tween_property(top_curtain, "position:y", -1180, duration).from(0)
	
	await tween.finished
	tween.kill()
	#curtain_opened.emit()
	await top_static_lines.lines_done
	bottom_curtain.hide()
	top_curtain.hide()
	hide()


func close_horizontal(frames: int = 20) -> void:
	right_curtain.position.x = 1920
	left_curtain.position.x = -2020
	right_curtain.show()
	left_curtain.show()
	right_static_lines.show()
	left_static_lines.show()
	show()
	
	var duration = 2020.0 / float(frames)
	duration = duration / 60.0
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.tween_property(right_curtain, "position:x", -100, duration).from(1920)
	tween.tween_property(left_curtain, "position:x", 0, duration).from(-2020)
	
	await tween.finished
	tween.kill()
	await left_static_lines.lines_done
	#hide_left_right_static_lines()
	#curtain_closed.emit()


func _on_right_curtain_item_rect_changed():
	if right_curtain != null:
		var lines_array: Array = []
		
		for child in right_static_lines.get_children():
			if not child.is_visible_in_tree():
				lines_array.append(child)
		
		lines_array.reverse()
		
		for line in lines_array:
			if right_curtain.global_position.x <= line.global_position.x:
				line.show()


func _on_left_curtain_item_rect_changed():
	if left_curtain != null:
		var right_edge = left_curtain.global_position.x + 1920
		var lines_array: Array = []
		
		for child in left_static_lines.get_children():
			if not child.is_visible_in_tree():
				lines_array.append(child)
		
		for line in lines_array:
			if right_edge >= line.global_position.x:
				line.show()


func _on_bottom_curtain_item_rect_changed():
	if bottom_curtain != null:
		var lines_array: Array = []
		
		for child in bottom_static_lines.get_children():
			if not child.is_visible_in_tree():
				lines_array.append(child)
		
		for line in lines_array:
			if bottom_curtain.global_position.y >= line.global_position.y:
				line.show()


func _on_top_curtain_item_rect_changed():
	if top_curtain != null:
		var bottom_edge = top_curtain.global_position.y + 1080
		var lines_array: Array = []
		
		for child in top_static_lines.get_children():
			if not child.is_visible_in_tree():
				lines_array.append(child)
		
		lines_array.reverse()
		#print(lines_array)
		for line in lines_array:
			if bottom_edge <= line.global_position.y:
				line.show()
