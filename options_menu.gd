extends Control

signal flash_finished

@export var from_pause: bool = false

var menu_colors: Resource = preload("res://resources/Data/main_menu_colors.tres")
var menu_popup = preload("res://menu_popup.tscn")

var first_focus: bool = true
var prev_focus: Button = null
var allow_input: bool = false

@onready var background_rect = $BackgroundRect
@onready var options_panel = %OptionsPanel
@onready var options_panel_stylebox: StyleBoxFlat = options_panel.get_theme_stylebox("panel")
@onready var options_panel_default_color: Color = menu_colors.border_color
@onready var panel_margin = %PanelMargin
@onready var display_button = %DisplayButton
@onready var audio_button = %AudioButton
@onready var data_button = %DataButton
@onready var licenses_button = %LicensesButton
@onready var back_button = %BackButton
@onready var item_margin = %ItemMargin
@onready var item_vbox = %ItemVBox
@onready var menu_vsep = %MenuVSep
@onready var menu_vsep_stylebox: StyleBoxLine = menu_vsep.get_theme_stylebox("separator")
@onready var panel_hbox = %PanelHBox
@onready var right_vbox = %RightVBox
@onready var display_scroll = %DisplayScroll
@onready var audio_scroll = %AudioScroll
@onready var data_scroll = %DataScroll
@onready var licenses_scroll = %LicensesScroll
@onready var window_options = %WindowOptions
@onready var window_options_popup: PopupMenu = window_options.get_popup()
@onready var resolution_options = %ResolutionOptions
@onready var resolution_options_popup: PopupMenu = resolution_options.get_popup()
@onready var h_separator = %HSeparator
@onready var h_sep_stylebox: StyleBoxLine = h_separator.get_theme_stylebox("separator")
@onready var master_vol_label = %MasterVolLabel
@onready var music_vol_label = %MusicVolLabel
@onready var sfx_vol_label = %SFXVolLabel
@onready var typing_vol_label = %TypingVolLabel
@onready var master_slider = %MasterSlider
@onready var music_slider = %MusicSlider
@onready var sfx_slider = %SFXSlider
@onready var typing_slider = %TypingSlider
@onready var ui_sound_button = %UISoundButton
@onready var ui_sound_label = %UISoundLabel
@onready var delete_button_1 = %DeleteButton1
@onready var delete_button_2 = %DeleteButton2
@onready var delete_button_3 = %DeleteButton3
@onready var engine_license_label = %EngineLicenseLabel
@onready var v_scroll: VScrollBar = licenses_scroll.get_v_scroll_bar()
@onready var vscroll_grabber_stylebox: StyleBoxFlat = get_theme().get_stylebox(
		"grabber", "VScrollBar")
@onready var vscroll_scroll_stylebox: StyleBoxFlat = get_theme().get_stylebox(
		"scroll", "VScrollBar")
@onready var bg_color = menu_colors.bg_color

# Theme stuff
@onready var grabber_area: StyleBoxFlat = get_theme_stylebox("grabber_area", "HSlider")
@onready var grabber_area_highlight: StyleBoxFlat = get_theme_stylebox(
		"grabber_area_highlight", "HSlider")
@onready var slider: StyleBoxFlat = get_theme_stylebox("slider", "HSlider")
@onready var slider_focus: StyleBoxFlat = slider.duplicate()
@onready var popup_menu_panel_stylebox: StyleBoxFlat = get_theme_stylebox("panel", "PopupMenu")
@onready var popup_menu_separator_stylebox: StyleBoxLine = get_theme_stylebox(
		"separator", "PopupMenu")
@onready var vscroll_grabber_highlight_stylebox: StyleBoxFlat = get_theme_stylebox(
		"grabber_highlight", "VScrollBar"
)
@onready var vscroll_grabber_pressed_stylebox: StyleBoxFlat = get_theme_stylebox(
		"grabber_pressed", "VScrollBar"
)


func _ready():
	load_options()
	
	grabber_area.bg_color = menu_colors.button_reg_color
	grabber_area_highlight.bg_color = menu_colors.button_focus_color
	slider.border_color = menu_colors.button_reg_color
	slider_focus.border_color = menu_colors.button_focus_color
	ui_sound_button.self_modulate = menu_colors.button_reg_color
	theme.set_color("font_color", "OptionButton", menu_colors.button_reg_color)
	var disabled_color: Color = menu_colors.button_reg_color
	disabled_color.a = 0.5
	theme.set_color("font_disabled_color", "OptionButton", disabled_color)
	theme.set_color("font_focus_color", "OptionButton", menu_colors.button_focus_color)
	theme.set_color("font_color", "PopupMenu", menu_colors.button_reg_color)
	theme.set_color("font_hover_color", "PopupMenu", menu_colors.button_focus_color)
	popup_menu_panel_stylebox.bg_color = menu_colors.bg_color
	popup_menu_panel_stylebox.border_color = menu_colors.border_color
	popup_menu_separator_stylebox.color = menu_colors.border_color
	vscroll_grabber_highlight_stylebox.bg_color = menu_colors.border_color
	vscroll_grabber_pressed_stylebox.bg_color = menu_colors.border_color
	delete_button_1.add_theme_color_override("font_disabled_color", disabled_color)
	delete_button_1.add_theme_color_override("icon_disabled_color", disabled_color)
	delete_button_2.add_theme_color_override("font_disabled_color", disabled_color)
	delete_button_2.add_theme_color_override("icon_disabled_color", disabled_color)
	delete_button_3.add_theme_color_override("font_disabled_color", disabled_color)
	delete_button_3.add_theme_color_override("icon_disabled_color", disabled_color)
	
	for button in get_tree().get_nodes_in_group("delete_buttons"):
		check_save_files(button)
	
	background_rect.color = bg_color
	vscroll_scroll_stylebox.border_color = bg_color
	v_scroll.focus_mode = Control.FOCUS_ALL
	v_scroll.step = 20
	v_scroll.focus_neighbor_left = v_scroll.get_path()
	v_scroll.focus_neighbor_right = v_scroll.get_path()
	v_scroll.focus_next = v_scroll.get_path()
	v_scroll.focus_previous = v_scroll.get_path()
	v_scroll.focus_entered.connect(_on_v_scroll_focus_entered)
	v_scroll.focus_exited.connect(_on_v_scroll_focus_exited)
	
	for item in get_tree().get_nodes_in_group("options_menu_items"):
		item.focus_entered.connect(_on_options_menu_item_focus_entered.bind(item))
		item.mouse_entered.connect(_on_options_menu_item_mouse_entered.bind(item))
		
		if item is HSlider:
			item.focus_exited.connect(_on_h_slider_focus_exited.bind(item))
		elif get_tree().get_nodes_in_group("delete_buttons").has(item):
			item.focus_exited.connect(_on_delete_button_focus_exited.bind(item))
	
	window_options_popup.window_input.connect(_on_popup_window_input)
	resolution_options_popup.window_input.connect(_on_popup_window_input)
	
	h_sep_stylebox.color = options_panel_default_color
	engine_license_label.text += Engine.get_license_text()
	vscroll_grabber_stylebox.bg_color = options_panel_default_color
	#vscroll_grabber_stylebox.bg_color.a = 0.5
	menu_vsep_stylebox.color = options_panel_default_color


func load_options() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://options.cfg")
	
	if err != OK:
		return
	
	var window_mode = config.get_value("Display", "window_mode")
	var windowed_res = config.get_value("Display", "windowed_res")
	
	var master_volume = config.get_value("Audio", "master_volume")
	var music_volume = config.get_value("Audio", "music_volume")
	var sfx_volume = config.get_value("Audio", "sfx_volume")
	var typing_volume = config.get_value("Audio", "typing_volume")
	var ui_sound = config.get_value("Audio", "ui_sound")
	
	window_options.selected = window_mode
	resolution_options.selected = windowed_res
	master_slider.value = master_volume
	music_slider.value = music_volume
	sfx_slider.value = sfx_volume
	typing_slider.value = typing_volume
	ui_sound_button.button_pressed = ui_sound


func save_options() -> void:
	var config = ConfigFile.new()
	
	config.set_value("Display", "window_mode", window_options.selected)
	config.set_value("Display", "windowed_res", resolution_options.selected)
	
	config.set_value("Audio", "master_volume", master_slider.value)
	config.set_value("Audio", "music_volume", music_slider.value)
	config.set_value("Audio", "sfx_volume", sfx_slider.value)
	config.set_value("Audio", "typing_volume", typing_slider.value)
	config.set_value("Audio", "ui_sound", ui_sound_button.button_pressed)
	
	config.save("user://options.cfg")


func check_save_files(button: Button) -> void:
	if button == delete_button_1:
		if not FileAccess.file_exists("user://savegame_1.save"):
			delete_button_1.disabled = true
			delete_button_1.focus_mode = FOCUS_NONE
	elif  button == delete_button_2:
		if not FileAccess.file_exists("user://savegame_2.save"):
			delete_button_2.disabled = true
			delete_button_2.focus_mode = FOCUS_NONE
	elif button == delete_button_3:
		if not FileAccess.file_exists("user://savegame_3.save"):
			delete_button_3.disabled = true
			delete_button_3.focus_mode = FOCUS_NONE


func grow_menu_vsep(speed: int = 3000) -> void:
	menu_vsep_stylebox.grow_begin = -308
	menu_vsep_stylebox.grow_end = -308
	
	var duration = 307 / float(speed)
	var tween = create_tween()
	
	tween.tween_property(menu_vsep_stylebox, "grow_begin", 1, duration)
	tween.parallel().tween_property(menu_vsep_stylebox, "grow_end", 1, duration)
	
	await tween.finished
	tween.kill()


func reveal_menu_items(delay: float = 0.05) -> void:
	for child in item_vbox.get_children():
		if child is HBoxContainer:
			child.hide()
	
	item_vbox.show()
	for child in item_vbox.get_children():
		if child is HBoxContainer:
			child.show()
			await get_tree().create_timer(delay).timeout


func flash_panel(flashes: int = 2, delay: float = 0.05) -> void:
	options_panel_stylebox.border_color = bg_color
	
	for i in flashes:
		options_panel_stylebox.border_color = options_panel_default_color
		await get_tree().create_timer(delay).timeout
		options_panel_stylebox.border_color = bg_color
		await get_tree().create_timer(delay).timeout
	
	options_panel_stylebox.border_color = options_panel_default_color
	flash_finished.emit()


func _unhandled_input(event):
	if not allow_input or not visible:
		return
	
	if event.is_action_pressed("ui_cancel"):
		accept_event()
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
		
		if (
				display_scroll.is_visible_in_tree()
				or audio_scroll.is_visible_in_tree()
				or licenses_scroll.is_visible_in_tree()
				or data_scroll.is_visible_in_tree()
		):
			first_focus = true
			display_scroll.hide()
			audio_scroll.hide()
			licenses_scroll.hide()
			data_scroll.hide()
			prev_focus.grab_focus()
			first_focus = false
		else:
			back_button.pressed.emit(true)


func _on_back_button_pressed(from_cancel: bool = false):
	if not allow_input:
		return
	
	save_options()
	
	if get_parent() == get_tree().root:
		get_tree().quit()
		return
	
	if from_pause:
		get_parent().first_focus = true
		get_parent().options_button.grab_focus()
		get_parent().first_focus = false
	else:
		get_parent().allow_input = true
		get_parent().first_focus = true
		get_parent().opt_button.grab_focus()
		get_parent().first_focus = false
	
	if from_cancel:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
	else:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
	
	#queue_free()
	hide()


func _on_display_button_pressed():
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	first_focus = true
	display_scroll.show()
	audio_scroll.hide()
	licenses_scroll.hide()
	data_scroll.hide()
	prev_focus = display_button
	window_options.grab_focus()
	first_focus = false


func _on_audio_button_pressed():
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	first_focus = true
	display_scroll.hide()
	audio_scroll.show()
	licenses_scroll.hide()
	data_scroll.hide()
	prev_focus = audio_button
	master_slider.grab_focus()
	first_focus = false


func _on_licenses_button_pressed():
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	display_scroll.hide()
	audio_scroll.hide()
	licenses_scroll.show()
	data_scroll.hide()
	prev_focus = licenses_button
	await get_tree().process_frame
	v_scroll.grab_focus()


func _on_window_options_item_selected(index):
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	
	match index:
		0: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			resolution_options.disabled = true
			resolution_options.focus_mode = FOCUS_NONE
		1: # Borderless Windowed
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			resolution_options.disabled = false
			resolution_options.focus_mode = FOCUS_ALL
			resolution_options.item_selected.emit(resolution_options.selected)
		2: # Windowed
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			resolution_options.disabled = false
			resolution_options.focus_mode = FOCUS_ALL
			resolution_options.item_selected.emit(resolution_options.selected)


func _on_resolution_options_item_selected(index):
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	
	match index:
		0: # 1920x1080
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1: # 1600x900
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2: # 1280x720
			DisplayServer.window_set_size(Vector2i(1280, 720))


func _on_master_slider_value_changed(value):
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), value < 0.05)
	master_vol_label.text = str(value * 100)


func _on_music_slider_value_changed(value):
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), value < 0.05)
	music_vol_label.text = str(value * 100)


func _on_sfx_slider_value_changed(value):
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), value < 0.05)
	sfx_vol_label.text = str(value * 100)


func _on_typing_slider_value_changed(value):
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Typing"), linear_to_db(value))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Typing"), value < 0.05)
	typing_vol_label.text = str(value * 100)


func _on_options_menu_item_focus_entered(item):
	if not first_focus:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)
	
	if item == ui_sound_button:
		ui_sound_button.self_modulate = menu_colors.button_focus_color
	
	elif item is HSlider:
		item.add_theme_stylebox_override("slider", slider_focus)
	
	elif get_tree().get_nodes_in_group("delete_buttons").has(item):
		if item.disabled:
			var disabled_focus_color: Color = menu_colors.button_focus_color
			disabled_focus_color.a = 0.7
			item.add_theme_color_override("font_disabled_color", disabled_focus_color)


func _on_h_slider_focus_exited(item):
	if item is HSlider:
		item.add_theme_stylebox_override("slider", slider)


func _on_options_menu_item_mouse_entered(item):
	if not allow_input:
		return
	
	if item.focus_mode != FOCUS_NONE:
		item.grab_focus()


func _on_window_options_item_focused(_index):
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)


func _on_window_options_toggled(button_pressed):
	if button_pressed:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)


func _on_resolution_options_item_focused(_index):
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)


func _on_resolution_options_toggled(button_pressed):
	if button_pressed:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)


func _on_popup_window_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)


func _on_ui_sound_button_toggled(button_pressed):
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("UI"), not button_pressed)
	ui_sound_label.text = "On" if button_pressed else "Off"


func _on_ui_sound_button_focus_exited():
	ui_sound_button.self_modulate = menu_colors.button_reg_color


func _on_delete_button_focus_exited(button: Button):
	if button.disabled:
		var disabled_color: Color = menu_colors.button_reg_color
		disabled_color.a = 0.5
		button.add_theme_color_override("font_disabled_color", disabled_color)


func _on_visibility_changed():
	if visible:
		display_scroll.hide()
		audio_scroll.hide()
		licenses_scroll.hide()
		item_vbox.hide()
		menu_vsep_stylebox.grow_begin = -308
		menu_vsep_stylebox.grow_end = -308
		
		await grow_menu_vsep(1000)
		await reveal_menu_items(0.05)
		display_button.grab_focus()
		#await get_tree().process_frame
		first_focus = false
		allow_input = true
	else:
		first_focus = true
		allow_input = false
		prev_focus = null


func _on_v_scroll_focus_entered():
	#vscroll_grabber_stylebox.bg_color.a = 1.0
	pass


func _on_v_scroll_focus_exited():
	#vscroll_grabber_stylebox.bg_color.a = 0.5
	pass


func _on_data_button_pressed():
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	first_focus = true
	display_scroll.hide()
	audio_scroll.hide()
	licenses_scroll.hide()
	data_scroll.show()
	prev_focus = data_button
	
	if delete_button_1.focus_mode != FOCUS_NONE:
		delete_button_1.grab_focus()
	elif delete_button_2.focus_mode != FOCUS_NONE:
		delete_button_2.grab_focus()
	elif delete_button_3.focus_mode != FOCUS_NONE:
		delete_button_3.grab_focus()
	
	first_focus = false


func _on_delete_button_1_pressed():
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	allow_input = false
	first_focus = true
	delete_button_1.release_focus()
	
	var menu_popup_instance = menu_popup.instantiate()
	add_child(menu_popup_instance)
	
	var confirm: bool = await menu_popup_instance.choice_made
	
	if confirm:
		#DirAccess.remove_absolute("user://savegame_1.save")
		OS.move_to_trash(ProjectSettings.globalize_path("user://savegame_1.save"))
		check_save_files(delete_button_1)
	
	if delete_button_1.focus_mode == FOCUS_ALL:
		delete_button_1.grab_focus()
	elif delete_button_2.focus_mode == FOCUS_ALL:
		delete_button_2.grab_focus()
	elif delete_button_3.focus_mode == FOCUS_ALL:
		delete_button_3.grab_focus()
	else:
		prev_focus.grab_focus()
		prev_focus = null
	
	first_focus = false
	allow_input = true


func _on_delete_button_2_pressed():
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	allow_input = false
	first_focus = true
	delete_button_2.release_focus()
	
	var menu_popup_instance = menu_popup.instantiate()
	add_child(menu_popup_instance)
	
	var confirm: bool = await menu_popup_instance.choice_made
	
	if confirm:
		#DirAccess.remove_absolute("user://savegame_2.save")
		OS.move_to_trash(ProjectSettings.globalize_path("user://savegame_2.save"))
		check_save_files(delete_button_2)
	
	if delete_button_2.focus_mode == FOCUS_ALL:
		delete_button_2.grab_focus()
	elif delete_button_3.focus_mode == FOCUS_ALL:
		delete_button_3.grab_focus()
	elif delete_button_1.focus_mode == FOCUS_ALL:
		delete_button_1.grab_focus()
	else:
		prev_focus.grab_focus()
		prev_focus = null
	
	first_focus = false
	allow_input = true


func _on_delete_button_3_pressed():
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	allow_input = false
	first_focus = true
	delete_button_3.release_focus()
	
	var menu_popup_instance = menu_popup.instantiate()
	add_child(menu_popup_instance)
	
	var confirm: bool = await menu_popup_instance.choice_made
	
	if confirm:
		#DirAccess.remove_absolute("user://savegame_3.save")
		OS.move_to_trash(ProjectSettings.globalize_path("user://savegame_3.save"))
		check_save_files(delete_button_3)
	
	if delete_button_3.focus_mode == FOCUS_ALL:
		delete_button_3.grab_focus()
	elif delete_button_1.focus_mode == FOCUS_ALL:
		delete_button_1.grab_focus()
	elif delete_button_2.focus_mode == FOCUS_ALL:
		delete_button_2.grab_focus()
	else:
		prev_focus.grab_focus()
		prev_focus = null
	
	first_focus = false
	allow_input = true
