extends MarginContainer

var final_size: int = 1080

@onready var circle = $Circle


func _ready():
	animate()


func animate(duration: float = 3.0) -> void:
	var final_value = (size.x - final_size) / 2
	var tween = create_tween().set_parallel()
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(self, "theme_override_constants/margin_left", final_value, duration)
	tween.tween_property(self, "theme_override_constants/margin_right", final_value, duration)
	tween.tween_property(circle, "self_modulate:a", 0.0, duration)
