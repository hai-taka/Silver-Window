extends Button

@export var use_rich_text_effects: bool = true
@export var hover_color: Color = Color("ffffff")
@export var selected_color: Color = Color("e51717")

var default_color: Color = Color("c0c0c000")

@onready var default_focus_color: Color = get_theme_color("font_focus_color")
@onready var default_hover_color: Color = get_theme_color("font_hover_color")
@onready var rich_text_label: RichTextLabel = get_child(0)
#@onready var default_text: String = rich_text_label.text


func _ready():
	rich_text_label.text = text
	rich_text_label.visible = use_rich_text_effects
	rich_text_label.add_theme_color_override("default_color", default_color)


func _on_rich_text_label_mouse_entered():
	grab_focus()


func _on_focus_entered():
	add_theme_color_override("font_focus_color", Color.TRANSPARENT)
	add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	rich_text_label.add_theme_color_override("default_color", hover_color)
	if use_rich_text_effects:
		rich_text_label.text = "[shake rate=30.0 level=10 connected=0]" + text + "[/shake]"


func _on_focus_exited():
	add_theme_color_override("font_focus_color", default_focus_color)
	add_theme_color_override("font_hover_color", default_hover_color)
	rich_text_label.add_theme_color_override("default_color", default_color)
	if use_rich_text_effects:
		rich_text_label.text = text
