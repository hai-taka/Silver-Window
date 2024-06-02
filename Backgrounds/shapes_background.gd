extends CanvasLayer

enum BGTypeEnum {
	SOLID,
	GRADIENT,
	TEXTURE,
}

enum AnimTypeEnum {
	NONE,
	SQUARE_1,
	MOVING_SQUARES,
	CLOCKS,
	MOVING_LINES,
	RIPPLES,
	VIEWFINDER,
}

@export var bg_type: BGTypeEnum
@export var anim_type: AnimTypeEnum

var square_shape = preload("res://Backgrounds/shapes/square_shape.tscn")
var moving_squares = preload("res://Backgrounds/shapes/moving_squares.tscn")
var clocks = preload("res://Backgrounds/shapes/clocks.tscn")
var moving_lines = preload("res://Backgrounds/shapes/moving_line.tscn")
var ripples = preload("res://Backgrounds/shapes/ripples.tscn")
var viewfinder = preload("res://Backgrounds/shapes/viewfinder.tscn")

var solid_color = Color("000000")
var grad_top_color = Color("000000")
var grad_top_offset = 21
var grad_bott_color = Color("ffffff")
var grad_bott_offset = 91
var texture_path = "res://assets/godot_icon_500.jpg"
var anim_color = Color("ffffff")
var line_color_1 = Color("ffffff")
var line_color_2 = Color("ffffff")
var line_color_3 = Color("ffffff")
var line_color_4 = Color("ffffff")
var ripple_delay = 6.0

@onready var solid_bg = $SolidBG
@onready var gradient_bg = $GradientBG
@onready var texture_bg = $TextureBG


func _ready():
	match bg_type:
		BGTypeEnum.SOLID:
			solid_bg.color = solid_color
			solid_bg.show()
		BGTypeEnum.GRADIENT:
			gradient_bg.texture.gradient.set_offset(0, grad_top_offset / 100.0)
			gradient_bg.texture.gradient.set_offset(1, grad_bott_offset / 100.0)
			gradient_bg.texture.gradient.set_color(0, grad_top_color)
			gradient_bg.texture.gradient.set_color(1, grad_bott_color)
			gradient_bg.show()
		BGTypeEnum.TEXTURE:
			texture_bg.texture = load(texture_path)
			texture_bg.show()
	
	match anim_type:
		AnimTypeEnum.NONE:
			pass
		AnimTypeEnum.SQUARE_1:
			var center_cont = CenterContainer.new()
			var grid = GridContainer.new()
			center_cont.set_anchors_preset(Control.PRESET_FULL_RECT)
			grid.columns = 15
			grid.add_theme_constant_override("h_separation", 50)
			grid.add_theme_constant_override("v_separation", 50)
			add_child(center_cont)
			center_cont.add_child(grid)
			
			for i in 120:
				var shape = square_shape.instantiate()
				shape.color = anim_color
				grid.add_child(shape)
		AnimTypeEnum.MOVING_SQUARES:
			var moving = moving_squares.instantiate()
			moving.color = anim_color
			add_child(moving)
		AnimTypeEnum.CLOCKS:
			var center_cont = CenterContainer.new()
			var grid = GridContainer.new()
			center_cont.set_anchors_preset(Control.PRESET_FULL_RECT)
			grid.columns = 5
			grid.add_theme_constant_override("h_separation", 100)
			grid.add_theme_constant_override("v_separation", 100)
			add_child(center_cont)
			center_cont.add_child(grid)
			
			for i in 15:
				var rand_clock = clocks.instantiate()
				rand_clock.color = anim_color
				grid.add_child(rand_clock)
		AnimTypeEnum.MOVING_LINES:
			for i in 20:
				var line = moving_lines.instantiate()
				line.color_1 = line_color_1
				line.color_2 = line_color_2
				line.color_3 = line_color_3
				line.color_4 = line_color_4
				add_child(line)
				await get_tree().create_timer(3.0).timeout
		AnimTypeEnum.RIPPLES:
			var ripples_instance = ripples.instantiate()
			ripples_instance.color = anim_color
			ripples_instance.delay = ripple_delay
			add_child(ripples_instance)
		AnimTypeEnum.VIEWFINDER:
			var viewfinder_instance = viewfinder.instantiate()
			viewfinder_instance.color = anim_color
			add_child(viewfinder_instance)
