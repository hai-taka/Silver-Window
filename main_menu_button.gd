extends Button

@export var main_menu: Control = null
@export var use_rich_text_effects: bool = true

var menu_colors: Resource = preload("res://resources/Data/main_menu_colors.tres")

@onready var rich_text_label: RichTextLabel = get_child(0)
@onready var default_text: String = rich_text_label.text


func _ready():
	rich_text_label.visible = use_rich_text_effects
	rich_text_label.add_theme_color_override("default_color", Color.TRANSPARENT)


func _on_new_game_label_mouse_entered():
	if not main_menu.menu_animating and not disabled and main_menu.allow_input:
		grab_focus()


func _on_focus_entered():
	if not main_menu.first_focus:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)
		
	rich_text_label.add_theme_color_override("default_color", menu_colors.button_focus_color)
	rich_text_label.text = "[rain2]" + text + "[/rain2]"


func _on_focus_exited():
	rich_text_label.add_theme_color_override("default_color", Color.TRANSPARENT)
	rich_text_label.text = default_text
