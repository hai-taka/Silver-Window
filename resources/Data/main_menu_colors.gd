extends Resource

@export var bg_color: Color = Color("000000")
@export var border_color: Color = Color("c0c0c0")
@export var label_color: Color = Color("ffffff")
@export var button_reg_color: Color = Color("808080")
@export var button_focus_color: Color = Color("ffffff")
@export var shake_color: Color = Color("e51717")
@export var file_select_border_color: Color = Color("e51717")

func _init(
		p_bg_color: Color = Color("000000"), 
		p_border_color: Color = Color("c0c0c0"), 
		p_label_color: Color = Color("ffffff"), 
		p_shake_color: Color = Color("e51717"), 
		p_button_reg_color: Color = Color("808080"), 
		p_button_focus_color: Color = Color("ffffff"),
		p_file_select_border_color: Color = Color("e51717")
):
	bg_color = p_bg_color
	border_color = p_border_color
	label_color = p_label_color
	shake_color = p_shake_color
	button_reg_color = p_button_reg_color
	button_focus_color = p_button_focus_color
	file_select_border_color = p_file_select_border_color
