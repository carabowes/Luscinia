extends Control

signal message_selected(message : MessageInstance)

var num_messages = 0


func _ready():
	MessageManager.message_sent.connect(_on_message_received)
	%BackButton.pressed.connect(func(): EventBus.navbar_message_button_pressed.emit())


# Function that is called when a new message is received
func _on_message_received(message : MessageInstance):
	if num_messages != 0:
		var seperator = %Seperator.duplicate()
		%MessagesReceived.add_child(seperator)
		%MessagesReceived.move_child(seperator, 0)
		seperator.visible = true
	else:
		# If there are no messages yet, check if the 'No Messages' label exists and remove it
		var no_msg_label = get_node_or_null("%NoMessagesLabel")
		if no_msg_label != null: no_msg_label.free()

	var new_message : ReceivedMessage = ReceivedMessage.new_instance(message)

	new_message.message_clicked.connect(func(message_info : MessageInstance): _message_selected(
		new_message, message_info))

	# Add the new message to the list of received messages
	%MessagesReceived.add_child(new_message)
	%MessagesReceived.move_child(new_message, 0)

	num_messages += 1


# Function that is called when a message is selected
func _message_selected(message_object : ReceivedMessage, message_info : MessageInstance):
	message_selected.emit(message_info)

	message_info.read()

	message_object.queue_redraw()
