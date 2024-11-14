extends Control

signal lines_done

@onready var static_line = $StaticLine
@onready var static_line_2 = $StaticLine2
@onready var static_line_3 = $StaticLine3
@onready var static_line_4 = $StaticLine4
@onready var static_line_5 = $StaticLine5
@onready var static_line_6 = $StaticLine6
@onready var static_line_7 = $StaticLine7
@onready var static_line_8 = $StaticLine8
@onready var static_line_9 = $StaticLine9
@onready var static_line_10 = $StaticLine10
@onready var static_line_11 = $StaticLine11
@onready var static_line_12 = $StaticLine12
@onready var static_line_13 = $StaticLine13
@onready var static_line_14 = $StaticLine14
@onready var static_line_15 = $StaticLine15
@onready var static_line_16 = $StaticLine16
@onready var static_line_17 = $StaticLine17
@onready var static_line_18 = $StaticLine18
@onready var static_line_19 = $StaticLine19
@onready var static_line_20 = $StaticLine20


func _ready():
	pass


func fade_out(line: VSeparator, duration: float = 0.5) -> void:
	var tween = create_tween()
	tween.tween_property(line, "self_modulate:a", 0.0, duration).from(1.0)
	await tween.finished
	#line.hide()
	tween.kill()


func _on_static_line_visibility_changed():
	if static_line != null and static_line.is_visible_in_tree():
		fade_out(static_line)


func _on_static_line_2_visibility_changed():
	if static_line_2 != null and static_line_2.is_visible_in_tree():
		fade_out(static_line_2)


func _on_static_line_3_visibility_changed():
	if static_line_3 != null and static_line_3.is_visible_in_tree():
		fade_out(static_line_3)


func _on_static_line_4_visibility_changed():
	if static_line_4 != null and static_line_4.is_visible_in_tree():
		fade_out(static_line_4)


func _on_static_line_5_visibility_changed():
	if static_line_5 != null and static_line_5.is_visible_in_tree():
		fade_out(static_line_5)


func _on_static_line_6_visibility_changed():
	if static_line_6 != null and static_line_6.is_visible_in_tree():
		fade_out(static_line_6)


func _on_static_line_7_visibility_changed():
	if static_line_7 != null and static_line_7.is_visible_in_tree():
		fade_out(static_line_7)


func _on_static_line_8_visibility_changed():
	if static_line_8 != null and static_line_8.is_visible_in_tree():
		fade_out(static_line_8)


func _on_static_line_9_visibility_changed():
	if static_line_9 != null and static_line_9.is_visible_in_tree():
		fade_out(static_line_9)


func _on_static_line_10_visibility_changed():
	if static_line_10 != null and static_line_10.is_visible_in_tree():
		fade_out(static_line_10)


func _on_static_line_11_visibility_changed():
	if static_line_11 != null and static_line_11.is_visible_in_tree():
		fade_out(static_line_11)


func _on_static_line_12_visibility_changed():
	if static_line_12 != null and static_line_12.is_visible_in_tree():
		fade_out(static_line_12)


func _on_static_line_13_visibility_changed():
	if static_line_13 != null and static_line_13.is_visible_in_tree():
		fade_out(static_line_13)


func _on_static_line_14_visibility_changed():
	if static_line_14 != null and static_line_14.is_visible_in_tree():
		fade_out(static_line_14)


func _on_static_line_15_visibility_changed():
	if static_line_15 != null and static_line_15.is_visible_in_tree():
		fade_out(static_line_15)


func _on_static_line_16_visibility_changed():
	if static_line_16 != null and static_line_16.is_visible_in_tree():
		fade_out(static_line_16)


func _on_static_line_17_visibility_changed():
	if static_line_17 != null and static_line_17.is_visible_in_tree():
		fade_out(static_line_17)


func _on_static_line_18_visibility_changed():
	if static_line_18 != null and static_line_18.is_visible_in_tree():
		fade_out(static_line_18)


func _on_static_line_19_visibility_changed():
	if static_line_19 != null and static_line_19.is_visible_in_tree():
		fade_out(static_line_19)


func _on_static_line_20_visibility_changed():
	if static_line_20 != null and static_line_20.is_visible_in_tree():
		await fade_out(static_line_20)
		lines_done.emit()
		
		for child in get_children():
			child.hide()
			child.self_modulate.a = 1.0
