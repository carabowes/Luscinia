extends Control

var num_messages = 0

func _ready():
	MessageManager.message_sent.connect(_on_message_received)
	%BackButton.pressed.connect(func(): visible = false)


func _on_message_received(message : Message):
	if num_messages != 0:
		var seperator = %Seperator.duplicate()
		%MessagesReceived.add_child(seperator)
		seperator.visible = true
	%MessagesReceived.add_child(ReceivedMessage.new_instance(MessageInstance.new(message)))
	num_messages += 1
