extends Node
@onready var message_history = $"../../../pages/text_message_list"

func _ready() -> void:
	self.pressed.connect(self.button_pressed)
	%NotificationBubble.visible = false
	MessageManager.message_sent.connect(func (message: Message) : %NotificationBubble.visible = true)


func button_pressed():
	message_history.visible = !message_history.visible
	%NotificationBubble.visible = false
