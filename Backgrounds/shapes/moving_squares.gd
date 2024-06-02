extends Control

var point_1 = Vector2(625, 205)
var point_2 = Vector2(625, 625)
var point_3 = Vector2(1045, 625)
var point_4 = Vector2(1045, 205)

var points_array = [
	point_1,
	point_2,
	point_3,
	point_4,
]

var outer_array = [
	Vector2(520, 100),
	Vector2(1330, 100),
	Vector2(1330, 910),
	Vector2(520, 910),
]

var color = Color.WHITE

@onready var square_1 = $Square1
@onready var square_2 = $Square2
@onready var square_3 = $Square3
@onready var square_4 = $Square4
@onready var square_5 = $Square5
@onready var square_6 = $Square6
@onready var square_7 = $Square7
@onready var square_8 = $Square8

@onready var panel_1 = $Square1/Panel1
@onready var panel_2 = $Square2/Panel2
@onready var panel_3 = $Square3/Panel3
@onready var panel_4 = $Square4/Panel4
@onready var panel_5 = $Square5/Panel5
@onready var panel_6 = $Square6/Panel6
@onready var panel_7 = $Square7/Panel7
@onready var panel_8 = $Square8/Panel8


func _ready():
	for panel in get_tree().get_nodes_in_group("panels"):
		#panel.self_modulate.a = 0.5
		panel.get_theme_stylebox("panel").border_color = color
	
	var ready_tween = create_tween().set_loops().set_parallel()
	ready_tween.tween_callback(animate.bind(square_1, 30)).set_delay(1.25)
	ready_tween.tween_callback(animate.bind(square_2, 30)).set_delay(1.25)
	ready_tween.tween_callback(animate.bind(square_3, 30)).set_delay(1.25)
	ready_tween.tween_callback(animate.bind(square_4, 30)).set_delay(1.25)
	ready_tween.tween_callback(animate.bind(square_5, 30, false)).set_delay(1.25)
	ready_tween.tween_callback(animate.bind(square_6, 30, false)).set_delay(1.25)
	ready_tween.tween_callback(animate.bind(square_7, 30, false)).set_delay(1.25)
	ready_tween.tween_callback(animate.bind(square_8, 30, false)).set_delay(1.25)


func animate(square: MarginContainer, frames: int = 30, inner: bool = true) -> void:
	var tween = create_tween().set_parallel()
	var index: int = (
			points_array.find(square.position) if inner
			else outer_array.find(square.position)
	)
	
	if index == 3:
		index = -1
	
	var destination: Vector2 = (
			points_array[index + 1] if inner
			else outer_array[index + 1]
	)
	
	var marg: int = 25 if inner else 10
	
	var tween_time = frames / 60.0
	var pulse_time = 1 / 8.0
	var delay = 0.25
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(
			square, "position", destination, tween_time
			).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.chain().tween_property(square, "theme_override_constants/margin_left", 0, pulse_time).set_delay(delay)
	tween.tween_property(square, "theme_override_constants/margin_top", 0, pulse_time).set_delay(delay)
	tween.tween_property(square, "theme_override_constants/margin_right", 0, pulse_time).set_delay(delay)
	tween.tween_property(square, "theme_override_constants/margin_bottom", 0, pulse_time).set_delay(delay)
	
	tween.chain().tween_property(square, "theme_override_constants/margin_left", marg, pulse_time).as_relative()
	tween.tween_property(square, "theme_override_constants/margin_top", marg, pulse_time)
	tween.tween_property(square, "theme_override_constants/margin_right", marg, pulse_time)
	tween.tween_property(square, "theme_override_constants/margin_bottom", marg, pulse_time)
	
	await tween.finished
	tween.kill()
