extends HBoxContainer

#signal replace_finished
#signal restore_finished
signal all_labels_restored

@export var main: Node = null

var update_count: int

var signal_count: int = 0:
	set(value):
		signal_count = value
		
		if GlobalData.first_script or GlobalData.old_locations.is_empty():
			if signal_count == 5:
				all_labels_restored.emit()
				signal_count = 0
		
		else:
			if signal_count == update_count:
				all_labels_restored.emit()
				signal_count = 0
				update_count = 0


func _ready():
	if GlobalData.first_script or GlobalData.old_locations.is_empty():
		hide()
		get_tree().call_group("location_labels", "set_visible_characters", 0)
	else:
		show()
		for label in get_tree().get_nodes_in_group("location_labels"):
			label.visible_characters = label.text.length()


func random_char() -> String:
	var random_int = randi_range(65, 127)
	var rand_char = char(random_int)
	
	return rand_char


func randomize_string(initial_text: String) -> String:
	for i in initial_text.length():
		initial_text[i] = random_char()
	
	return initial_text


func replace_chars_with_rand(label: Label, frames: int = 20):
	var pos_array = range(label.text.length())
	var duration_sec = frames / 60.0
	var step_time
	
	if label.text.length() != 0:
		step_time = duration_sec / label.text.length()
	else:
		step_time = duration_sec
	
	#pos_array.append_array(pos_array)
	while pos_array.size() != 0:
		if get_tree().paused == true:
			await %PauseScreen.game_unpaused
		
		var rand_pos = randi() % pos_array.size()
		var index = pos_array[rand_pos]
		
		label.text[index] = random_char()
		pos_array.remove_at(rand_pos)
		await get_tree().create_timer(step_time).timeout
	
	if label.text.length() == 0:
		await get_tree().create_timer(step_time).timeout
	
	label.replace_finished.emit()


func restore_original_chars(label: Label, original_text: String, frames: int = 20):
	var pos_array = range(label.text.length())
	var duration_sec = frames / 60.0
	var step_time
	
	if label.text.length() != 0:
		step_time = duration_sec / label.text.length()
	else:
		step_time = duration_sec
	
	while pos_array.size() != 0:
		if get_tree().paused == true:
			await %PauseScreen.game_unpaused
		
		var rand_pos = randi() % pos_array.size()
		var index = pos_array[rand_pos]
		
		label.text[index] = original_text[index]
		pos_array.remove_at(rand_pos)
		await get_tree().create_timer(step_time).timeout
	
	if label.text.length() == 0:
		await get_tree().create_timer(step_time).timeout
	
	label.restore_finished.emit()


func animate_label(label: Label, frames: int = 20):
	var total_chars = label.get_total_character_count()
	var original_text = label.text
	var tween = create_tween()
	var tween_time = frames / 60.0
	
	label.text = randomize_string(label.text)
	label.visible_characters = 0
	tween.tween_property(label, "visible_characters", total_chars, tween_time)
	await tween.finished
	replace_chars_with_rand(label, frames)
	await label.replace_finished
	restore_original_chars(label, original_text, frames)


func update_label(label: Label, new_text: String, frames: int = 20):
	var tween_time = frames / 60.0
	
	replace_chars_with_rand(label, frames)
	await label.replace_finished
	
	if label.text.length() > new_text.length():
		var tween = create_tween()
		tween.tween_property(label, "visible_characters", new_text.length(), tween_time)
		replace_chars_with_rand(label, frames)
		await tween.finished
		await label.replace_finished
		label.text = label.text.left(new_text.length())
		label.visible_characters = new_text.length()
		
		if label.text == "":
			label.hide()
			label.left_sep.hide()
	
	elif  label.text.length() < new_text.length():
		if label.text == "":
			label.left_sep.show()
			label.show()
		
		var diff = new_text.length() - label.text.length()
		label.text += randomize_string(new_text.right(diff))
		var tween = create_tween()
		tween.tween_property(label, "visible_characters", new_text.length(), tween_time)
		replace_chars_with_rand(label, frames)
		await tween.finished
		await label.replace_finished
	
	else:
		replace_chars_with_rand(label, frames)
		await label.replace_finished
	
	restore_original_chars(label, new_text, frames)


func _on_test_button_pressed():
	pass


func _on_location_1_restore_finished():
	signal_count += 1


func _on_location_2_restore_finished():
	signal_count += 1


func _on_location_3_restore_finished():
	signal_count += 1


func _on_location_4_restore_finished():
	signal_count += 1


func _on_chapter_restore_finished():
	signal_count += 1


func _on_all_labels_restored():
	#await SoundManager.stop_location_sound()
	SoundManager.stop_location_sound(false)
