extends TextureRect

signal fade_in_finished
signal fade_out_finished

@export var fade_in_duration: float = 3.0
@export var fade_in_color: Color = Color("black")
@export var fade_in_solid: bool = true
@export var fade_out_duration: float = 1.0
@export var fade_out_color: Color = Color("black")
@export var fade_out_solid: bool = true

var fade_in_flag = false
var fade_out_flag = false

@onready var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
@onready var picture_window = get_parent().get_parent().get_parent().get_parent()
@onready var color_rect = $ColorRect
@onready var top_label = %FirstPicTopLabel
@onready var bott_label = %FirstPicBottLabel


func fade_in():
	var tween = create_tween()
	
	if fade_in_solid:
		tween.tween_property(color_rect, "self_modulate:a", 0.0, fade_in_duration)
	
	else:
		tween.tween_property(self, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), fade_in_duration)
	
	await tween.finished
	tween.kill()
	
	color_rect.hide()
	main.fading_in = false
	main.allow_input_main = true
	
	fade_in_finished.emit()


func fade_out():
	main.allow_input_main = false
	main.fading_out = true
	main.fading_out_picture_window = picture_window
	
	var tween = create_tween()
	
	if fade_out_solid:
		color_rect.color = fade_out_color
		color_rect.self_modulate.a = 0.0
		color_rect.show()
		
		tween.tween_property(color_rect, "self_modulate:a", 1.0, fade_out_duration)
	
	else:
		tween.tween_property(self, "self_modulate", fade_out_color, fade_out_duration)
	
	await tween.finished
	tween.kill()
	
	main.fading_out = false
	main.allow_input_main = true
	
	fade_out_finished.emit()
