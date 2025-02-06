class_name MessageBubble
extends Control

@export var non_player_color : Color
@export var player_color : Color
var maximum_size = 300
var is_player_message = false

func _ready():
	%Background.self_modulate = non_player_color
	%MessageLayoutController.resized.connect(_update_layout)
	_update_layout()


func set_text(text : String):
	%MessageLayoutController.size.x = 0
	%Text.text = text
	_update_layout()


func set_player_message(is_player_message : bool):
	self.is_player_message = is_player_message
	if is_player_message:
		%Background.self_modulate = player_color
	else:
		%Background.self_modulate = non_player_color
	_update_layout()


func set_join(joined_at_top : bool, joined_at_bottom : bool):
	var styling : StyleBoxFlat = StyleBoxFlat.new() 
	styling.bg_color = Color.WHITE
	styling.set_corner_radius_all(15)
	if joined_at_bottom:
		if is_player_message:
			styling.corner_radius_bottom_right = 0
		else:
			styling.corner_radius_bottom_left = 0
	if joined_at_top:
		if is_player_message:
			styling.corner_radius_top_right = 0
		else:
			styling.corner_radius_top_left = 0
	%Background.add_theme_stylebox_override("panel", styling)


func _update_layout():
	if %Text.get_line_count() > 1 and %MessageLayoutController.size.x < maximum_size:
		%MessageLayoutController.custom_minimum_size = Vector2(%MessageLayoutController.size.x + 10, 0)
	custom_minimum_size.y = %MessageLayoutController.size.y + 6
	if is_player_message:
		%MessageLayoutController.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		%MessageLayoutController.offset_left = -%Text.size.x
