class_name ChoicePicker
extends Control

signal value_chosen(value)
var popup_values : Dictionary

var text : String:
	get:
		return %Label.text
	set(value):
		%Label.text = value


func _ready() -> void:
	%Choices.index_pressed.connect(_on_index_pressed)
	%PickOptionButton.pressed.connect(func(): %Choices.popup_on_parent(get_rect()))


func _on_index_pressed(index):
	value_chosen.emit(popup_values.values()[index])
	%PickOptionButton.text = str(popup_values.keys()[index])


func set_values(current_value, values : Dictionary):
	popup_values = values
	for key in popup_values.keys():
		%Choices.add_item(str(key))
	%PickOptionButton.text = str(current_value)
