class_name MessageBubble
extends Control

# Exported variables to allow for color customisation for player and non-player messages
@export var non_player_color : Color   # Color for non-player messages
@export var player_color : Color       # Color for player messages
var maximum_size = 300                 # Maximum width of the message bubble
var is_player_message = false          # Flag to check if the message is from the player
var unjoined_corner_radius = 15        # Corner radius for unjoined messages
var joined_corner_radius = 5          # Corner radius for joined messages


# Called when the scene is loaded
func _ready():
	# Connect the resized signal of the MessageLayoutController to the _update_layout function
	%MessageLayoutController.resized.connect(_update_layout)
	_update_layout()  # Update the layout when the scene is ready


# Custom draw function to handle any custom drawing
func _draw():
	if is_player_message:
		set_player_message_offsets()  # Adjust offsets if it's a player message


# Set the text of the message
func set_text(text : String):
	%MessageLayoutController.size.x = 0  # Reset the layout size for proper recalculation
	%Text.text = text  # Set the text of the message
	_update_layout()  # Update the layout based on the new text


# Set the message to be either a player message or a non-player message
func set_player_message(is_player_message : bool):
	self.is_player_message = is_player_message  # Set the flag
	# If it's a player message, change the background color to the player color,
	# otherwise to the non-player color
	if is_player_message:
		%Background.self_modulate = player_color
	else:
		%Background.self_modulate = non_player_color
	_update_layout()  # Update the layout after changing the background color


# Adjusts the alignment and offset for player messages (aligns them to the right)
func set_player_message_offsets():
	if not is_player_message or not is_inside_tree():
		return  # If it's not a player message or not inside the tree, do nothing
	# Aligns the player messages to the right
	%MessageLayoutController.offset_right = 0
	var padding = 10  # Padding on the right side
	%MessageLayoutController.offset_left = get_viewport_rect().size.x - %Background.size.x - padding


# This function handles setting the corners of the message bubble when the message "joins"
# with another message
# The corners are rounded differently based on the "joined_at_top" and "joined_at_bottom" flags
func set_join(joined_at_top : bool, joined_at_bottom : bool) -> StyleBoxFlat:
	# Create a new StyleBoxFlat for styling the background of the message bubble
	var styling : StyleBoxFlat = StyleBoxFlat.new()
	styling.bg_color = Color.WHITE  # Set background color to white
	styling.set_corner_radius_all(unjoined_corner_radius)  # Set all corners
	# to the unjoined corner radius

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

	# Apply the custom style to the background panel
	%Background.add_theme_stylebox_override("panel", styling)
	return styling  # Return the customized style


# This function updates the layout of the message bubble based on the current text and size
func _update_layout():
	%MessageLayoutController.offset_left = 0  # Reset the left offset
	# If the message has more than one line and the width is less than the maximum size,
	# adjust the layout size
	if %Text.get_line_count() > 1 and %MessageLayoutController.size.x < maximum_size:
		%MessageLayoutController.custom_minimum_size = Vector2(%MessageLayoutController.size.x + 1, 0)
	elif is_player_message:
		# If it's a player message, adjust the offsets to align it properly
		set_player_message_offsets()
		queue_redraw()  # Redraw the control to update the layout
	# Add extra space (6 pixels) between the message bubble's lines for proper spacing
	custom_minimum_size.y = %MessageLayoutController.size.y + 6
