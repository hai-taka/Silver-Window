extends MarginContainer

signal picture_finished
signal expand_started
signal expanded
signal shrink_finished
signal move_completed
signal change_completed

@export var tween_frames : int = 13

var shrinking = false
var expanding = false
var final_window = false
var paired = false

var speed: float = 10.0
var height: float = 50.0
var spread: float = 50.0
var speed_str: String = " speed=" + str(speed).pad_decimals(1)
var height_str: String = " height=" + str(height).pad_decimals(1)
var spread_str: String = " spread=" + str(spread).pad_decimals(1)
var plain_top: String
var plain_bott: String
var plain_top_length: int
var ptl_no_sp: int
var plain_bott_length: int
var pbl_no_sp: int
var top_2: String
var bott_2: String
var dur: float
var dur_bott: float
var text_color: Color:
	set(value):
		text_color = value
		top_label.add_theme_color_override("default_color", value)
		bott_label.add_theme_color_override("default_color", value)

var play_sound: bool = false
var await_sound: bool = false
var new_track: bool = false
var sound_path: String

var update_play_sound: bool = false
var update_new_track: bool = false
var update_sound_path: String

var show_location: bool = true
var location_type: int = 0

@onready var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
@onready var PictureContainer = $PictureContainer
@onready var PictureRect = $PictureContainer/Control/PictureRect
@onready var color_rect = $PictureContainer/Control/PictureRect/ColorRect
@onready var border_left = $PictureContainer.get_theme_stylebox("panel").border_width_left
@onready var border_top = $PictureContainer.get_theme_stylebox("panel").border_width_top
@onready var border_right = $PictureContainer.get_theme_stylebox("panel").border_width_right
@onready var border_bottom = $PictureContainer.get_theme_stylebox("panel").border_width_bottom
@onready var top_label = %FirstPicTopLabel
@onready var bott_label = %FirstPicBottLabel


func _ready():
	custom_minimum_size.x = PictureRect.size.x + border_left + border_right
	custom_minimum_size.y = PictureRect.size.y + border_top + border_bottom
	reset_size()
	hide()
	
	if PictureRect.fade_in_flag:
		if PictureRect.fade_in_solid:
			color_rect.color = PictureRect.fade_in_color
			color_rect.show()
		
		else:
			PictureRect.self_modulate = PictureRect.fade_in_color
		
		main.allow_input_main = false
		main.fading_in = true
		main.fading_in_picture_window = get_parent()
	
	if not paired:
		# If picture is independent and there is a non-blank text box,
		# wait for text box to finish shrinking before showing picture.
		if main.window != null and not main.old_box.blank:
			await main.window.tree_exited
	
		# If picture is independent and another picture is closing,
		# wait for other picture to finish shrinking before showing.
		if main.pic_to_close != null:
			await main.pic_to_close.tree_exited
		
		if main.moving_pic != null:
			await main.moving_pic.move_completed
			main.moving_pic = null
		
		if main.changing_pic != null:
			if main.non_zero_delay:
				await main.changing_pic.change_completed
				main.non_zero_delay = false
			
			main.changing_pic = null
	
	expand()


func set_all_margins(left : int, top : int, right : int, bottom : int):
	add_theme_constant_override("margin_left", left)
	add_theme_constant_override("margin_top", top)
	add_theme_constant_override("margin_right", right)
	add_theme_constant_override("margin_bottom", bottom)


func expand():
	main.allow_input_main = false
	expanding = true
	emit_signal("expand_started")
	
	var full_size = size
	var left_marg = (full_size.x / 2) - border_left
	var right_marg = (full_size.x / 2) - border_right
	var top_marg = (full_size.y / 2) - border_top
	var bottom_marg = (full_size.y / 2) - border_bottom
	
#	PictureRect.hide()
	set_all_margins(left_marg, top_marg, right_marg, bottom_marg)
	show()
	
	var tween = create_tween()
	var tween_time = tween_frames / 60.0
	
	tween.set_parallel()
	tween.tween_property(self, "theme_override_constants/margin_left", 0, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_top", 0, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_right", 0, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_bottom", 0, tween_time)

	await tween.finished
	tween.kill()
#	PictureRect.show()

	expanding = false
	
#	if PictureRect.fade_in_flag:
#		await PictureRect.fade_in()
	
	if play_sound:
		if not new_track:
			await_sound = true
			SoundManager.play_picture_sound(sound_path)
		else:
			if top_label.text != "":
				if show_location:
					if location_type == 0: # Silver
						await main.locations_dropped_down
					elif location_type == 1: # Twenty-five
						await main.header_container.all_labels_restored
			await_sound = false
			SoundManager.play_background_music(sound_path)
	
	if PictureRect.fade_in_flag:
		await PictureRect.fade_in()
	
	# Top Label 1 appear
	if top_label.text != "":
		plain_top = top_label.text
		plain_top_length = top_label.text.length()
		ptl_no_sp = plain_top_length - plain_top.count(" ")
		
		SoundManager.play_first_pic_appear()
		top_label.show()
		top_label.text = (
				"[fall" + speed_str + height_str + spread_str + "]" 
				+ top_label.text + "[/fall]"
		)
		#print(top_label.text)
		dur = (1 / speed) + ((ptl_no_sp - 1) * spread) / (speed * height)
		#print(dur)
		await get_tree().create_timer(dur, false).timeout
		SoundManager.stop_first_pic_appear()
		
		if bott_label.text == "":
			await get_tree().create_timer(1.5, false).timeout
		else:
			await get_tree().create_timer(0.5, false).timeout
	
	# Bott Label 1 appear
	if bott_label.text != "":
		plain_bott = bott_label.text
		plain_bott_length = bott_label.text.length()
		pbl_no_sp = plain_bott_length - plain_bott.count(" ")
		
		SoundManager.play_first_pic_appear()
		bott_label.show()
		bott_label.text = (
				"[fall" + speed_str + height_str + spread_str + "]" 
				+ bott_label.text + "[/fall]"
		)
		#print(bott_label.text)
		dur_bott = (1 / speed) + ((pbl_no_sp - 1) * spread) / (speed * height)
		#print(dur_bott)
		await get_tree().create_timer(dur_bott, false).timeout
		SoundManager.stop_first_pic_appear()
		
		await get_tree().create_timer(1.5, false).timeout
	
	# Top Label 1 disappear
	if top_label.text != "":
		SoundManager.play_first_pic_disappear()
		top_label.show()
		top_label.text = (
				"[sink" + speed_str + height_str + spread_str + "]" 
				+ plain_top + "[/sink]"
		)
		#print(top_label.text)
		dur = (1 / speed) + ((ptl_no_sp - 1) * spread) / (speed * height)
		#print(dur)
		await get_tree().create_timer(dur, false).timeout
		SoundManager.stop_first_pic_disappear()
		
		await get_tree().create_timer(0.5, false).timeout
	
	# Top Label 2 appear
	if top_2 != "":
		plain_top = top_2
		plain_top_length = top_2.length()
		ptl_no_sp = plain_top_length - plain_top.count(" ")
		
		SoundManager.play_first_pic_appear()
		top_label.show()
		top_label.text = (
				"[fall" + speed_str + height_str + spread_str + "]" 
				+ top_2 + "[/fall]"
		)
		#print(top_label.text)
		dur = (1 / speed) + ((ptl_no_sp - 1) * spread) / (speed * height)
		#print(dur)
		await get_tree().create_timer(dur, false).timeout
		SoundManager.stop_first_pic_appear()
		
		if bott_2 == "":
			await get_tree().create_timer(1.5, false).timeout
		else:
			await get_tree().create_timer(0.5, false).timeout
	
	# Bott Label 1 disappear
	if bott_label.text != "":
		SoundManager.play_first_pic_disappear()
		bott_label.show()
		bott_label.text = (
				"[sink" + speed_str + height_str + spread_str + "]" 
				+ plain_bott + "[/sink]"
		)
		#print(bott_label.text)
		dur_bott = (1 / speed) + ((pbl_no_sp - 1) * spread) / (speed * height)
		#print(dur_bott)
		await get_tree().create_timer(dur_bott, false).timeout
		SoundManager.stop_first_pic_disappear()
		
		await get_tree().create_timer(0.5, false).timeout
	
	# Bott Label 2 appear
	if bott_2 != "":
		plain_bott = bott_2
		plain_bott_length = bott_2.length()
		pbl_no_sp = plain_bott_length - plain_bott.count(" ")
		
		SoundManager.play_first_pic_appear()
		bott_label.show()
		bott_label.text = (
				"[fall" + speed_str + height_str + spread_str + "]" 
				+ bott_2 + "[/fall]"
		)
		#print(bott_label.text)
		dur_bott = (1 / speed) + ((pbl_no_sp - 1) * spread) / (speed * height)
		#print(dur_bott)
		await get_tree().create_timer(dur_bott, false).timeout
		SoundManager.stop_first_pic_appear()
		
		await get_tree().create_timer(1.5, false).timeout
	
	# Top Label 2 disappear
	if top_2 != "":
		SoundManager.play_first_pic_disappear()
		top_label.show()
		top_label.text = (
				"[sink" + speed_str + height_str + spread_str + "]" 
				+ plain_top + "[/sink]"
		)
		#print(top_label.text)
		dur = (1 / speed) + ((ptl_no_sp - 1) * spread) / (speed * height)
		#print(dur)
		await get_tree().create_timer(dur, false).timeout
		SoundManager.stop_first_pic_disappear()
		
		await get_tree().create_timer(0.5, false).timeout
	
	# Bott Label 2 disappear
	if bott_2 != "":
		SoundManager.play_first_pic_disappear()
		bott_label.show()
		bott_label.text = (
				"[sink" + speed_str + height_str + spread_str + "]" 
				+ plain_bott + "[/sink]"
		)
		#print(bott_label.text)
		dur_bott = (1 / speed) + ((pbl_no_sp - 1) * spread) / (speed * height)
		#print(dur_bott)
		await get_tree().create_timer(dur_bott, false).timeout
		SoundManager.stop_first_pic_disappear()
		await get_tree().create_timer(0.5, false).timeout
	
	main.allow_input_main = true
	
	emit_signal("expanded")


func shrink():
	SoundManager.stop_picture_sound()
	main.picture_playing_sound = null
	
	if PictureRect.fade_out_flag:
		if not get_tree().get_nodes_in_group("dialogue_labels")[0].blank:
			await get_tree().get_nodes_in_group("dialogue_windows")[0].tree_exited
		
		await PictureRect.fade_out()
	
	else:
		if not paired and not main.old_box.blank:
			await main.window.tree_exited
	
	main.allow_input_main = false
	shrinking = true
	
	var full_size = size
	var left_marg = (full_size.x / 2) - border_left
	var right_marg = (full_size.x / 2) - border_right
	var top_marg = (full_size.y / 2) - border_top
	var bottom_marg = (full_size.y / 2) - border_bottom
	
#	PictureRect.hide()
	set_all_margins(0, 0, 0, 0)
	
	var tween = create_tween()
	var tween_time = tween_frames / 60.0
	
	tween.set_parallel()
	tween.tween_property(self, "theme_override_constants/margin_left", left_marg, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_top", top_marg, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_right", right_marg, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_bottom", bottom_marg, tween_time)
	
	await tween.finished
	tween.kill()
	hide()
	shrinking = false
	main.allow_input_main = true
	
	if main.fading_in_picture_window == get_parent():
		main.fading_in_picture_window = null
	
	if main.fading_out_picture_window == get_parent():
		main.fading_out_picture_window = null
	
	if main.active_pictures.values().has(get_parent()):
		main.active_pictures.erase(main.active_pictures.find_key(get_parent()))
	
	$"..".queue_free()
	shrink_finished.emit()
	
	if final_window:
		main.pull_up_all()
		#get_tree().quit()


func move_picture(new_pos_x: int, new_pos_y: int, move_type: int):
	if main.window != null and not main.old_box.blank:
		await main.window.tree_exited
	
	var tween = create_tween()
	var tween_time
	var distance = Vector2(new_pos_x, new_pos_y) - position
	distance = distance.abs()
	var length = distance.length()
	tween_time = length/2000
	
	# Direct
	if move_type == 0:
		tween.tween_property(self, "position", Vector2(new_pos_x, new_pos_y), tween_time)
	# X --> Y
	elif move_type == 1:
		tween.tween_property(self, "position:x", new_pos_x, tween_time / 2)
		tween.tween_property(self, "position:y", new_pos_y, tween_time / 2)
	# Y --> X
	elif move_type == 2:
		tween.tween_property(self, "position:y", new_pos_y, tween_time / 2)
		tween.tween_property(self, "position:x", new_pos_x, tween_time / 2)
	
	await tween.finished
	tween.kill()
	move_completed.emit()
	
	if update_play_sound:
		if update_new_track:
			await_sound = false
			SoundManager.play_background_music(update_sound_path)
		else:
			await_sound = true
			SoundManager.play_picture_sound(update_sound_path)
		
		update_play_sound = false
		update_new_track = false
		update_sound_path = ""


func change_picture(new_path: String, delay_before: float, delay_after: float) -> void:
	if main.window != null and not main.old_box.blank:
		await main.window.tree_exited
	
	if delay_before != 0:
		await get_tree().create_timer(delay_before).timeout
	
	if new_path != "":
		PictureRect.texture = load(new_path)
	
	if update_play_sound:
		if update_new_track:
			await_sound = false
			SoundManager.play_background_music(update_sound_path)
		else:
			await_sound = true
			SoundManager.play_picture_sound(update_sound_path)
		
		update_play_sound = false
		update_new_track = false
		update_sound_path = ""
	
	if delay_after != 0:
		await get_tree().create_timer(delay_after).timeout
	
	change_completed.emit()
