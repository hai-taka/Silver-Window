extends Control

signal flash_finished
signal animate_finished
signal overwrite_chosen(yes: bool)

@export var load_menu: bool = true

var post_load = preload("res://post_load.tscn")
var menu_colors: Resource = preload("res://resources/Data/main_menu_colors.tres")
var first_focus: bool = true
var allow_input: bool = false
var post_end_card: bool = false
var from_pause: bool = false

var save_paths: Array[String] = [
		"user://savegame_1.save",
		"user://savegame_2.save",
		"user://savegame_3.save"
	]

#var load_dict_1
#var load_dict_2
#var load_dict_3

@onready var background = %Background
@onready var file_v_box = %FileVBox
@onready var save_panel_1 = %SavePanel1
@onready var slot_label_1 = %SlotLabel1
@onready var save_info_v_box_1 = %SaveInfoVBox1
@onready var chapter_label_1 = %ChapterLabel1
@onready var date_label_1 = %DateLabel1
@onready var play_time_label_1 = %PlayTimeLabel1
@onready var blank_container_1 = %BlankContainer1
@onready var save_panel_2 = %SavePanel2
@onready var slot_label_2 = %SlotLabel2
@onready var save_info_v_box_2 = %SaveInfoVBox2
@onready var chapter_label_2 = %ChapterLabel2
@onready var date_label_2 = %DateLabel2
@onready var play_time_label_2 = %PlayTimeLabel2
@onready var blank_container_2 = %BlankContainer2
@onready var save_panel_3 = %SavePanel3
@onready var slot_label_3 = %SlotLabel3
@onready var save_info_v_box_3 = %SaveInfoVBox3
@onready var chapter_label_3 = %ChapterLabel3
@onready var date_label_3 = %DateLabel3
@onready var play_time_label_3 = %PlayTimeLabel3
@onready var blank_container_3 = %BlankContainer3
@onready var completion_icon_1 = %CompletionIcon1
@onready var completion_icon_2 = %CompletionIcon2
@onready var completion_icon_3 = %CompletionIcon3
@onready var menu_title_label = %MenuTitleLabel
@onready var back_button = %BackButton
@onready var overwrite_yes = %OverwriteYes
@onready var overwrite_no = %OverwriteNo
@onready var overwrite_h_box = %OverwriteHBox
@onready var yes_rich_text = %YesRichText
@onready var no_rich_text = %NoRichText

@onready var reg_stylebox: StyleBoxFlat = save_panel_1.get_theme_stylebox("panel").duplicate()
@onready var focus_stylebox: StyleBoxFlat = reg_stylebox.duplicate()

func _ready():
	if load_menu:
		menu_title_label.text = "Load"
	else:
		menu_title_label.text = "Save"
	
	reg_stylebox.border_color = menu_colors.button_reg_color
	focus_stylebox.border_color = menu_colors.file_select_border_color
	background.color = menu_colors.bg_color
	
	save_panel_1.hide()
	save_panel_2.hide()
	save_panel_3.hide()
	
	for panel in file_v_box.get_children():
		if panel is PanelContainer:
			panel.add_theme_stylebox_override("panel", reg_stylebox)
			set_up_slot(panel)
			panel.focus_entered.connect(_on_save_panel_focus_entered.bind(panel))
			panel.focus_exited.connect(_on_save_panel_focus_exited.bind(panel))
			panel.mouse_entered.connect(_on_save_panel_mouse_entered.bind(panel))
			panel.gui_input.connect(_on_save_panel_gui_input.bind(panel))
	
	for button in get_tree().get_nodes_in_group("file_menu_buttons"):
		if button is Button:
#			button.add_theme_color_override("font_focus_color", 
#					menu_colors.file_select_border_color)
#			button.add_theme_color_override("font_hover_color", 
#					menu_colors.file_select_border_color)
#			button.add_theme_color_override("font_hover_pressed_color", 
#					menu_colors.file_select_border_color)
#			button.add_theme_color_override("font_pressed_color", 
#					menu_colors.file_select_border_color)
			
			button.mouse_entered.connect(_on_menu_button_mouse_entered.bind(button))
			button.focus_entered.connect(_on_menu_button_focus_entered.bind(button))
			
			if button != back_button:
				button.focus_exited.connect(_on_menu_button_focus_exited.bind(button))
	
	#await get_tree().create_timer(1.0).timeout
	animate(0.2)
	await animate_finished
	save_panel_1.grab_focus()
	first_focus = false
	allow_input = true


func load_json(path: String):
	if not FileAccess.file_exists(path):
		#print("Error: File does not exist.")
		return null
	
	var save_game = FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(save_game.get_as_text())
	
	if parsed is Dictionary:
		return parsed
	else:
		print("Error: Parsed result not dictionary.")
		return null


func format_datetime() -> String:
	var current_datetime = Time.get_datetime_dict_from_system()
	var datetime_string = (
			current_datetime["year"] + "-" 
			+ current_datetime["month"] + "-" 
			+ current_datetime["day"]
	)
	return datetime_string


func calculate_play_time() -> Dictionary:
	var play_time: Dictionary = GlobalData.play_time_at_load.duplicate()
	var start_time: float = GlobalData.unix_time_at_load
	var current_time: float = Time.get_unix_time_from_system()
	
	if start_time == 0.0:
		start_time = current_time
	
	var elapsed_seconds: int = roundi(current_time - start_time) # in seconds
	@warning_ignore("integer_division")
	var elapsed_hours: int = elapsed_seconds / 3600
	elapsed_seconds -= elapsed_hours * 3600
	@warning_ignore("integer_division")
	var elapsed_minutes: int = elapsed_seconds / 60
	elapsed_seconds -= elapsed_minutes * 60
	
	play_time["seconds"] += elapsed_seconds
	
	if play_time["seconds"] >= 60:
		play_time["seconds"] -= 60
		play_time["minutes"] += 1
	
	play_time["minutes"] += elapsed_minutes
	
	if play_time["minutes"] >= 60:
		play_time["minutes"] -= 60
		play_time["hours"] += 1
	
	play_time["hours"] += elapsed_hours
	
	if play_time["hours"] > 999:
		play_time["hours"] = 999
	
	return play_time


func play_time_dict_to_string(play_time_dict: Dictionary) -> String:
	var hours: String = str(play_time_dict["hours"])
	var minutes: String = str(play_time_dict["minutes"])
	var seconds: String = str(play_time_dict["seconds"])
	
	if seconds.length() == 1:
		seconds = "0" + seconds
	
	if minutes.length() == 1:
		minutes = "0" + minutes
	
	if hours.length() == 1:
		hours = "00" + hours
	
	var play_time_string: String = "Play Time: " + hours + "H " + minutes + "M " + seconds + "S"
	
	return play_time_string


func set_up_slot(panel: PanelContainer) -> void:
	if panel == save_panel_1:
		var load_dict = load_json(save_paths[0])
		
		if load_dict == null:
			save_info_v_box_1.hide()
			blank_container_1.show()
			completion_icon_1.hide()
		else:
			chapter_label_1.text = load_dict["chapter_name"]
			date_label_1.text = load_dict["date"]
			var play_time_string = play_time_dict_to_string(load_dict["play_time"])
			play_time_label_1.text = play_time_string
			completion_icon_1.visible = load_dict["game_completed"]
			
			save_info_v_box_1.show()
			blank_container_1.hide()
	
	elif panel == save_panel_2:
		var load_dict = load_json(save_paths[1])
		
		if load_dict == null:
			save_info_v_box_2.hide()
			blank_container_2.show()
			completion_icon_2.hide()
		else:
			chapter_label_2.text = load_dict["chapter_name"]
			date_label_2.text = load_dict["date"]
			var play_time_string = play_time_dict_to_string(load_dict["play_time"])
			play_time_label_2.text = play_time_string
			completion_icon_2.visible = load_dict["game_completed"]
			
			save_info_v_box_2.show()
			blank_container_2.hide()
	
	elif panel == save_panel_3:
		var load_dict = load_json(save_paths[2])
		
		if load_dict == null:
			save_info_v_box_3.hide()
			blank_container_3.show()
			completion_icon_3.hide()
		else:
			chapter_label_3.text = load_dict["chapter_name"]
			date_label_3.text = load_dict["date"]
			var play_time_string = play_time_dict_to_string(load_dict["play_time"])
			play_time_label_3.text = play_time_string
			completion_icon_3.visible = load_dict["game_completed"]
			
			save_info_v_box_3.show()
			blank_container_3.hide()


func animate(delay: float = 0.0) -> void:
	for panel in file_v_box.get_children():
		flash_panel(panel, 2)
		await flash_finished
		
		if delay != 0.0:
			await get_tree().create_timer(delay).timeout
	
	animate_finished.emit()


func flash_panel(panel: PanelContainer, flashes: int = 3) -> void:
	var delay: float = 0.05
	
	for i in flashes:
		panel.show()
		await get_tree().create_timer(delay).timeout
		
		if i != flashes - 1:
			panel.hide()
			await get_tree().create_timer(delay).timeout
	
	flash_finished.emit(panel)


func _unhandled_input(event):
	if not allow_input:
		return
	
	if event.is_action_pressed("ui_cancel"):
		accept_event()
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
		back_button.pressed.emit()


func _on_save_panel_focus_entered(panel: PanelContainer):
	if not first_focus:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)
	
	var slot: Label = (
			slot_label_1 if panel == save_panel_1
			else slot_label_2 if panel == save_panel_2
			else slot_label_3
	)
	panel.add_theme_stylebox_override("panel", focus_stylebox)
	slot.add_theme_color_override("font_color", menu_colors.shake_color)


func _on_save_panel_focus_exited(panel: PanelContainer):
	if not allow_input: # Keep highlight colors if prompting overwrite
		return
	
	var slot: Label = (
			slot_label_1 if panel == save_panel_1
			else slot_label_2 if panel == save_panel_2
			else slot_label_3
	)
	panel.add_theme_stylebox_override("panel", reg_stylebox)
	slot.add_theme_color_override("font_color", menu_colors.border_color)


func _on_save_panel_mouse_entered(panel: PanelContainer):
	if not allow_input:
		return
	
	if panel.focus_mode != FOCUS_NONE:
		panel.grab_focus()


func _on_save_panel_gui_input(event: InputEvent, panel: PanelContainer):
	if not allow_input:
		return
	
	if (
			event.is_action_pressed("ui_accept") 
			or event is InputEventMouseButton and event.button_index == 1 and event.pressed
	):
		allow_input = false
		
		var path: String = (
				save_paths[0] if panel == save_panel_1
				else save_paths[1] if panel == save_panel_2
				else save_paths[2]
		)
		
		if load_menu: # Loading game
			var load_dict = load_json(path)
			
			if load_dict == null:
				SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
				allow_input = true
				return
			
			SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
			#print(load_dict)
			GlobalData.initialize()
			GlobalData.unix_time_at_load = Time.get_unix_time_from_system()
			GlobalData.current_chapter = load_dict["chapter"]
			GlobalData.furthest_chapter = load_dict["furthest_chapter"]
			GlobalData.game_completed = load_dict["game_completed"]
			GlobalData.play_time_at_load = load_dict["play_time"].duplicate()
			DialogueManager.change_script(load_dict["dialogue_script_path"])
			
			var post_load_instance = post_load.instantiate()
			post_load_instance.selected_slot = panel
			panel.release_focus()
			allow_input = false
			first_focus = true
			add_child(post_load_instance)
			
		else: # Saving game
			SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
			
			# Check if overwriting
			if FileAccess.file_exists(path):
				back_button.hide()
				overwrite_h_box.show()
				first_focus = true
				overwrite_yes.grab_focus()
				first_focus = false
				
				for slot in file_v_box.get_children():
					if slot is PanelContainer:
						slot.focus_mode = Control.FOCUS_NONE
				
				var confirm = await overwrite_chosen
				
				for slot in file_v_box.get_children():
					if slot is PanelContainer:
						slot.focus_mode = Control.FOCUS_ALL
				
				if not confirm:
					first_focus = true
					panel.grab_focus()
					first_focus = false
					allow_input = true
					return
				else:
					first_focus = true
					panel.grab_focus()
					first_focus = false
			
			var save_game = FileAccess.open(path, FileAccess.WRITE)
			var save_dict: Dictionary = {
				"chapter": GlobalData.current_chapter,
				"chapter_name": GlobalData.chapter_list[GlobalData.current_chapter],
				"dialogue_script_path": DialogueManager.dialogue_script_file_path,
				"furthest_chapter": GlobalData.furthest_chapter,
				"game_completed": GlobalData.game_completed,
				"date": Time.get_datetime_string_from_system(false, true),
				"play_time": calculate_play_time(),
			}
			var json_string = JSON.stringify(save_dict, "\t")
			#print(json_string)
			save_game.store_string(json_string)
			save_game.close()
			
			set_up_slot(panel)
			allow_input = true


func _on_menu_button_mouse_entered(button: Button):
	if not allow_input and button == back_button:
		return
	
	button.grab_focus()


func _on_menu_button_focus_entered(_button: Button):
	if not first_focus:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)
#
#	if button == overwrite_yes:
#		button.add_theme_color_override("font_focus_color", Color.TRANSPARENT)
#		button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
#		button.add_theme_color_override("font_hover_pressed_color", Color.TRANSPARENT)
#		button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
#		yes_rich_text.show()
#		yes_rich_text.add_theme_color_override("default_color", menu_colors.button_focus_color)
#		yes_rich_text.text = "[wave amp=100.0 freq=5.0 connected=0][center]Yes[/center][/wave]"
#
#	elif button == overwrite_no:
#		button.add_theme_color_override("font_focus_color", Color.TRANSPARENT)
#		button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
#		button.add_theme_color_override("font_hover_pressed_color", Color.TRANSPARENT)
#		button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
#		no_rich_text.show()
#		no_rich_text.add_theme_color_override("default_color", menu_colors.button_focus_color)
#		no_rich_text.text = "[wave amp=100.0 freq=5.0 connected=0][center]No[/center][/wave]"


func _on_menu_button_focus_exited(_button: Button):
	pass
#	if button == overwrite_yes:
#		button.add_theme_color_override("font_focus_color", menu_colors.button_reg_color)
#		button.add_theme_color_override("font_hover_color", menu_colors.button_reg_color)
#		button.add_theme_color_override("font_hover_pressed_color", menu_colors.button_reg_color)
#		button.add_theme_color_override("font_pressed_color", menu_colors.button_reg_color)
#		yes_rich_text.hide()
#		yes_rich_text.add_theme_color_override("default_color", Color.TRANSPARENT)
#		yes_rich_text.text = "[center]Yes[/center]"
#
#	elif button == overwrite_no:
#		button.add_theme_color_override("font_focus_color", menu_colors.button_reg_color)
#		button.add_theme_color_override("font_hover_color", menu_colors.button_reg_color)
#		button.add_theme_color_override("font_hover_pressed_color", menu_colors.button_reg_color)
#		button.add_theme_color_override("font_pressed_color", menu_colors.button_reg_color)
#		no_rich_text.hide()
#		no_rich_text.add_theme_color_override("default_color", Color.TRANSPARENT)
#		no_rich_text.text = "[center]No[/center]"


func _on_back_button_pressed():
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
	
	if get_parent() == get_tree().root:
		get_tree().quit()
	
	elif post_end_card:
		queue_free()
	
	elif from_pause:
		get_parent().first_focus = true
		get_parent().save_button.grab_focus()
		get_parent().first_focus = false
		#get_parent().allow_input = true
		queue_free()
	
	else:
		get_parent().first_focus = true
		get_parent().load_button.grab_focus()
		get_parent().first_focus = false
		get_parent().allow_input = true
		queue_free()


func _on_overwrite_yes_pressed():
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	overwrite_chosen.emit(true)
	overwrite_h_box.hide()
	back_button.show()


func _on_overwrite_no_pressed():
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
	overwrite_chosen.emit(false)
	overwrite_h_box.hide()
	back_button.show()
