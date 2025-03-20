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


# Custom draw function to handle any custom drawing
func _draw():
	if is_player_message:
		set_player_message_offsets()


# Set the text of the message
func set_text(text : String):
	%MessageLayoutController.size.x = 0
	%Text.text = text
	_update_layout()


# Set the message to be either a player message or a non-player message
func set_player_message(is_player_message : bool):
	self.is_player_message = is_player_message
	if is_player_message:
		%Background.self_modulate = player_color
	else:
		%Background.self_modulate = non_player_color
	_update_layout()


# Adjusts the alignment and offset for player messages (aligns them to the right)
func set_player_message_offsets():
	if not is_player_message or not is_inside_tree():
		return  # If it's not a player message or not inside the tree, do nothing
	%MessageLayoutController.offset_right = 0
	var padding = 10
	%MessageLayoutController.offset_left = get_viewport_rect().size.x - %Background.size.x - padding


# This function handles setting the corners of the message bubble when the message "joins"
# with another message
# The corners are rounded differently based on the "joined_at_top" and "joined_at_bottom" flags
func set_join(joined_at_top : bool, joined_at_bottom : bool) -> StyleBoxFlat:
	var styling : StyleBoxFlat = StyleBoxFlat.new()
	styling.bg_color = Color.WHITE
	styling.set_corner_radius_all(unjoined_corner_radius)
	# If the message joins at the bottom, adjust the appropriate corner radius based on
	# player/non-player message
	if joined_at_bottom:
		if is_player_message:
			styling.corner_radius_bottom_right = joined_corner_radius
		else:
			styling.corner_radius_bottom_left = joined_corner_radius

	# If the message joins at the top, adjust the appropriate corner radius based on
	# player/non-player message
	if joined_at_top:
		if is_player_message:
			styling.corner_radius_top_right = joined_corner_radius
		else:
			styling.corner_radius_top_left = joined_corner_radius

	%Background.add_theme_stylebox_override("panel", styling)
	return styling


# This function updates the layout of the message bubble based on the current text and size
func _update_layout():
	%MessageLayoutController.offset_left = 0
	# If the message has more than one line and the width is less than the maximum size,
	# adjust the layout size
	if %Text.get_line_count() > 1 and %MessageLayoutController.size.x < maximum_size:
		%MessageLayoutController.custom_minimum_size = Vector2(%MessageLayoutController.size.x + 1, 0)
	elif is_player_message:
		# If it's a player message, adjust the offsets to align it properly
		set_player_message_offsets()
		queue_redraw()
	custom_minimum_size.y = %MessageLayoutController.size.y + 6
