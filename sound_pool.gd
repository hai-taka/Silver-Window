extends Node

var sounds_list: Array[AudioStreamPlayer] = []
var last_index: int = -1


func _ready():
	if get_child_count() < 2:
		return
	
	for child in get_children():
		if child is AudioStreamPlayer:
			sounds_list.append(child)


func play_random_sound(allow_repeats: bool = false) -> void:
	var index: int
	
	if not allow_repeats:
		var index_array: Array = range(sounds_list.size())
		
		if last_index != -1:
			index_array.erase(last_index)
		
		index = index_array[randi() % index_array.size()]
	else:
		index = randi() % sounds_list.size()
	
	#print("last index: " + str(last_index))
	#print("new index: " + str(index))
	
	sounds_list[index].play()
	last_index = index


func play_next_sound() -> void:
	var index = last_index + 1
	
	if index == sounds_list.size():
		index = 0
	
	sounds_list[index].play()
	last_index = index


func stop_sound() -> void:
	if sounds_list[last_index].playing:
		sounds_list[last_index].stop()


func is_playing() -> bool:
	if sounds_list[last_index].playing:
		return true
	else:
		return false
