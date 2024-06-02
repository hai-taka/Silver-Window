extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func fill_bar(tween_time: float):
	get_tree().paused = true
	get_parent().show()
	
	var tween = create_tween()
	
	tween.tween_property(self, "value", 100, tween_time)
	
	await tween.finished
	get_parent().hide()
	value = 0
	get_tree().paused = false
