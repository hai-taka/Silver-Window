extends HBoxContainer

@export var main: Node = null

signal update_finished

var initial_margin: int = 75


func darken_location(location_panel: PanelContainer, value: float = 0.7):
	var location_label = location_panel.get_child(0).get_child(0).get_child(0)
	
	location_panel.self_modulate = Color(value, value, value)
	location_label.self_modulate = Color(value, value, value)


func brighten_location(location_panel: PanelContainer, value: float = 1.0):
	var location_label = location_panel.get_child(0).get_child(0).get_child(0)
	
	location_panel.self_modulate = Color(value, value, value)
	location_label.self_modulate = Color(value, value, value)


func drop_down(margin_container: MarginContainer, emit_sig: bool = true, frames: int = 13):
	var final_value = 0
	var color_rect = margin_container.get_child(0).get_child(1)
	var tween = create_tween()
	var tween_frames = frames
	var tween_time = tween_frames / 60.0
	
	initial_margin = margin_container.get_theme_constant("margin_bottom")
	color_rect.show()
	tween.tween_property(margin_container, "theme_override_constants/margin_bottom", 
			initial_margin / 2.0, tween_time / 2.0)
	
	await tween.finished
	tween.kill()
	
	if emit_sig:
		margin_container.drop_down_half_finished.emit()
	
	tween = create_tween()
	tween.tween_property(margin_container, "theme_override_constants/margin_bottom", 
			final_value, tween_time / 2.0)
	
	await tween.finished
	tween.kill()
	
	color_rect.hide()
	
	if emit_sig:
		margin_container.drop_down_finished.emit()


func pull_up(margin_container: MarginContainer, emit_half_sig: bool = true, 
		emit_full_sig: bool = true, frames: int = 13):
	
	var final_value = 75
	var color_rect = margin_container.get_child(0).get_child(1)
	var tween = create_tween()
	var tween_frames = frames
	var tween_time = tween_frames / 60.0
	
	color_rect.show()
	tween.tween_property(margin_container, "theme_override_constants/margin_bottom", 
			final_value / 2.0, tween_time / 2.0)
	
	await tween.finished
	tween.kill()
	
	if emit_half_sig:
		margin_container.pull_up_half_finished.emit()
	
	tween = create_tween()
	tween.tween_property(margin_container, "theme_override_constants/margin_bottom", 
			final_value, tween_time / 2.0)
	
	await tween.finished
	tween.kill()
	
	color_rect.hide()
	
	if emit_full_sig:
		margin_container.pull_up_finished.emit()


func update_locations(key_array: Array[String], margins_to_update: Array[MarginContainer], 
		labels_to_update: Array[Label]) -> void:
	
	# Pull up locations
	margins_to_update.reverse()
	
	for marg in margins_to_update:
		#if marg == margins_to_update[0]:
		#	darken_location(marg.get_child(0))
		if marg.get_theme_constant("margin_bottom") != 75:
			pull_up(marg, true, true, 26)
			await marg.pull_up_half_finished
	
	await margins_to_update.back().pull_up_finished
	
	# Update text on labels
	for i in labels_to_update.size():
		labels_to_update[i].text = main.location_dict[key_array[i]]
	
	await get_tree().create_timer(10 / 60.0).timeout
	
	# Drop down locations
	var margins_to_drop: Array[MarginContainer] = margins_to_update.duplicate()
	
	for marg in margins_to_update:
		if main.locations_to_show.has(marg) == false:
			margins_to_drop.erase(marg)
	
	margins_to_drop.reverse()
	
	for marg in margins_to_drop:
		#if marg == margins_to_update.back():
		#	brighten_location(marg.get_child(0))
		
		drop_down(marg, true, 26)
		await marg.drop_down_half_finished
		
	if not margins_to_drop.is_empty():
		await margins_to_drop.back().drop_down_finished
	
	update_finished.emit()
