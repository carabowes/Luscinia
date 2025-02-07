class_name MessageBubble
extends Control

@export var non_player_color : Color
@export var player_color : Color
var maximum_size = 300
var is_player_message = false

func _ready():
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
			styling.corner_radius_bottom_right = 5
		else:
			styling.corner_radius_bottom_left = 5
	if joined_at_top:
		if is_player_message:
			styling.corner_radius_top_right = 5
		else:
			styling.corner_radius_top_left = 5
	%Background.add_theme_stylebox_override("panel", styling)


func _update_layout():
	%MessageLayoutController.offset_left = 0
	if %Text.get_line_count() > 1 and %MessageLayoutController.size.x < maximum_size:
		%MessageLayoutController.custom_minimum_size = Vector2(%MessageLayoutController.size.x + 1, 0)
	elif is_player_message: #Aligns the player messages to the right, bit janky but this is the only way I've found to do it
		%MessageLayoutController.offset_left = -%Text.size.x
		%MessageLayoutController.set_anchors_preset(Control.PRESET_TOP_RIGHT, true)
		if %MessageLayoutController.offset_left == -maximum_size: #Fixes some weird off by one alignment issue, still misalligned by like 1/3 of pixel but idk man
			%MessageLayoutController.offset_left+=1
	custom_minimum_size.y = %MessageLayoutController.size.y + 6 #+6 for spacing between the bubbles
