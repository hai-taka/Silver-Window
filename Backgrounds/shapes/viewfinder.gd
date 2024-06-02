extends Control

var color = Color.WHITE


func _ready():
	for rect in get_tree().get_nodes_in_group("inner_rects"):
		rect.pivot_offset = rect.size / 2.0
	for rect in get_tree().get_nodes_in_group("outer_rects"):
		rect.pivot_offset = rect.size / 2.0
	
	modulate = color
	animate()


func animate(duration: float = 1.0) -> void:
	var tween = create_tween().set_parallel().set_loops()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	for rect in get_tree().get_nodes_in_group("inner_rects"):
		tween.tween_property(rect, "rotation_degrees", 90, duration).as_relative()
	for rect in get_tree().get_nodes_in_group("outer_rects"):
		tween.chain().tween_property(rect, "rotation_degrees", 90, duration).as_relative()
