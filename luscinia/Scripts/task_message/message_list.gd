extends Control

@onready var message_manager = $"../../message_manager"
@onready var container = $ColorRect/VBoxContainer
@export var message_shortened : Array[String]

func add_message():
	var message_instance = load("res://Nodes/task_message_buttons/button.tscn").instantiate()
	message_instance.text = add_text_from_task_data()
	container.add_child(message_instance)
	container.move_child(message_instance, 0)

func add_text_from_task_data():
	if(message_manager.send_rand):
		var text = message_manager.random_task_data[message_manager.current_rand].message
		text = text.erase(40,1000)
		text = text + "..."
		return text
	else:
		var text = message_manager.message_data[message_manager.current_message].message
		text = text.erase(40,1000)
		text = text + "..."
		return text
