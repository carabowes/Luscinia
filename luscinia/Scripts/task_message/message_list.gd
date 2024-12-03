extends Control

@onready var message_manager = $"../../message_manager"
@onready var container = $ColorRect/VBoxContainer
@export var message_shortened : Array[String]
@export var message_amt: int = 0

func add_message():
	var message_instance = load("res://Nodes/task_message_buttons/button.tscn").instantiate()
	message_instance.text = add_text_from_task_data()
	container.add_child(message_instance)
	container.move_child(message_instance, 0)
	message_amt += 1

func add_text_from_task_data():
	var text = message_manager.message_data[message_amt].message
	text = text.erase(30)
	text = text + "..."
	return text
