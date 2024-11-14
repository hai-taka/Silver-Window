extends ColorRect

var color_1 = Color.WHITE
var color_2 = Color.WHITE
var color_3 = Color.WHITE
var color_4 = Color.WHITE

var color_array = []

@onready var screen_size: Vector2 = get_viewport().get_visible_rect().size


func _ready():
	#self_modulate.a = 0.5
	color_array = [
		color_1,
		color_2,
		color_3,
		color_4,
	]
	color = color_array.pick_random()
	size.y = randi_range(20, 100)
	#print(size.y)
	position.y = randi_range(100, int(screen_size.y) - int(size.y) - 100)
	#print(position.y)
	var rand_time = randf_range(20.0, 50.0)
	
	animate(rand_time)


func animate(duration: float = 5.0) -> void:
	var vert: bool = true if size.y > size.x else false
	var tween = create_tween().set_loops()
	var final_val = screen_size + size
	
	if not vert:
		tween.tween_property(
				self, "position:x", final_val.x, duration
		).as_relative().from_current()#.set_delay(3.0)
	else:
		tween.tween_property(
				self, "position:y", 2 * screen_size.y, duration
		).as_relative().from_current()#.set_delay(3.0)
	
	tween.tween_interval(3.0)
