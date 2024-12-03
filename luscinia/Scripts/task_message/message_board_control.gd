class_name MessageBoard
extends Control

@export var message_box : VBoxContainer
var map : MapTasks # this bit is a bit janky
var text_message_prefab = preload("res://Nodes/task_message_buttons/text_message.tscn")
var response_button_prefab = preload("res://Nodes/task_message_buttons/text_response_button.tscn")
signal response_picked

func clear_messages():
	for child in message_box.get_children():
		child.queue_free()


func add_message(message_data : Message) -> void:
	var text_message_instance : TextMessage = text_message_prefab.instantiate()
	text_message_instance.set_text(message_data.message)
	message_box.add_child(text_message_instance)
	for response in message_data.responses:
		add_responses(response)


func add_responses(response_data : Response) -> void:
	var response_instance : ResponseButton = response_button_prefab.instantiate()
	response_instance.text = response_data.response_text
	response_instance.initialise_button(response_data.task)
	response_instance.response_chosen.connect(dispatch_task)
	message_box.add_child(response_instance)

func dispatch_task(task_data : TaskData):
	for resource in task_data.resources_required.keys():
		if resource == "funds":
			ResourceManager.remove_resources(resource, task_data.resources_required[resource])
		else:
			ResourceManager.remove_available_resources(resource, task_data.resources_required[resource])
	var new_task_instance = TaskInstance.new(task_data, 0, 0, 0, task_data.start_location, false)
	map.add_task_instance(new_task_instance)
	response_picked.emit()
	clear_messages()
