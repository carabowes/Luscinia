extends Control

var num_messages = 0
@export var message_page : MessagePage

func _ready():
	MessageManager.message_sent.connect(_on_message_received)
	%BackButton.pressed.connect(func(): visible = false)


func _on_message_received(message : Message):
	if num_messages != 0:
		var seperator = %Seperator.duplicate()
		%MessagesReceived.add_child(seperator)
		seperator.visible = true
	var new_message : ReceivedMessage = ReceivedMessage.new_instance(MessageInstance.new(message))
	new_message.message_clicked.connect(func(message_info : MessageInstance): _message_selected(new_message, message_info))
	%MessagesReceived.add_child(new_message)
	num_messages += 1


func _message_selected(message_object : ReceivedMessage, message_info : MessageInstance):
	message_page.visible = true
	message_page.show_message(message_info)
	message_info.message_status = MessageInstance.MessageStatus.READ;
	message_object.queue_redraw()
