extends CanvasLayer

signal game_unpaused

var menu_popup = preload("res://menu_popup.tscn")
var file_select = preload("res://file_select.tscn")

var allow_input: bool = false
var first_focus: bool = true

@onready var resume_button = %ResumeButton
@onready var save_button = %SaveButton
@onready var options_button = %OptionsButton
@onready var main_menu_button = %MainMenuButton

@onready var options_menu = $OptionsMenu


func _ready():
	hide()
	
	for button in get_tree().get_nodes_in_group("pause_menu_buttons"):
		if button is Button:
			button.mouse_entered.connect(_on_pause_menu_button_mouse_entered.bind(button))
			button.focus_entered.connect(_on_pause_menu_button_focus_entered.bind(button))


func _unhandled_input(event):
	if allow_input:
		if event.is_action_pressed("pause_game"):
			SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
			await %PauseMenu.shrink_menu()
			hide()
			get_tree().paused = false
			game_unpaused.emit()


func _on_pause_menu_button_mouse_entered(button: Button):
	if allow_input:
		button.grab_focus()


func _on_pause_menu_button_focus_entered(_button: Button):
	if not first_focus:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)


func _on_resume_button_pressed():
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
	await %PauseMenu.shrink_menu()
	hide()
	get_tree().paused = false
	game_unpaused.emit()


func _on_save_button_pressed():
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	allow_input = false
	
	var file_select_instance = file_select.instantiate()
	file_select_instance.load_menu = false
	file_select_instance.from_pause = true
	add_child(file_select_instance)
	first_focus = true
	
	await file_select_instance.tree_exited
	allow_input = true


func _on_options_button_pressed():
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	allow_input = false
	options_button.release_focus()
	options_menu.show()
	first_focus = true
	
	await options_menu.hidden
	allow_input = true


func _on_main_menu_button_pressed():
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	allow_input = false
	
	var menu_popup_instance = menu_popup.instantiate()
	menu_popup_instance.line_1_text = "Warning! Unsaved progress will be lost."
	menu_popup_instance.line_2_text = "Really quit?"
	add_child(menu_popup_instance)
	
	var confirm: bool = await menu_popup_instance.choice_made
	
	if confirm:
		get_tree().paused = false
		SoundManager.stop_background_music(false)
		SoundManager.stop_first_pic_appear()
		SoundManager.stop_first_pic_disappear()
		SoundManager.stop_picture_sound()
		SoundManager.stop_typing_sound()
		
		SceneSwitcher.go_to_scene("res://main_menu.tscn")
		#TransitionManager.fade_to_scene("res://main_menu.tscn", 0.5)
	else:
		first_focus = true
		main_menu_button.grab_focus()
		first_focus = false
		allow_input = true


func _on_visibility_changed():
	if visible:
		await %PauseMenu.grow_menu()
	else:
		pass
