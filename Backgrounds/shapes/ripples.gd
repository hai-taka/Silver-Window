extends Control

var wave = preload("res://Backgrounds/shapes/wave.tscn")
var delay: float = 6.0
var color = Color.WHITE

@onready var screen_size = get_viewport().get_visible_rect().size


func _ready():
	modulate = color
	
	var tween = create_tween().set_loops()
	tween.tween_callback(ripple.bind(4))
	tween.tween_interval(delay)


func ripple(waves: int = 4) -> void:
	var final_size: int = randi_range(400, 1080)
	var margin = (1080 - final_size) / 2.0
	var rand_pos_x: int = randi_range(0 - margin, screen_size.x - (final_size + margin))
	var rand_pos_y: int = randi_range(0 - margin, screen_size.y - (final_size + margin))
	if waves == 0:
		waves = randi_range(2, 10)
	
	for i in waves:
		var wave_instance = wave.instantiate()
		wave_instance.position = Vector2(rand_pos_x, rand_pos_y)
		wave_instance.final_size = final_size
		if final_size <= 800:
			wave_instance.get_child(0).texture = load("res://Backgrounds/shapes/textures/circle-800-5.png")
		add_child(wave_instance)
		await get_tree().create_timer(1.0).timeout
