class_name Field
extends Control

signal field_changed (field_name : String, field_value : String)

var field_name : String:
	get():
		return %FieldName.text
	set(value):
		%FieldName.text = value

var field_value : String:
	get():
		return %FieldValue.text
	set(value):
		%FieldValue.text = value

func _ready() -> void:
	%FieldValue.text_submitted.connect(func(val : String): field_changed.emit(field_name, val))
	%FieldValue.focus_exited.connect(func(): field_changed.emit(field_name, field_value))
