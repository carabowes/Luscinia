extends Button

func _ready() -> void:
	%NotificationBubble.visible = false
	MessageManager.message_sent.connect(
	func(message: MessageInstance) -> void:
		%NotificationBubble.visible = true
	)
	pressed.connect(func(): EventBus.navbar_message_button_pressed.emit())
	EventBus.all_messages_read.connect(func(): %NotificationBubble.visible = false)
