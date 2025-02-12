class_name MessageBubble
extends Control

@export var non_player_color : Color
@export var player_color : Color
var maximum_size = 300
var is_player_message = false
var unjoined_corner_radius = 15
var joined_corner_radius = 5

func _ready():
	%MessageLayoutController.resized.connect(_update_layout)
	_update_layout()


func _draw():
	if is_player_message: 
		set_player_message_offsets()


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


func set_player_message_offsets():
	if not is_player_message:
		return
	#Aligns the player messages to the right
	%MessageLayoutController.offset_right = 0
	var padding = 10
	%MessageLayoutController.offset_left = get_viewport_rect().size.x - %Background.size.x - padding


func set_join(joined_at_top : bool, joined_at_bottom : bool) -> StyleBoxFlat:
	var styling : StyleBoxFlat = StyleBoxFlat.new() 
	styling.bg_color = Color.WHITE
	styling.set_corner_radius_all(unjoined_corner_radius)
	if joined_at_bottom:
		if is_player_message:
			styling.corner_radius_bottom_right = joined_corner_radius
		else:
			styling.corner_radius_bottom_left = joined_corner_radius
	if joined_at_top:
		if is_player_message:
			styling.corner_radius_top_right = joined_corner_radius
		else:
			styling.corner_radius_top_left = joined_corner_radius
	%Background.add_theme_stylebox_override("panel", styling)
	return styling


func _update_layout():
	%MessageLayoutController.offset_left = 0
	if %Text.get_line_count() > 1 and %MessageLayoutController.size.x < maximum_size:
		%MessageLayoutController.custom_minimum_size = Vector2(%MessageLayoutController.size.x + 1, 0)
	elif is_player_message:
		set_player_message_offsets()
		queue_redraw()
	custom_minimum_size.y = %MessageLayoutController.size.y + 6 #+6 for spacing between the bubbles
