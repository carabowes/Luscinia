extends Control

@onready var alert = $new_message_alert

@export_group("Messages")
var message_amount: int = 0
@export var show_alert: bool = false
@export var messages: Array[String] = []

func _process(delta: float) -> void:
	if(!show_alert || message_amount == messages.size()):
		alert.visible = false
	else:
		alert.visible = true

func print_msg_amt():
	print(str(message_amount))
