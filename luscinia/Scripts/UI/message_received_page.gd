extends Control

# Signal emitted when a message is selected
signal message_selected(message : MessageInstance)

# Tracks the number of messages displayed on the page
var num_messages = 0


# Called when the scene is loaded and ready
func _ready():
	# Connect the message_sent event from MessageManager to handle new messages
	MessageManager.message_sent.connect(_on_message_received)
	# Connect the BackButton pressed event to trigger navbar message button press
	%BackButton.pressed.connect(func(): EventBus.navbar_message_button_pressed.emit())


# Function that is called when a new message is received
func _on_message_received(message : MessageInstance):
	# If there are already messages, add a separator between messages
	if num_messages != 0:
		# Duplicate the separator and add it to the list of messages
		var seperator = %Seperator.duplicate()
		%MessagesReceived.add_child(seperator)
		%MessagesReceived.move_child(seperator, 0)  # Move the separator to the front
		seperator.visible = true
	else:
		# If there are no messages yet, check if the 'No Messages' label exists and remove it
		var no_msg_label = get_node_or_null("%NoMessagesLabel")
		if no_msg_label != null: no_msg_label.free()

	# Create a new ReceivedMessage instance to display the new message
	var new_message : ReceivedMessage = ReceivedMessage.new_instance(message)

	# Connect the click event of the new message to the _message_selected function
	new_message.message_clicked.connect(func(message_info : MessageInstance): _message_selected(
		new_message, message_info))

	# Add the new message to the list of received messages
	%MessagesReceived.add_child(new_message)
	%MessagesReceived.move_child(new_message, 0)  # Move the new message to the front

	# Increment the number of messages displayed
	num_messages += 1


# Function that is called when a message is selected
func _message_selected(message_object : ReceivedMessage, message_info : MessageInstance):
	# Emit the message_selected signal to notify other parts of the program
	message_selected.emit(message_info)

	# Mark the message as read
	message_info.read()

	# Trigger a redraw of the message object
	message_object.queue_redraw()
