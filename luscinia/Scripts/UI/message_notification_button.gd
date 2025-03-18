extends Button


func _ready():
	visible = false
	#MessageManager.message_sent.connect(func(message): visible = true)
	#pressed.connect(func(): GameManager.navbar_message_button_pressed.emit())
	#GameManager.all_messages_read.connect(func(): visible = false)
