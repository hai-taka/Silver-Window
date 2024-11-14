extends Panel

#var time = 0
var rotate_tween: Tween = null
var color = Color.WHITE


func _ready():
	#self_modulate.a = 0.5
	get_theme_stylebox("panel").border_color = color
	pivot_offset = size / 2.0
	rotate_shape()


func rotate_shape(frames: int = 60, loop: bool = true) -> void:
	var tween_time = frames / 60.0
	rotate_tween = create_tween()
	rotate_tween.set_ease(Tween.EASE_OUT_IN)
	rotate_tween.set_trans(Tween.TRANS_EXPO)
	if loop:
		rotate_tween.set_loops()
	
	rotate_tween.tween_property(self, "rotation", PI / 2, tween_time).from(0.0).set_delay(1.0)
