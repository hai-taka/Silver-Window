extends Control

@onready var fade_rect = %FadeRect


func _ready():
	hide()


func fade_out(duration: float = 2.0) -> void:
	show()
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	
	await tween.finished
	tween.kill()


func fade_in(duration: float = 2.0) -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	tween.kill()
	hide()
