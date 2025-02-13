class_name VectorInput
extends Control

signal value_changed(value : Vector2)

var value : Vector2:
	get:
		return Vector2(get_x_value(), get_y_value())
	set(value):
		%XInput.text = str(value.x)
		%YInput.text = str(value.y)

var heading : String:
	get:
		return %HeadingLabel.text
	set(value):
		%HeadingLabel.text = str(value)


func _ready():
	%XInput.text_changed.connect(func(text):
		if text.is_valid_int():
			%XInput.self_modulate = Color.WHITE
			value_changed.emit(value)
		else:
			%XInput.self_modulate = Color.RED
	)
	%YInput.text_changed.connect(func(text):
		if text.is_valid_int():
			%YInput.self_modulate = Color.WHITE
			value_changed.emit(value)
		else:
			%YInput.self_modulate = Color.RED
	)


func get_x_value() -> int:
	if %XInput.text.is_valid_int():
		return %XInput.text.to_int()
	else:
		return 0


func get_y_value() -> int:
	if %YInput.text.is_valid_int():
		return %YInput.text.to_int()
	else:
		return 0
