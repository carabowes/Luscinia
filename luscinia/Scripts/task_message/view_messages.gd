extends Node
#var message_history = $"../../../pages/MessagesReceivedPage"

func _ready() -> void:
	self.pressed.connect(self.button_pressed)
	%NotificationBubble.visible = false
	MessageManager.message_sent.connect(func (message: MessageInstance) : %NotificationBubble.visible = true)


func button_pressed():
	#message_history.visible = !message_history.visible
	%NotificationBubble.visible = false
	EventBus.navbar_message_button_pressed.emit()
