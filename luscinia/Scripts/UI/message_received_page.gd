class_name MessageReceivedPage
extends Control

signal message_selected(message : MessageInstance)
var num_messages = 0
var game_timer : GameTimer

func _ready():
	GameManager.message_sent.connect(_on_message_received)
	%BackButton.pressed.connect(func(): GameManager.navbar_message_button_pressed.emit())


func _on_message_received(message : MessageInstance):
	if num_messages != 0:
		var seperator = %Seperator.duplicate()
		%MessagesReceived.add_child(seperator)
		%MessagesReceived.move_child(seperator, 0)
		seperator.visible = true
	else:
		#Accessing like this incase it's already null, don't want to free null
		var no_msg_label = get_node_or_null("%NoMessagesLabel")
		if no_msg_label != null: no_msg_label.free()
	var new_message : ReceivedMessage = ReceivedMessage.new_instance(message, game_timer)
	new_message.message_clicked.connect(func(message_info : MessageInstance): _message_selected(
	new_message, message_info))
	%MessagesReceived.add_child(new_message)
	%MessagesReceived.move_child(new_message, 0)
	num_messages += 1


func _message_selected(message_object : ReceivedMessage, message_info : MessageInstance):
	message_selected.emit(message_info)
	message_info.read();
	message_object.queue_redraw()
