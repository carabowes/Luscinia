class_name MessageBoard
extends Control

@export var message_box : VBoxContainer
@export var response_box : VBoxContainer
var map : MapTasks # this bit is a bit janky
var text_message_prefab = preload("res://Nodes/task_message_buttons/text_message.tscn")
var response_button_prefab = preload("res://Nodes/task_message_buttons/text_response_button.tscn")
signal response_picked

func clear_messages():
	for child in message_box.get_children():
		child.queue_free()
	for child in response_box.get_children():
		child.queue_free()


func add_message(message_data : Message) -> void:
	_set_sender_info(message_data.sender)
	var text_message_instance : TextMessage = text_message_prefab.instantiate()
	text_message_instance.set_text(message_data.message)
	message_box.add_child(text_message_instance)
	for response in message_data.responses:
		add_responses(response, message_data.sender)


func add_responses(response_data : Response, sender : Sender) -> void:
	var response_instance : ResponseButton = response_button_prefab.instantiate()
	response_instance.text = response_data.response_text
	response_instance.initialise_button(response_data.task, response_data, sender)
	response_instance.response_chosen.connect(dispatch_task)
	response_box.add_child(response_instance)


func dispatch_task(task_data : TaskData, response_chosen : Response, sender : Sender):
	for resource in task_data.resources_required.keys():
		if resource == "funds":
			ResourceManager.remove_resources(resource, task_data.resources_required[resource])
		else:
			ResourceManager.remove_available_resources(resource, task_data.resources_required[resource])
	var new_task_instance = TaskInstance.new(task_data, 0, 0, 0, task_data.start_location, false, task_data.resources_required, sender)
	ResourceManager.queue_relationship_change(task_data.task_id, response_chosen.relationship_change)
	map.add_task_instance(new_task_instance)
	response_picked.emit()
	clear_messages()


func _set_sender_info(sender : Sender):
	if sender == null:
		%ContactProfile.self_modulate = Color.BLACK
		%ContactRelationBar.visible = false
		%ContactNameLabel.text = "Unknown Messenger"
		return
	
	%ContactRelationBar.visible = true
	%ContactProfile.texture = sender.image
	%ContactRelationBar.value = clamp(sender.relationship, -85, 95)
	%ContactRelationBar.self_modulate = sender.get_relationship_color()
	%ContactNameLabel.text = sender.name
	%ContactRelationLabel.text = sender.get_relationship_status()


#class_name MessageBoard
#extends Control
#
#@export var message_box : VBoxContainer
#@export var response_box : VBoxContainer
#var map : MapTasks # this bit is a bit janky
#var text_message_prefab = preload("res://Nodes/task_message_buttons/text_message.tscn")
#var response_button_prefab = preload("res://Nodes/task_message_buttons/text_response_button.tscn")
#
#signal response_picked
#
#
#func clear_messages():
	#for child in message_box.get_children():
		#child.queue_free()
	#for child in response_box.get_children():
		#child.queue_free()
#
#
#func add_message(message_data : Message) -> void:
	#_set_sender_info(message_data.sender)
	#var text_message_instance : TextMessage = text_message_prefab.instantiate()
	#text_message_instance.set_text(message_data.message)
	#message_box.add_child(text_message_instance)
	#for response in message_data.responses:
		#add_responses(response, message_data.sender)
#
#
#func add_responses(response_data: Response, sender: Sender) -> void:
	#var response_instance: ResponseButton = response_button_prefab.instantiate()
	#response_instance.text = response_data.response_text
	#response_instance.initialise_button(response_data.task, response_data, sender)
	#response_instance.response_chosen.connect(dispatch_task)
	#response_box.add_child(response_instance)
#
#
#func _on_response_chosen(message_data: Message, response_chosen: Response) -> void:
	## Store the response in the global history
	#get_tree().root.get_node("main/message_manager").store_message_in_history(message_data, response_chosen.response_text)
	#dispatch_task(response_chosen.task, response_chosen, message_data.sender)
#
#
#func dispatch_task(task_data: TaskData, response_chosen: Response, sender: Sender):
	#for resource in task_data.resources_required.keys():
		#if resource == "funds":
			#ResourceManager.remove_resources(resource, task_data.resources_required[resource])
		#else:
			#ResourceManager.remove_available_resources(resource, task_data.resources_required[resource])
	#var new_task_instance = TaskInstance.new(task_data, 0, 0, 0, task_data.start_location, false, task_data.resources_required, sender)
	#ResourceManager.queue_relationship_change(task_data.task_id, response_chosen.relationship_change)
	#map.add_task_instance(new_task_instance)
	#response_picked.emit()
	#clear_messages()
#
#
#func _set_sender_info(sender : Sender):
	#if sender == null:
		#%ContactProfile.self_modulate = Color.BLACK
		#%ContactRelationBar.visible = false
		#%ContactNameLabel.text = "Unknown Messenger"
		#return
	#
	#%ContactRelationBar.visible = true
	#%ContactProfile.texture = sender.image
	#%ContactRelationBar.value = clamp(sender.relationship, -85, 95)
	#%ContactRelationBar.self_modulate = sender.get_relationship_color()
	#%ContactNameLabel.text = sender.name
	#%ContactRelationLabel.text = sender.get_relationship_status()
