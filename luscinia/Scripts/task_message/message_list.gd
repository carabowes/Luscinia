extends Control

@onready var message_manager = $"../../message_manager"
@onready var container = $ColorRect/VBoxContainer
@export var message_shortened : Array[String]
@export var message_board : MessageBoard


func _ready():
	MessageManager.message_sent.connect(add_message)


func add_message(message: MessageInstance):
	var message_instance : Button = load("res://Nodes/task_message_buttons/button.tscn").instantiate()
	message_instance.pressed.connect(func():message_board.add_message(message.message))
	message_instance.text = add_text_from_task_data(message.message)
	container.add_child(message_instance)
	container.move_child(message_instance, 0)


func add_text_from_task_data(message: Message):
	var text = message.message
	text = text.erase(40,1000)
	text = text + "..."
	return text
