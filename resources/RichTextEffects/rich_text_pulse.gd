@tool
extends RichTextEffect
class_name RichTextPulse

# Syntax: [pulse color=#ffffff33 freq=1.0 ease=-2.0 height=0][/pulse]

# Define the tag name.
var bbcode = "pulse"

func _process_custom_fx(char_fx):
	# Get parameters, or use the provided default value if missing.
	var color = Color(char_fx.env.get("color", Color(1, 1, 1, 0.2)))
	var freq = char_fx.env.get("freq", 1.0)
	var param_ease = char_fx.env.get("ease", -2.0)
	var height = char_fx.env.get("height", 0)

	var sined_time = (ease(pingpong(char_fx.elapsed_time, 1.0 / freq) * freq, param_ease))
	var y_off = sined_time * height
	char_fx.color = char_fx.color.lerp(char_fx.color * color, sined_time)
	char_fx.offset = Vector2(0, -1) * y_off
	return true
