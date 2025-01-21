extends Node
@onready var message_history = $"../../../pages/message_history"

func _ready() -> void:
	self.pressed.connect(self.button_pressed)


func button_pressed():
	message_history.visible = !message_history.visible
