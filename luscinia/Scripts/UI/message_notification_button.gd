extends Button


func _ready():
	visible = false
	MessageManager.message_sent.connect(func(message): visible = true)
	pressed.connect(func(): EventBus.navbar_message_button_pressed.emit())
	EventBus.all_messages_read.connect(func(): visible = false)
