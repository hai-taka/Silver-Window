extends MarginContainer

@export var pause_screen: CanvasLayer = null
@export var menu_panel_stylebox: StyleBoxTexture = null

var panel_full_size
var marg_top
var marg_bott
var marg_left
var marg_right

@onready var inner_marg = $PanelContainer/MarginContainer
@onready var menu_panel = $PanelContainer
@onready var resume_button = %ResumeButton


# Called when the node enters the scene tree for the first time.
func _ready():
	custom_minimum_size = size
	panel_full_size = menu_panel.size
	#print(panel_full_size)
	marg_top = panel_full_size.y / 2.0
	marg_bott = panel_full_size.y - marg_top
	marg_left = panel_full_size.x / 2.0
	marg_right = panel_full_size.x - marg_left
	
	reset_menu()


func reset_menu():
	inner_marg.hide()
	menu_panel_stylebox.draw_center = false
	add_theme_constant_override("margin_top", marg_top)
	add_theme_constant_override("margin_bottom", marg_bott)
	add_theme_constant_override("margin_left", marg_left)
	add_theme_constant_override("margin_right", marg_right)


func grow_menu(frames:int = 10):
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	pause_screen.allow_input = false
	
	var tween = create_tween()
	var tween_time = frames / 60.0
	
	reset_menu()
	
	tween.set_parallel()
	tween.tween_property(self, "theme_override_constants/margin_left", 0, tween_time * 0.75).from(
			marg_left)
	tween.tween_property(self, "theme_override_constants/margin_right", 0, tween_time * 0.75).from(
			marg_right)
	
	tween.chain().tween_property(self, "theme_override_constants/margin_top", 0, tween_time).from(
			marg_top)
	tween.tween_property(self, "theme_override_constants/margin_bottom", 0, tween_time).from(
			marg_bott)
	await tween.finished
	tween.kill()
	
	menu_panel_stylebox.draw_center = true
	inner_marg.show()
	resume_button.grab_focus()
	pause_screen.first_focus = false
	pause_screen.allow_input = true


func shrink_menu(frames:int = 10):
	pause_screen.allow_input = false
	pause_screen.first_focus = true
	
	var tween = create_tween()
	var tween_time = frames / 60.0
	
	inner_marg.hide()
	menu_panel_stylebox.draw_center = false
	
	tween.set_parallel()
	tween.tween_property(self, "theme_override_constants/margin_top", marg_top, tween_time).from(
			0)
	tween.tween_property(self, "theme_override_constants/margin_bottom", marg_bott, tween_time).from(
			0)
	
	tween.chain().tween_property(self, "theme_override_constants/margin_left", marg_left, tween_time * 0.75).from(
			0)
	tween.tween_property(self, "theme_override_constants/margin_right", marg_right, tween_time * 0.75).from(
			0)
	
	#tween.chain().tween_property(self, "theme_override_constants/margin_left", 0, 0)
	#tween.tween_property(self, "theme_override_constants/margin_right", 0, 0)
	#tween.chain().tween_interval(0.2)
	
	await tween.finished
	tween.kill()
	
	#pause_screen.allow_input = true
