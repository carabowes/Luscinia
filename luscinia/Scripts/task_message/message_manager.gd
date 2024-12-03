extends Control

@onready var alert = $Button

@export_group("Messages")
var message_amount: int = 0
@export var show_alert: bool = false
@export var messages: Array[String] = []

func _process(delta: float) -> void:
	if(!show_alert || messages.size() == message_amount):
		alert.visible = false
	else:
		alert.visible = true

func print_msg_amt():
	print(str(message_amount))
