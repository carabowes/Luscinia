class_name MessagePage
extends Control

# Signals to handle button presses
signal back_button_pressed      # Emitted when the back button is pressed
signal respond_button_pressed(message : Message)  # Emitted when the respond button is pressed

# Preload the message scene to instantiate message bubbles
var message  = preload("res://Scenes/UI/message.tscn")


# Called when the scene is loaded and ready
func _ready():
	# Connect the back button press event to emit the back_button_pressed signal
	%BackButton.pressed.connect(func(): back_button_pressed.emit())


# Show a specific message instance on the page
func show_message(message_instance : MessageInstance):
	_clear_old_message()  # Clear any existing messages
	_connect_response_button(message_instance)  # Setup response button for the message
	if message_instance == null: return  # If the message instance is null, do nothing
	_set_contact_info(message_instance.message.sender)  # Set contact info (sender details)
	_render_message(message_instance)  # Render the message content on the page


# Connect the respond button to a function that will emit the respond signal
func _connect_response_button(message_instance : MessageInstance):
	# Disconnect any existing connections for the respond button to avoid duplicates
	for connection in %RespondButton.pressed.get_connections():
		%RespondButton.pressed.disconnect(connection["callable"])
	if message_instance == null: return  # If message instance is null, do nothing
	# Connect the respond button press event to emit the respond_button_pressed signal with
	# the message instance
	%RespondButton.pressed.connect(func(): respond_button_pressed.emit(message_instance))
	# Show the respond button if the message hasn't been replied to
	%RespondButton.visible = message_instance.message_status != MessageInstance.MessageStatus.REPLIED


# Clear any old message content before rendering a new one
func _clear_old_message():
	# Free all child nodes under MessagesLayout (which are the old message bubbles)
	for child in %MessagesLayout.get_children():
		child.free()


# Render the message and its response (if available) on the message page
func _render_message(message_instance : MessageInstance):
	# Instantiate a new MessageRenderer for rendering the current message
	var message_object : MessageRenderer = message.instantiate()
	# Render the text of the message
	message_object.render_message(message_instance.message.message)
	# Set the message's player status (false for non-player messages)
	message_object.is_player_message = false
	# Add the message object as a child of the MessagesLayout
	%MessagesLayout.add_child(message_object)

	# Create a spacer between messages
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 10  # Set the spacer height to 10 pixels
	%MessagesLayout.add_child(spacer)  # Add spacer to layout

	# If there is a player response, render it as well
	if message_instance.player_response:
		# Instantiate a new MessageRenderer for the player's response
		message_object = message.instantiate()
		# Set it as a player message
		message_object.is_player_message = true
		# Render the player's response text
		message_object.render_message(message_instance.player_response)
		# Add the player's response as a child of the MessagesLayout
		%MessagesLayout.add_child(message_object)


# Set the contact information (sender profile, name, relationship status)
func _set_contact_info(sender : Sender):
	# Set the profile image of the sender
	%ContactProfile.texture = sender.image
	# Set the sender's name label
	%ContactNameLabel.text = sender.name
	# Set the relationship status colour for the sender
	%ContactRelationBar.self_modulate = sender.get_relationship_color()
	# Set the relationship value of the sender
	%ContactRelationBar.value = sender.relationship
	# Set the relationship status label for the sender
	%ContactRelationLabel.text = sender.get_relationship_status()
