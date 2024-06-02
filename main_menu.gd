extends Control

signal flash_finished
signal grow_finished
signal items_revealed
signal faded_in
signal any_button_pressed

@export var menu_colors: Resource

var chapter_select = preload("res://chapter_select.tscn")
var file_select = preload("res://file_select.tscn")

var menu_animating: bool = true:
	set(value):
		menu_animating = value
		if value == false and menu_item_hbox != null:
			for button in menu_item_hbox.get_children():
				if button is Button:
					button.disabled = false
					button.add_theme_color_override("font_disabled_color", bg_color)


var skip_animation: bool = false
var active_tweens: Array[Tween] = []
var allow_input: bool = false
var first_focus: bool = true

var pulse_tween: Tween

@onready var bg_color: Color = menu_colors.bg_color
@onready var main_panel = %MainPanel
@onready var main_panel_stylebox: StyleBoxFlat = main_panel.get_theme_stylebox("panel")
@onready var main_panel_default_color: Color = menu_colors.border_color
@onready var panel_inner_margin = %PanelInnerMargin

@onready var game_title = %GameTitle
@onready var game_logo = %GameLogo
@onready var press_any_control = %PressAnyControl
@onready var press_any_label = %PressAnyLabel

@onready var menu_item_margin = %MenuItemMargin
@onready var menu_item_panel = %MenuItemPanel
@onready var menu_item_hbox = %MenuItemHBox
@onready var new_game_button = %NewGameButton
@onready var initial_button_font_color: Color = menu_colors.button_reg_color
@onready var initial_button_hover_color: Color = menu_colors.button_focus_color
@onready var load_button = %LoadButton
@onready var opt_button = %OptButton
@onready var quit_button = %QuitButton
@onready var options_menu = $OptionsMenu
@onready var wipe_panel = %WipePanel
@onready var wipe_margin = %WipeMargin


func _ready():
	load_options()
	
	$Background.color = bg_color
	wipe_panel.get_theme_stylebox("panel").bg_color = bg_color
	menu_item_panel.get_theme_stylebox("panel").border_color = main_panel_default_color
	wipe_panel.get_theme_stylebox("panel").border_color = main_panel_default_color
	theme.set_color("font_color", "Button", menu_colors.button_reg_color)
	theme.set_color("font_focus_color", "Button", menu_colors.button_focus_color)
	theme.set_color("font_hover_color", "Button", menu_colors.button_focus_color)
	theme.set_color("font_hover_pressed_color", "Button", menu_colors.button_focus_color)
	theme.set_color("font_pressed_color", "Button", menu_colors.button_focus_color)
	theme.set_color("icon_normal_color", "Button", menu_colors.button_reg_color)
	theme.set_color("icon_focus_color", "Button", menu_colors.button_focus_color)
	theme.set_color("icon_hover_color", "Button", menu_colors.button_focus_color)
	theme.set_color("icon_hover_pressed_color", "Button", menu_colors.button_focus_color)
	theme.set_color("icon_pressed_color", "Button", menu_colors.button_focus_color)
	theme.set_color("font_color", "Label", menu_colors.label_color)
	
	panel_inner_margin.hide()
	main_panel_stylebox.border_color = bg_color
	game_title.self_modulate.a = 0.0
	game_logo.self_modulate.a = 0.0
	menu_item_panel.custom_minimum_size.y = menu_item_panel.size.y
	menu_item_hbox.hide()
	
	if GlobalData.transitioning:
		await TransitionManager.transition_finished
	else:
		await get_tree().create_timer(1.0).timeout
	
	SoundManager.play_main_menu_music()
	
	flash_panel()
	await flash_finished
	await get_tree().create_timer(0.25).timeout
	allow_input = true
	
	panel_inner_margin.show()
	set_up_menu_items()
	
	fade_in(game_logo)
	if not skip_animation:
		await faded_in
	
	fade_in(game_title)
	if not skip_animation:
		await faded_in
	
	if not skip_animation:
		press_any_control.show()
		press_any_control.grab_focus()
		await any_button_pressed
	
	grow_menu_line(2000)
	if not skip_animation:
		await grow_finished
	
	reveal_menu_items(0.05)
	if not skip_animation:
		await items_revealed
	#menu_item_hbox.show()
	
	menu_animating = false
	new_game_button.grab_focus()
	first_focus = false


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
	
	var master_bus = AudioServer.get_bus_index("Master")
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	var typing_bus = AudioServer.get_bus_index("Typing")
	var ui_bus = AudioServer.get_bus_index("UI")
	
	match window_mode:
		0: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		1: # Borderless Windowed
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		2: # Windowed
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	match windowed_res:
		0: # 1920x1080
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1: # 1600x900
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2: # 1280x720
			DisplayServer.window_set_size(Vector2i(1280, 720))
	
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
	AudioServer.set_bus_mute(master_bus, master_volume < 0.05)
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	AudioServer.set_bus_mute(music_bus, music_volume < 0.05)
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))
	AudioServer.set_bus_mute(sfx_bus, sfx_volume < 0.05)
	AudioServer.set_bus_volume_db(typing_bus, linear_to_db(typing_volume))
	AudioServer.set_bus_mute(typing_bus, typing_volume < 0.05)
	AudioServer.set_bus_mute(ui_bus, not ui_sound)


func wipe(frames: int = 30) -> void:
	allow_input = false
	wipe_margin.show()
	var tween = create_tween()
	var duration: float = frames / 60.0
	
	tween.tween_property(wipe_margin, "theme_override_constants/margin_right", 0, duration)
	
	await tween.finished
	tween.kill()


func flash_panel(flashes: int = 2, delay: float = 0.05) -> void:
	main_panel_stylebox.border_color = bg_color
	
	for i in flashes:
		main_panel_stylebox.border_color = main_panel_default_color
		await get_tree().create_timer(delay).timeout
		main_panel_stylebox.border_color = bg_color
		await get_tree().create_timer(delay).timeout
	
	main_panel_stylebox.border_color = main_panel_default_color
	flash_finished.emit()


func set_up_menu_items():
	menu_item_hbox.hide()
	menu_item_margin.add_theme_constant_override("margin_left", 628)
	menu_item_margin.add_theme_constant_override("margin_right", 628)


func grow_menu_line(speed: int = 3000) -> void:
	if skip_animation:
		return
	
	var tween = create_tween()
	active_tweens.append(tween)
	var duration = 478 / float(speed)
	tween.set_parallel()
	tween.tween_property(menu_item_margin, "theme_override_constants/margin_left", 150, duration)
	tween.tween_property(menu_item_margin, "theme_override_constants/margin_right", 150, duration)
	await tween.finished
	tween.kill()
	active_tweens.erase(tween)
	grow_finished.emit()


func reveal_menu_items(delay: float = 0.05) -> void:
	if skip_animation:
		return
	
	menu_item_hbox.show()
	menu_item_hbox.custom_minimum_size = menu_item_hbox.size
	
	var initial_color: Color = new_game_button.get_theme_color("font_color")
	
	for button in menu_item_hbox.get_children():
		if button is Button:
			button.add_theme_color_override("font_disabled_color", bg_color)
			button.disabled = true
	
	for button in menu_item_hbox.get_children():
		if button is Button:
			if skip_animation:
				return
			
			button.add_theme_color_override("font_disabled_color", initial_color)
			await get_tree().create_timer(delay).timeout
	
	items_revealed.emit()


func fade_in(node: Control, duration: float = 2.0) -> void:
	if skip_animation:
		return
	
	var tween = create_tween()
	active_tweens.append(tween)
	tween.tween_property(node, "self_modulate:a", 1.0, duration)
	await tween.finished
	tween.kill()
	active_tweens.erase(tween)
	faded_in.emit()


func _unhandled_input(event):
	if not allow_input:
		return
	
	if (
			menu_animating and event.is_action_pressed("advance_text") 
			or menu_animating and event.is_action_pressed("ui_accept")
	):
		for tween in active_tweens:
			tween.kill()
		
		skip_animation = true
		
		game_logo.self_modulate.a = 1.0
		game_title.self_modulate.a = 1.0
		faded_in.emit()
		
		menu_item_margin.add_theme_constant_override("margin_left", 150)
		menu_item_margin.add_theme_constant_override("margin_right", 150)
		grow_finished.emit()
		
		menu_item_hbox.show()
		
		for button in menu_item_hbox.get_children():
			button.add_theme_color_override("font_color", initial_button_font_color)
		
		items_revealed.emit()
		
		menu_animating = false
		new_game_button.grab_focus()


func _on_new_game_button_pressed():
	if not menu_animating and allow_input:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.SPECIAL)
		allow_input = false
		for button in menu_item_hbox.get_children():
			if button is Button:
				if button != new_game_button:
					button.disabled = true
					button.focus_mode = Control.FOCUS_NONE
					button.get_child(0).hide()
				else:
					button.disabled = true
					button.get_child(0).text = (
							"[shake rate=30.0 level=20 connected=0]New Game[/shake]"
					)
					button.get_child(0).add_theme_color_override(
							"default_color", 
							menu_colors.shake_color
					)
			else:
				pass
		
		GlobalData.current_chapter = 0
		GlobalData.furthest_chapter = 0
		GlobalData.game_completed = false
		GlobalData.reset_play_time()
		GlobalData.unix_time_at_load = Time.get_unix_time_from_system()
		GlobalData.initialize()
		DialogueManager.change_script(GlobalData.first_script_list[0])
		TransitionManager.fade_to_scene("res://title_card.tscn")
		SoundManager.stop_main_menu_music()


func _on_load_button_pressed():
	if not menu_animating and allow_input:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
		allow_input = false
		load_button.release_focus()
		await wipe()
		
		var file_select_instance = file_select.instantiate()
		file_select_instance.load_menu = true
		add_child(file_select_instance)
		
		wipe_margin.hide()
		wipe_margin.add_theme_constant_override("margin_right", 1270)


func _on_opt_button_pressed():
	if not menu_animating and allow_input:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
		allow_input = false
		opt_button.release_focus()
		#await wipe()
		
		options_menu.show()
		
		#wipe_margin.hide()
		#wipe_margin.add_theme_constant_override("margin_right", 1270)


func _on_quit_button_pressed():
	if not menu_animating and allow_input:
		get_tree().quit()


func _on_press_any_control_gui_input(event: InputEvent):
	if (
			event.is_action_pressed("ui_accept")
			or event.is_action_pressed("ui_cancel")
			or event.is_action("advance_text")
	):
		press_any_control.accept_event()
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
		press_any_control.hide()
		any_button_pressed.emit()


func _on_press_any_control_visibility_changed():
	if press_any_control.visible:
		press_any_label.self_modulate.a = 0.0
		var dur: float = 1.0
		
		pulse_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
		pulse_tween.tween_property(press_any_label, "self_modulate:a", 1.5, dur)
		pulse_tween.tween_property(press_any_label, "self_modulate:a", 0.0, dur).set_delay(0.2)
	else:
		if pulse_tween != null:
			pulse_tween.kill()
			pulse_tween = null
