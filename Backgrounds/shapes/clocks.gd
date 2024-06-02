extends Control

var rand_speed: float
var color = Color.WHITE

@onready var circle = $Circle
@onready var hour = $Hour
@onready var minute = $Minute


func _ready():
	#circle.self_modulate.a = 0.5
	#hour.self_modulate.a = 0.5
	#minute.self_modulate.a = 0.5
	modulate = color
	
	minute.pivot_offset = minute.size / 2.0
	hour.pivot_offset = hour.size / 2.0
	
	rand_speed = randf_range(-18, 18)
	if rand_speed < 0:
		rand_speed -= 2
	else:
		rand_speed += 2
	#print(rand_speed)
	animate_minute(rand_speed)


func animate_minute(loop_duration: float = 10.0, loop: bool = true) -> void:
	var tween = create_tween().set_parallel().set_loops()
	var final_m = 360 if loop_duration > 0 else -360
	var final_h = 30 if loop_duration > 0 else -30
	
	loop_duration = abs(loop_duration)
	if not loop:
		tween.set_loops(12)
	
	tween.tween_property(minute, "rotation_degrees", final_m, loop_duration).as_relative()
	tween.tween_property(hour, "rotation_degrees", final_h, loop_duration).as_relative()
