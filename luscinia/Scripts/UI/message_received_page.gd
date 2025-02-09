extends Control

var num_messages = 0

func _ready():
	MessageManager.message_sent.connect(_on_message_received)
	%BackButton.pressed.connect(func(): EventBus.message_received_page_back_button_pressed.emit())


func _on_message_received(message : MessageInstance):
	if num_messages != 0:
		var seperator = %Seperator.duplicate()
		%MessagesReceived.add_child(seperator)
		%MessagesReceived.move_child(seperator, 0)
		seperator.visible = true
		
	var new_message : ReceivedMessage = ReceivedMessage.new_instance(message)
	new_message.message_clicked.connect(func(message_info : MessageInstance): _message_selected(new_message, message_info))
	%MessagesReceived.add_child(new_message)
	%MessagesReceived.move_child(new_message, 0)
	num_messages += 1


func _message_selected(message_object : ReceivedMessage, message_info : MessageInstance):
	EventBus.message_selected.emit(message_info)
	message_info.read();
	message_object.queue_redraw()
