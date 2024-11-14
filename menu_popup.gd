extends Control

signal choice_made(yes: bool)
signal expanded

@export var line_1_text: String = ""
@export var line_2_text: String = ""

var menu_colors: Resource = preload("res://resources/Data/main_menu_colors.tres")
var first_focus: bool = true
var expand_on_ready: bool = false
var size_after_expand: Vector2i = Vector2i(0, 0)
var message_size: int = 0
var button_size: int = 0

@onready var outer_margin = %OuterMargin
@onready var popup_panel = %PopupPanel
@onready var inner_margin = %InnerMargin
@onready var message_label = %MessageLabel
@onready var button_h_box = %ButtonHBox
@onready var yes_button = %YesButton
@onready var no_button = %NoButton

@onready var stylebox: StyleBoxFlat = popup_panel.get_theme_stylebox("panel").duplicate()

func _ready():
	stylebox.draw_center = true
	stylebox.bg_color = menu_colors.bg_color
	popup_panel.add_theme_stylebox_override("panel", stylebox)
	
	for button in button_h_box.get_children():
		if button is Button:
			button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
			button.focus_entered.connect(_on_button_focus_entered)
	
	if message_size != 0:
		message_label.add_theme_font_size_override("font_size", message_size)
	
	if button_size != 0:
		yes_button.add_theme_font_size_override("font_size", button_size)
		no_button.add_theme_font_size_override("font_size", button_size)
	
	if line_1_text != "":
		if line_2_text == "":
			line_2_text = " "
		message_label.text = line_1_text + "\n" + line_2_text
	
	if expand_on_ready:
		#await get_tree().create_timer(1.0).timeout
		expand(size_after_expand)
		await expanded
	
	yes_button.grab_focus()
	first_focus = false


func expand(final_size: Vector2i = Vector2i(0, 0), frames: int = 13) -> void:
	if final_size.x == 0:
		outer_margin.custom_minimum_size.x = outer_margin.size.x
	else:
		outer_margin.custom_minimum_size.x = final_size.x
	
	if final_size.y == 0:
		outer_margin.custom_minimum_size.y = outer_margin.size.y
	else:
		outer_margin.custom_minimum_size.y = final_size.y
	
	var dur: float = frames / 60.0
	var initial_size: Vector2 = popup_panel.size
	
	inner_margin.hide()
	outer_margin.add_theme_constant_override("margin_left", initial_size.x / 2.0)
	outer_margin.add_theme_constant_override("margin_right", initial_size.x / 2.0)
	outer_margin.add_theme_constant_override("margin_top", initial_size.y / 2.0)
	outer_margin.add_theme_constant_override("margin_bottom", initial_size.y / 2.0)
	
	var tween = create_tween().set_parallel()
	tween.tween_property(outer_margin, "theme_override_constants/margin_left", 0, dur)
	tween.tween_property(outer_margin, "theme_override_constants/margin_right", 0, dur)
	tween.tween_property(outer_margin, "theme_override_constants/margin_top", 0, dur)
	tween.tween_property(outer_margin, "theme_override_constants/margin_bottom", 0, dur)
	
	await tween.finished
	tween.kill()
	
	inner_margin.show()
	expanded.emit()


func _on_button_mouse_entered(button: Button):
	button.grab_focus()


func _on_button_focus_entered():
	if not first_focus:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)


func _on_yes_button_pressed():
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	choice_made.emit(true)
	
	if get_parent() == get_tree().root:
		get_tree().quit()
	else:
		queue_free()


func _on_no_button_pressed():
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
	choice_made.emit(false)
	
	if get_parent() == get_tree().root:
		get_tree().quit()
	else:
		queue_free()
