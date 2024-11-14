extends Node

signal script_finished
signal locations_dropped_down
signal locations_pulled_up

@export_file("*.json") var custom_dialogue_path = ""

@export var window_stylebox: StyleBoxFlat = null
@export var window_theme: Theme = null
@export var frame_stylebox: StyleBoxFlat = null
@export var name_label_settings: LabelSettings = null
@export var framelines_lr_stylebox: StyleBoxLine = null
@export var framelines_tb_stylebox: StyleBoxLine = null
@export var wipe_stylebox: StyleBoxFlat = null
@export var silver_location_stylebox: StyleBoxFlat = null
@export var silver_label_settings: LabelSettings = null
@export var twenty_five_line_stylebox: StyleBoxLine = null
@export var twenty_five_label_settings: LabelSettings = null

var shapes_bg = preload("res://Backgrounds/shapes_background.tscn")

var dialogue_script
var location_dict
var dialogue_script_index = 0
var dialogue_window = preload("res://dialogue_window.tscn")
var picture_window = preload("res://picture_window.tscn")
var window = null
var old_box = null
var paired_window = null
var active_pictures = {}
var locations_to_show = []

var allow_input_main = true
var pic_to_show = null
var pic_to_close = null
var moving_pic = null
var changing_pic = null
var non_zero_delay: bool = false
var fading_in = false
var fading_in_picture_window = null
var fading_out = false
var fading_out_picture_window = null
var picture_playing_sound = null
var revealing_location: bool = true

@onready var chapter_index = GlobalData.current_chapter
@onready var chapter_name = GlobalData.chapter_list[chapter_index]

#@onready var dialogue_script = DialogueManager.dialogue_script
#@onready var location_dict = DialogueManager.dialogue_script["0"]["location dict"]

@onready var SpeakerFrame = $SpeakerFrame
@onready var SpeakerName = $SpeakerName
@onready var FrameLineControl = $FrameLineControl
@onready var location_1 = %Location1
@onready var location_2 = %Location2
@onready var location_3 = %Location3
@onready var location_4 = %Location4
@onready var chapter = %Chapter
@onready var pause_screen = %PauseScreen
@onready var header_container = %HeaderContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	if custom_dialogue_path != "":
		DialogueManager.change_script(custom_dialogue_path)
	elif DialogueManager.dialogue_script == {}:
		DialogueManager.change_script(GlobalData.first_script_list[0])
	
	dialogue_script = DialogueManager.dialogue_script
	location_dict = DialogueManager.dialogue_script["0"]["location dict"]
	
	var bg_dict = dialogue_script["0"]["bg dict"]
	var bg = shapes_bg.instantiate()
	
	bg.bg_type = bg_dict["type"]
	if bg_dict["type"] == 0:
		bg.solid_color = bg_dict["solid color"]
	elif bg_dict["type"] == 1:
		bg.grad_top_color = bg_dict["top color"]
		bg.grad_top_offset = bg_dict["top offset"]
		bg.grad_bott_color = bg_dict["bott color"]
		bg.grad_bott_offset = bg_dict["bott offset"]
	else:
		bg.texture_path = bg_dict["path"]
	
	bg.anim_type = bg_dict["animation"]
	if bg_dict["animation"] != 4:
		bg.anim_color = bg_dict["anim color"]
		if bg_dict["animation"] == 5:
			bg.ripple_delay = bg_dict["ripple delay"]
	else:
		bg.line_color_1 = bg_dict["line color 1"]
		bg.line_color_2 = bg_dict["line color 2"]
		bg.line_color_3 = bg_dict["line color 3"]
		bg.line_color_4 = bg_dict["line color 4"]
	
	add_child(bg)
	
	locations_pulled_up.connect(_on_main_1_locations_pulled_up)
	SoundManager.picture_sound.finished.connect(_on_picture_sound_finished)
	
	window_stylebox.bg_color = DialogueManager.dialogue_script["0"]["box bg color"]
	window_stylebox.border_color = DialogueManager.dialogue_script["0"]["border color"]
	window_stylebox.set_border_width_all(DialogueManager.dialogue_script["0"]["border width"])
	window_theme.set_color("default_color", "RichTextLabel", dialogue_script["0"]["text color"])
	window_theme.set_color("default_color", "TextOrnaments", dialogue_script["0"]["cursor color"])
	frame_stylebox.border_color = DialogueManager.dialogue_script["0"]["frame color"]
	frame_stylebox.set_border_width_all(DialogueManager.dialogue_script["0"]["frame width"])
	name_label_settings.font_color = DialogueManager.dialogue_script["0"]["name color"]
	framelines_lr_stylebox.color = DialogueManager.dialogue_script["0"]["frame color"]
	framelines_lr_stylebox.color.a = 1.00
	framelines_tb_stylebox.color = DialogueManager.dialogue_script["0"]["frame color"]
	framelines_tb_stylebox.color.a = 1.00
	wipe_stylebox.border_color = DialogueManager.dialogue_script["0"]["wipe color"]
	
	silver_location_stylebox.bg_color = dialogue_script["0"]["loc bg color"]
	silver_label_settings.font_color = dialogue_script["0"]["loc text color"]
	twenty_five_line_stylebox.color = dialogue_script["0"]["25 line color"]
	twenty_five_label_settings.font_color = dialogue_script["0"]["25 text color"]
	
	set_location()
	
	if location_dict["type"] == 0:
		%HeaderContainer.hide()
		
		if GlobalData.previous_transition == GlobalData.NONE:
			%LocationMargin.add_theme_constant_override("margin_bottom", 0)
			%LocationMargin5.add_theme_constant_override("margin_bottom", 0)

			for loc in GlobalData.old_locations_to_show:
				var marg: MarginContainer = null

				if "LocationMargin2" in loc:
					marg = %LocationMargin2
					%SilverLoc2.text = GlobalData.old_locations["loc 2"]
				if "LocationMargin3" in loc:
					marg = %LocationMargin3
					%SilverLoc3.text = GlobalData.old_locations["loc 3"]
				if "LocationMargin4" in loc:
					marg = %LocationMargin4
					%SilverLoc4.text = GlobalData.old_locations["loc 4"]

				marg.add_theme_constant_override("margin_bottom", 0)
	
	if GlobalData.running_from_editor:
		$ReturnButton.show()
		$RestartButton.show()
		$QuitButton.show()
	
	#if fullscreen:
	#	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	if GlobalData.transitioning:
		await TransitionManager.transition_finished
	
	if GlobalData.previous_transition != GlobalData.NONE:
		await get_tree().create_timer(0.5).timeout
	
	if location_dict["show"]:
		
		if (
			not GlobalData.old_locations.is_empty() 
			and location_dict["type"] != GlobalData.old_locations["type"]
		):
			GlobalData.old_locations.clear()
		
		if GlobalData.first_script or GlobalData.old_locations.is_empty():
			# Show all labels, as if starting a new chapter
			if location_dict["type"] == 0:
				
				if (
						not dialogue_script[str(0)]["start picture"] 
						or dialogue_script[str(0)].has("first pic dict") 
						and dialogue_script[str(0)]["first pic dict"][0]["top 1"] == "" 
						and dialogue_script[str(0)]["first pic dict"][0]["bott 1"] == ""
				):
					await drop_down_all()
				else:
					drop_down_all()
			elif location_dict["type"] == 1:
				if (
						not dialogue_script[str(0)]["start picture"] 
						or dialogue_script[str(0)].has("first pic dict") 
						and dialogue_script[str(0)]["first pic dict"][0]["top 1"] == "" 
						and dialogue_script[str(0)]["first pic dict"][0]["bott 1"] == ""
				):
					await twenty_five_animate_all()
				
				else:
					twenty_five_animate_all()
			
			GlobalData.old_locations = location_dict.duplicate()
		
		else:
			# Update labels that differ from previous ones
			var locations_to_change: Array[String] = []
			for key in location_dict:
				if key == "type" or key == "show":
					continue
				
				if location_dict[key] != GlobalData.old_locations[key]:
					locations_to_change.append(key)
			
			if location_dict["type"] == 0:
				if GlobalData.previous_transition == GlobalData.NONE:
					var marg_array: Array[MarginContainer] = location_key_to_marg_array(
							locations_to_change)
					var label_array: Array[Label] = location_key_to_label_array(
							locations_to_change)
					
					revealing_location = true
					%HeaderContainer2.update_locations(locations_to_change, marg_array, label_array)
					
					if (
							not dialogue_script[str(0)]["start picture"] 
							or dialogue_script[str(0)].has("first pic dict") 
							and dialogue_script[str(0)]["first pic dict"][0]["top 1"] == "" 
							and dialogue_script[str(0)]["first pic dict"][0]["bott 1"] == ""
					):
						await %HeaderContainer2.update_finished
					
					locations_dropped_down.emit()
					revealing_location = false
				
				else:
					if (
							not dialogue_script[str(0)]["start picture"] 
							or dialogue_script[str(0)].has("first pic dict") 
							and dialogue_script[str(0)]["first pic dict"][0]["top 1"] == "" 
							and dialogue_script[str(0)]["first pic dict"][0]["bott 1"] == ""
					):
						await drop_down_all()
					else:
						drop_down_all()
			
			elif location_dict["type"] == 1:
				%HeaderContainer.update_count = locations_to_change.size()
				if locations_to_change.size() != 0:
					SoundManager.play_location_sound()
				
				revealing_location = true
				for key in locations_to_change:
					var label: Label
					match key:
						"loc 1":
							label = %Location1
						"loc 2":
							label = %Location2
						"loc 3":
							label = %Location3
						"loc 4":
							label = %Location4
						"chapter":
							label = %Chapter
					
					%HeaderContainer.update_label(label, location_dict[key], 20)
				
				if (
						not dialogue_script[str(0)]["start picture"] 
						or dialogue_script[str(0)].has("first pic dict") 
						and dialogue_script[str(0)]["first pic dict"][0]["top 1"] == "" 
						and dialogue_script[str(0)]["first pic dict"][0]["bott 1"] == ""
				):
					await %HeaderContainer.all_labels_restored
				
				revealing_location = false
		
		GlobalData.old_locations = location_dict.duplicate()
	
	else:
		revealing_location = false
		GlobalData.old_locations.clear()
	
	next_dialogue()


func _input(event):
	if (
			not GlobalData.running_from_editor and not GlobalData.transitioning 
			and not revealing_location
	):
		
		if event.is_action_pressed("pause_game"):
			get_viewport().set_input_as_handled()
			get_tree().paused = true
			pause_screen.show()


func twenty_five_animate_all():
	revealing_location = true
	SoundManager.play_location_sound()
	%HeaderContainer.show()
	for label in get_tree().get_nodes_in_group("location_labels"):
		%HeaderContainer.animate_label(label, 20)
		#await label.restore_finished
	
	await %HeaderContainer.all_labels_restored
	SoundManager.stop_location_sound()
	revealing_location = false


func twenty_five_update_all():
	pass


func drop_down_all():
	revealing_location = true
	if location_dict["type"] == 0:
		%HeaderContainer2.drop_down(%LocationMargin)
		%HeaderContainer2.drop_down(%LocationMargin5, false)
		await %LocationMargin.drop_down_half_finished
		
		for loc in locations_to_show:
			%HeaderContainer2.drop_down(loc)
			await loc.drop_down_half_finished
		
		if not locations_to_show.is_empty():
			await locations_to_show.back().drop_down_finished
		
		locations_dropped_down.emit()
	
	revealing_location = false


func pull_up_all():
	revealing_location = true
	if location_dict["type"] == 0:
		locations_to_show.reverse()
		
		for loc in locations_to_show:
			%HeaderContainer2.pull_up(loc, true, false)
			await loc.pull_up_half_finished
		
		%HeaderContainer2.pull_up(%LocationMargin, false, false)
		%HeaderContainer2.pull_up(%LocationMargin5)
		await %LocationMargin5.pull_up_finished
	
		locations_pulled_up.emit()
	#revealing_location = false


func location_key_to_marg_array(change_array: Array[String]) -> Array[MarginContainer]:
	var output_array: Array[MarginContainer] = []
	
	for key in change_array:
		var marg: MarginContainer
		match key:
			"loc 1":
				marg = %LocationMargin
			"loc 2":
				marg = %LocationMargin2
			"loc 3":
				marg = %LocationMargin3
			"loc 4":
				marg = %LocationMargin4
			"chapter":
				marg = %LocationMargin5
		
		output_array.append(marg)
	
	return output_array


func location_key_to_label_array(change_array: Array[String]) -> Array[Label]:
	var output_array: Array[Label] = []
	
	for key in change_array:
		var label: Label
		match key:
			"loc 1":
				label = %SilverLoc1
			"loc 2":
				label = %SilverLoc2
			"loc 3":
				label = %SilverLoc3
			"loc 4":
				label = %SilverLoc4
			"chapter":
				label = %SilverChap
		
		output_array.append(label)
	
	return output_array


func set_location():
	if location_dict["show"]:
		var text_dict: Dictionary
		
		if GlobalData.first_script or GlobalData.old_locations.is_empty():
			text_dict = location_dict
		else:
			text_dict = GlobalData.old_locations
		
		if location_dict["type"] == 0:
			if GlobalData.previous_transition == 0:
				text_dict = GlobalData.old_locations
			else:
				text_dict = location_dict
			
			%HeaderContainer2.show()
			%SilverLoc1.text = text_dict["loc 1"]
			%SilverPanel.self_modulate = Color(0.7, 0.7, 0.7)
			%SilverLoc1.self_modulate = Color(0.7, 0.7, 0.7)
			
			if location_dict["loc 2"] != "":
				%SilverLoc2.text = text_dict["loc 2"]
				locations_to_show.append(%LocationMargin2)
				%SilverPanel2.self_modulate = Color(0.7, 0.7, 0.7)
				%SilverLoc2.self_modulate = Color(0.7, 0.7, 0.7)
			
				if location_dict["loc 3"] != "":
					%SilverLoc3.text = text_dict["loc 3"]
					locations_to_show.append(%LocationMargin3)
					%SilverPanel3.self_modulate = Color(0.7, 0.7, 0.7)
					%SilverLoc3.self_modulate = Color(0.7, 0.7, 0.7)
				
					if location_dict["loc 4"] != "":
						%SilverLoc4.text = text_dict["loc 4"]
						locations_to_show.append(%LocationMargin4)
						%SilverPanel4.self_modulate = Color(0.7, 0.7, 0.7)
						%SilverLoc4.self_modulate = Color(0.7, 0.7, 0.7)
			
			%SilverChap.text = chapter_name
			#%SilverPanel5.self_modulate = Color(1.3, 1.3, 1.3)
			#%SilverChap.self_modulate = Color(1.3, 1.3, 1.3)
			
			match locations_to_show.size():
				0:
					#%SilverPanel.self_modulate = Color(1.3, 1.3, 1.3)
					%SilverPanel.self_modulate = Color(1.0, 1.0, 1.0)
					#%SilverLoc1.self_modulate = Color(1.3, 1.3, 1.3)
					%SilverLoc1.self_modulate = Color(1.0, 1.0, 1.0)
				_:
					var back_marg = locations_to_show.back()
					var back_panel = back_marg.get_child(0)
					var back_label = (back_panel.get_child(0).get_child(0)
							.get_child(0))
					
					#back_panel.self_modulate = Color(1.3, 1.3, 1.3)
					back_panel.self_modulate = Color(1.0, 1.0, 1.0)
					#back_label.self_modulate = Color(1.3, 1.3, 1.3)
					back_label.self_modulate = Color(1.0, 1.0, 1.0)
		
		elif location_dict["type"] == 1:
			#%HeaderContainer.show()
			location_1.text = text_dict["loc 1"]
			location_2.text = ""
			location_3.text = ""
			location_4.text = ""
			
			if text_dict["loc 2"] != "":
				%VSeparator2.show()
				location_2.text = text_dict["loc 2"]
				location_2.show()
			
				if text_dict["loc 3"] != "":
					%VSeparator3.show()
					location_3.text = text_dict["loc 3"]
					location_3.show()
				
					if text_dict["loc 4"] != "":
						%VSeparator4.show()
						location_4.text = text_dict["loc 4"]
						location_4.show()
			
			chapter.text = chapter_name
			
			for location in get_tree().get_nodes_in_group("location_labels"):
				location.visible_characters = location.text.length()
	
	else:
		%HeaderContainer.hide()
		%HeaderContainer2.hide()


func next_dialogue():
	var current_dict = dialogue_script[str(dialogue_script_index)]
	var type = DialogueManager.dialogue_script[str(dialogue_script_index)]["type"]
	
	if type == "transition":
		var last_pic = null
		
		for pic in active_pictures.values():
			last_pic = pic
			pic.get_child(0).shrink()
		
		if paired_window != null:
			paired_window.get_child(0).shrink()
			
		if window != null:
			SpeakerName.reset()
			if SpeakerFrame.is_visible_in_tree():
				SpeakerFrame.reset()
			window.get_child(0).shrink()
			
			if not old_box.blank:
				await window.tree_exited
		
		if last_pic != null:
			await last_pic.tree_exited
		
		var trans_dict = current_dict["trans dict"]
		
		if trans_dict["end card"]:
			GlobalData.end_card_moon_color = trans_dict["moon color"]
			GlobalData.end_card_moon_phrase = trans_dict["moon phrase"]
			GlobalData.end_card_moon_phrase_color = trans_dict["phrase color"]
			
			var end_card_path = "res://end_card.tscn"
			var fade_duration = trans_dict["fade duration"]
			var fade_color: Color
			
			if GlobalData.current_chapter + 1 >= GlobalData.chapter_list.size():
				fade_color = Color("ffffff")
			else:
				fade_color = Color("000000")
			
			TransitionManager.fade_to_scene(end_card_path, fade_duration, fade_color)
			await TransitionManager.transition_finished
		
		var next_script = trans_dict["next script"]
		var trans_type = int(trans_dict["trans type"])
		
		match trans_type:
			0: # None
#				if location_dict["type"] == 0:
#					pull_up_all()
#					await locations_pulled_up
#				
				GlobalData.old_locations_to_show.clear()

				for loc in locations_to_show:
					GlobalData.old_locations_to_show.append(loc.get_name())
				
				TransitionManager.no_transition(next_script)
				await TransitionManager.transition_finished
			
			1: # Curtain Wipe
				if location_dict["show"]:
					if location_dict["type"] == 0:
						pull_up_all()
				
				var line_color = trans_dict["line color"]
				TransitionManager.curtain_wipe(next_script, line_color)
				await TransitionManager.transition_finished
			
			2: # Fade
				var fade_duration = trans_dict["fade duration"]
				TransitionManager.fade(next_script, fade_duration)
				await TransitionManager.transition_finished
	
	var start_pic = DialogueManager.dialogue_script[str(dialogue_script_index)]["start picture"]
	var end_pic = DialogueManager.dialogue_script[str(dialogue_script_index)]["end picture"]
	var pics_to_move = DialogueManager.dialogue_script[str(dialogue_script_index)]["pics to move"]
	
	pic_to_show = null
	pic_to_close = null
	
	# Update picture if called for
	if not pics_to_move.is_empty():
		for move_dict in pics_to_move:
			var pic = move_dict["pic name"]
			var move_type = move_dict["move type"]
			var sound_dict = move_dict["sound dict"]
			#print(move_dict)
			#print(sound_dict)
			if sound_dict["play sound"]:
				var pic_marg_cont = active_pictures[pic].get_child(0)
				
				pic_marg_cont.update_play_sound = sound_dict["play sound"]
				pic_marg_cont.update_new_track = sound_dict["new track"]
				pic_marg_cont.update_sound_path = sound_dict["sound path"]
				
				if not sound_dict["new track"]:
					picture_playing_sound = active_pictures[pic]
			
			if move_type == 3: # No movement, only change image
				var new_path = move_dict["new path"]
				var delay_before = move_dict["delay before"]
				var delay_after = move_dict["delay after"]
				
				active_pictures[pic].get_child(0).change_picture(new_path, delay_before, delay_after)
				changing_pic = active_pictures[pic].get_child(0)
				
				if delay_before + delay_after > 0:
					non_zero_delay = true
			else: # Move only, no image change
				var new_pos_x = move_dict["new pos x"]
				var new_pos_y = move_dict["new pos y"]
				
				active_pictures[pic].get_child(0).move_picture(new_pos_x, new_pos_y, move_type)
				moving_pic = active_pictures[pic].get_child(0)
				#moving_pic = active_pictures[pics_to_move.back()["pic name"]].get_child(0)
	
	if start_pic:
		var pic_to_start = DialogueManager.dialogue_script[str(dialogue_script_index)]["picture to start"]
		var pic_path = DialogueManager.dialogue_script[str(dialogue_script_index)]["picture path"]
		var pic_pos_x = DialogueManager.dialogue_script[str(dialogue_script_index)]["picture pos x"]
		var pic_pos_y = DialogueManager.dialogue_script[str(dialogue_script_index)]["picture pos y"]
	#	var _pic_size_x = DialogueManager.dialogue_script[str(dialogue_script_index)]["picture size x"]
	#	var _pic_size_y = DialogueManager.dialogue_script[str(dialogue_script_index)]["picture size y"]
		
		var fade_in = DialogueManager.dialogue_script[str(dialogue_script_index)]["fade in"]
		var fade_in_duration = DialogueManager.dialogue_script[str(dialogue_script_index)]["fade in duration"]
		var fade_in_color = DialogueManager.dialogue_script[str(dialogue_script_index)]["fade in color"]
		var fade_in_solid = DialogueManager.dialogue_script[str(dialogue_script_index)]["fade in solid"]
		var fade_out = DialogueManager.dialogue_script[str(dialogue_script_index)]["fade out"]
		var fade_out_duration = DialogueManager.dialogue_script[str(dialogue_script_index)]["fade out duration"]
		var fade_out_color = DialogueManager.dialogue_script[str(dialogue_script_index)]["fade out color"]
		var fade_out_solid = DialogueManager.dialogue_script[str(dialogue_script_index)]["fade out solid"]
		var first_pic_array
		
		if dialogue_script_index == 0:
			first_pic_array = dialogue_script[str(0)]["first pic dict"]
		
		var sound_dict_array = dialogue_script[str(dialogue_script_index)]["sound dict"]
		
		for i in pic_to_start.size():
			var picture_window_instance = picture_window.instantiate()
			var PictureMarginContainer = picture_window_instance.get_child(0)
			var PictureRect = picture_window_instance.get_node("ExpandShrinkContainer/PictureContainer/Control/PictureRect")
			
			PictureMarginContainer.position = Vector2(pic_pos_x[i], pic_pos_y[i])
			
			if pic_path[i] != "":
				PictureRect.texture = load(pic_path[i])
			else:
				PictureRect.texture = null
				picture_window_instance.hide()
			
		#	PictureRect.size = Vector2(pic_size_x[i], pic_size_y[i])
			PictureRect.fade_in_flag = fade_in[i]
			PictureRect.fade_in_duration = fade_in_duration[i]
			PictureRect.fade_in_color = Color(fade_in_color[i])
			PictureRect.fade_in_solid = fade_in_solid[i]
			PictureRect.fade_out_flag = fade_out[i]
			PictureRect.fade_out_duration = fade_out_duration[i]
			PictureRect.fade_out_color = Color(fade_out_color[i])
			PictureRect.fade_out_solid = fade_out_solid[i]
			
			if sound_dict_array[i]["play sound"]:
				PictureMarginContainer.play_sound = sound_dict_array[i]["play sound"]
				PictureMarginContainer.await_sound = sound_dict_array[i]["await sound"]
				PictureMarginContainer.new_track = sound_dict_array[i]["new track"]
				PictureMarginContainer.sound_path = sound_dict_array[i]["sound path"]
				
				if not sound_dict_array[i]["new track"]:
					picture_playing_sound = picture_window_instance
			
			picture_window_instance.add_to_group("non_paired_pics")
			add_child(picture_window_instance)
			
			if dialogue_script_index == 0:
				PictureRect.top_label.text = first_pic_array[i]["top 1"]
				PictureRect.bott_label.text = first_pic_array[i]["bott 1"]
				PictureMarginContainer.top_2 = first_pic_array[i]["top 2"]
				PictureMarginContainer.bott_2 = first_pic_array[i]["bott 2"]
				PictureMarginContainer.text_color = first_pic_array[i]["color"]
				PictureMarginContainer.show_location = location_dict["show"]
				PictureMarginContainer.location_type = location_dict["type"]
			
			active_pictures[pic_to_start[i]] = picture_window_instance
			pic_to_show = picture_window_instance
	
	if type == "text":
		var speaker_name = DialogueManager.dialogue_script[str(dialogue_script_index)]["name"]
		var text = DialogueManager.dialogue_script[str(dialogue_script_index)]["text"]
		var new_box = DialogueManager.dialogue_script[str(dialogue_script_index)]["new"]
		var dialogue_sound_dict = dialogue_script[str(dialogue_script_index)]["dialogue sound dict"]
		
		if new_box:
			var width = DialogueManager.dialogue_script[str(dialogue_script_index)]["width"]
			var pos_x = DialogueManager.dialogue_script[str(dialogue_script_index)]["pos x"]
			var pos_y = DialogueManager.dialogue_script[str(dialogue_script_index)]["pos y"]
			var paired = DialogueManager.dialogue_script[str(dialogue_script_index)]["paired"]
			var lines = DialogueManager.dialogue_script[str(dialogue_script_index)]["lines"]
			
			var dialogue_window_instance = dialogue_window.instantiate()
			var Dialogue = dialogue_window_instance.get_node("ExpandShrinkContainer/DialogueContainer/DialoguePadding/Dialogue")
			
			if end_pic:
				var pic_to_end = DialogueManager.dialogue_script[str(dialogue_script_index)]["picture to end"]
				
				pic_to_close = active_pictures.get(pic_to_end[0])
				
				for i in pic_to_end.size():
					active_pictures.get(pic_to_end[i]).get_child(0).shrink()
			
			if paired_window != null:
				paired_window.get_child(0).shrink()
			
			if window != null:
				SpeakerName.reset()
				if SpeakerFrame.is_visible_in_tree():
					SpeakerFrame.reset()
				window.get_child(0).shrink()
				
				if not old_box.blank:
					await window.tree_exited
			
			window = dialogue_window_instance
			old_box = Dialogue
			
			Dialogue.dialogue_finished.connect(_on_dialogue_dialogue_finished)
			
			dialogue_window_instance.position = Vector2(pos_x, pos_y)
			Dialogue.text = text
			Dialogue.dialogue_width = width
			Dialogue.lines = lines
			
			if dialogue_sound_dict["change bgm"]:
				dialogue_window_instance.get_child(0).change_bgm = dialogue_sound_dict["change bgm"]
				dialogue_window_instance.get_child(0).sound_path = dialogue_sound_dict["sound path"]
			
			add_child(dialogue_window_instance)
			
			if window.get_child(0).waiting_to_expand:
				await window.get_child(0).expand_started
			
			if paired:
				var texture_path = DialogueManager.dialogue_script[str(dialogue_script_index)]["path"]
				var picture_pos_x = DialogueManager.dialogue_script[str(dialogue_script_index)]["paired pos x"]
				var picture_pos_y = DialogueManager.dialogue_script[str(dialogue_script_index)]["paired pos y"]
				var paired_auto = DialogueManager.dialogue_script[str(dialogue_script_index)]["paired_auto"]
				var paired_auto_option = DialogueManager.dialogue_script[str(dialogue_script_index)]["paired auto option"]
				var speaker_option = DialogueManager.dialogue_script[str(dialogue_script_index)]["speaker option"]
				
				var picture_window_instance = picture_window.instantiate()
				var PictureRect = picture_window_instance.get_node("ExpandShrinkContainer/PictureContainer/Control/PictureRect")
				
				picture_window_instance.get_child(0).paired = true
				paired_window = picture_window_instance
				PictureRect.texture = load(texture_path)
				
				add_child(picture_window_instance)
				
				picture_window_instance.z_index = 1
				picture_window_instance.position = Vector2(picture_pos_x, picture_pos_y)
				
				if paired_auto:
					if paired_auto_option == 0 or paired_auto_option == 1:
						picture_window_instance.position.y = dialogue_window_instance.position.y - (picture_window_instance.get_child(0).size.y - dialogue_window_instance.get_child(0).size.y)
				
				SpeakerFrame.show()
				SpeakerFrame.size = picture_window_instance.get_child(0).size + Vector2(14, 14)
				SpeakerFrame.position = picture_window_instance.position - Vector2(7, 7)
				SpeakerFrame.pulse()
				
				FrameLineControl.move_to_frame()
				
				SpeakerName.text = speaker_name
				SpeakerName.reset_size()
				
				if speaker_option == 0:
					SpeakerName.position = SpeakerFrame.position - Vector2(0, SpeakerName.size.y)
				elif speaker_option == 1:
					SpeakerName.position = SpeakerFrame.position + Vector2(0, SpeakerFrame.size.y)
				elif speaker_option == 2:
					SpeakerName.position = SpeakerFrame.position + Vector2(-(SpeakerName.size.x + 10), (SpeakerFrame.size.y / 2) - (SpeakerName.size.y / 2))
				elif speaker_option == 3:
					SpeakerName.position = SpeakerFrame.position + Vector2(SpeakerFrame.size.x + 10, (SpeakerFrame.size.y / 2) - (SpeakerName.size.y / 2))
				
				SpeakerName.begin()
				
			else:
				var show_frame = DialogueManager.dialogue_script[str(dialogue_script_index)]["show frame"]
				
				if show_frame:
				
					var frame_size_x = DialogueManager.dialogue_script[str(dialogue_script_index)]["frame size x"]
					var frame_size_y = DialogueManager.dialogue_script[str(dialogue_script_index)]["frame size y"]
					var frame_pos_x = DialogueManager.dialogue_script[str(dialogue_script_index)]["frame pos x"]
					var frame_pos_y = DialogueManager.dialogue_script[str(dialogue_script_index)]["frame pos y"]
					var speaker_pos_x = DialogueManager.dialogue_script[str(dialogue_script_index)]["speaker pos x"]
					var speaker_pos_y = DialogueManager.dialogue_script[str(dialogue_script_index)]["speaker pos y"]
					
					SpeakerFrame.show()
					SpeakerFrame.size = Vector2(frame_size_x, frame_size_y)
					SpeakerFrame.position = Vector2(frame_pos_x, frame_pos_y)
					SpeakerFrame.pulse()
					
					FrameLineControl.move_to_frame()
					
					SpeakerName.text = speaker_name
					SpeakerName.reset_size()
					SpeakerName.position = Vector2(speaker_pos_x, speaker_pos_y)
					SpeakerName.begin()
			
		else:
			# Reuse the old box and just update the text.
			var wipe = DialogueManager.dialogue_script[str(dialogue_script_index)]["wipe"]
			
			if wipe:
				window.get_node("ExpandShrinkContainer/DialogueContainer/BoxWipeContainer").box_wipe_vertical(text)
			else:
				window.get_node("ExpandShrinkContainer/DialogueContainer/DialoguePadding/Dialogue").add_to_next_line(text)
			
			window.get_node("ExpandShrinkContainer/DialogueContainer/DialoguePadding/Dialogue").allow_input = true
	
	
	elif type == "blank":
		var dialogue_window_instance = dialogue_window.instantiate()
		var Dialogue = dialogue_window_instance.get_node("ExpandShrinkContainer/DialogueContainer/DialoguePadding/Dialogue")
		var dialogue_sound_dict = dialogue_script[str(dialogue_script_index)]["dialogue sound dict"]
		
		if end_pic:
			var pic_to_end = DialogueManager.dialogue_script[str(dialogue_script_index)]["picture to end"]
			
			pic_to_close = active_pictures.get(pic_to_end[0])
			
			for i in pic_to_end.size():
				active_pictures.get(pic_to_end[i]).get_child(0).shrink()
				#active_pictures.erase(pic_to_end[i])
		
		if paired_window != null:
			paired_window.get_child(0).shrink()

		if window != null:
		#	if SpeakerName.is_visible_in_tree():
			SpeakerName.reset()
			if SpeakerFrame.is_visible_in_tree():
				SpeakerFrame.reset()
			window.get_child(0).shrink()
			await window.tree_exited
		
		window = dialogue_window_instance
		old_box = Dialogue
		Dialogue.blank = true
		Dialogue.text = ""
		Dialogue.dialogue_finished.connect(_on_dialogue_dialogue_finished)
		
		if dialogue_sound_dict["change bgm"]:
			dialogue_window_instance.get_child(0).change_bgm = dialogue_sound_dict["change bgm"]
			dialogue_window_instance.get_child(0).sound_path = dialogue_sound_dict["sound path"]
		
		add_child(dialogue_window_instance)
		dialogue_window_instance.hide()


func _on_dialogue_dialogue_finished():
	dialogue_script_index += 1
	
	if dialogue_script_index <= DialogueManager.dialogue_script.size() - 1:
		next_dialogue()
	
	else:
	#	if SpeakerName.is_visible_in_tree():
		SpeakerName.reset()
		if SpeakerFrame.is_visible_in_tree():
			SpeakerFrame.reset()
		
		window.get_child(0).final_window = true
		window.get_child(0).shrink()
		
		if paired_window != null:
			paired_window.get_child(0).shrink()
		
		if not active_pictures.is_empty():
			for key in active_pictures.keys():
				active_pictures.get(key).get_child(0).shrink()
				#active_pictures.erase(key)
		
	#	get_tree().quit()


func _on_return_button_pressed():
	SoundManager.stop_picture_sound()
	SoundManager.stop_background_music(false)
	SoundManager.stop_typing_sound()
	SoundManager.stop_first_pic_appear()
	SoundManager.stop_first_pic_disappear()
	SoundManager.stop_location_sound(false)
	
	$ReturnButton.hide()
	$RestartButton.hide()
	$QuitButton.hide()
	GlobalData.running_from_editor = false
	SceneSwitcher.go_to_preserved()


func _on_restart_button_pressed():
	SoundManager.stop_picture_sound()
	SoundManager.stop_background_music(false)
	SoundManager.stop_typing_sound()
	SoundManager.stop_first_pic_appear()
	SoundManager.stop_first_pic_disappear()
	SoundManager.stop_location_sound(false)
	SceneSwitcher.go_to_scene("res://main1.tscn")


func _on_main_1_locations_pulled_up():
	#get_tree().quit()
	pass


func _on_quit_button_pressed():
	get_tree().quit()


func _on_color_rect_visibility_changed():
	if %ColorRect.is_visible_in_tree():
		#print("visible")
		pass
	else:
		#print("hidden")
		pass


func _on_picture_sound_finished():
	if picture_playing_sound != null:
		picture_playing_sound.get_child(0).await_sound = false
	
	picture_playing_sound = null
