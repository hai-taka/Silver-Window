extends Control

signal screen_obscured
signal transition_finished

@export var h_leading_line_stylebox: StyleBoxLine = null
@export var h_static_line_stylebox: StyleBoxLine = null
@export var v_leading_line_stylebox: StyleBoxLine = null
@export var v_static_line_stylebox: StyleBoxLine = null

@onready var stylebox_array: Array = [
	h_leading_line_stylebox,
	h_static_line_stylebox,
	v_leading_line_stylebox,
	v_static_line_stylebox,
]

@onready var fade_control = %Fade
@onready var fade_rect = %FadeRect
@onready var curtain_wipe_control = %CurtainWipe
@onready var left_static_lines = %LeftStaticLines


func _ready():
	hide()


func no_transition(new_script: String) -> void:
	GlobalData.transitioning = true
	GlobalData.previous_transition = GlobalData.NONE
	
	if not GlobalData.running_from_editor:
		DialogueManager.change_script(new_script)
		GlobalData.first_script = false
		SceneSwitcher.go_to_scene("res://main1.tscn")
	else:
		SoundManager.stop_background_music(false)
		SceneSwitcher.go_to_preserved()
	
	transition_finished.emit()
	GlobalData.transitioning = false


func curtain_wipe(new_script: String, line_color: Color) -> void:
	if SoundManager.current_bg_player.playing:
		await SoundManager.stop_background_music(true, 1.0)
	
	SoundManager.play_curtain_sound()
	
	for stylebox in stylebox_array:
		stylebox.color = line_color
	
	show()
	GlobalData.transitioning = true
	GlobalData.previous_transition = GlobalData.CURTAIN_WIPE
	await curtain_wipe_control.close_horizontal()
	screen_obscured.emit()
	
	if not GlobalData.running_from_editor:
		DialogueManager.change_script(new_script)
		GlobalData.first_script = false
		SceneSwitcher.go_to_scene("res://main1.tscn")
	else:
		SceneSwitcher.go_to_preserved()
	
	await curtain_wipe_control.open_vertical()
	hide()
	transition_finished.emit()
	GlobalData.transitioning = false


func fade(new_script: String, duration: float = 2.0, fade_color: Color = Color("000000")) -> void:
	if SoundManager.current_bg_player.playing:
		SoundManager.stop_background_music(true, duration)
	
	fade_rect.color = fade_color
	fade_rect.color.a = 0.0
	show()
	GlobalData.transitioning = true
	GlobalData.previous_transition = GlobalData.FADE
	await fade_control.fade_out(duration)
	screen_obscured.emit()
	
	if not GlobalData.running_from_editor:
		DialogueManager.change_script(new_script)
		GlobalData.first_script = false
		SceneSwitcher.go_to_scene("res://main1.tscn")
	else:
		SceneSwitcher.go_to_preserved()
	
	# Wait while screen is black
	await get_tree().create_timer(0.5).timeout
	
	await fade_control.fade_in(duration)
	hide()
	transition_finished.emit()
	GlobalData.transitioning = false


func fade_to_scene(new_scene: String, duration: float = 2.0, fade_color: Color = Color("000000")) -> void:
	SoundManager.stop_background_music(true, duration)
	fade_rect.color = fade_color
	fade_rect.color.a = 0.0
	show()
	GlobalData.transitioning = true
	GlobalData.previous_transition = GlobalData.FADE
	await fade_control.fade_out(duration)
	screen_obscured.emit()
	
	if not GlobalData.running_from_editor:
		SceneSwitcher.go_to_scene(new_scene)
	else:
		SoundManager.stop_background_music(false)
		SceneSwitcher.go_to_preserved()
	
	# Wait while screen is black
	await get_tree().create_timer(1.0).timeout
	
	await fade_control.fade_in(duration)
	hide()
	transition_finished.emit()
	GlobalData.transitioning = false


func _on_test_button_pressed():
	await curtain_wipe_control.close_horizontal()
	await curtain_wipe_control.open_vertical()


func _on_fade_button_pressed():
	show()
	await fade_control.fade_out()
	await fade_control.fade_in()
