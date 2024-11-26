extends Control

@onready var alert = $Button

@export_group("Messages")
var message_amount: int = 0
@export var show_alert: bool = false
@export var messages: Array[String] = []

@export_group("Resources")
@export var personnel: int = 100
@export var funding: int = 100
@export var equipment: int = 100

@export_group("Stats")
@export var stability: int = 100

func _process(delta: float) -> void:
	if(!show_alert):
		alert.visible = false
	else:
		alert.visible = true

func print_msg_amt():
	print(str(message_amount))
