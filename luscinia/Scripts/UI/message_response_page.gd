class_name MessageResponsePage
extends Control

signal back_button_pressed
signal response_option_selected(response : Response, message : Message)

var option_button_prefab : Button
var option_buttons : Array[Button]
var option_button_group : ButtonGroup
var current_selection : int = 0

func _ready() -> void:
	option_button_prefab = %OptionButton.duplicate()
	option_button_group = ButtonGroup.new()
	option_button_group.allow_unpress = false
	%BackButton.pressed.connect(func(): back_button_pressed.emit())


func _option_selected(message : Message):
	var response : Response = message.responses[current_selection]
	response_option_selected.emit(response, message)


func set_message(message : Message):
	_render_option_buttons(message)
	_select_option_button(0, message)
	for connection in %ConfirmButton.pressed.get_connections():
		%ConfirmButton.pressed.disconnect(connection["callable"])
	%ConfirmButton.pressed.connect(func(): _option_selected(message))


func _render_option_buttons(message : Message):
	option_buttons.clear()
	for child in %ButtonLayout.get_children():
		child.free()
	var index = 0
	for response : Response in message.responses:
		var new_option_button : Button = option_button_prefab.duplicate()
		new_option_button.text = response.response_name
		new_option_button.pressed.connect(func(): _select_option_button(index, message))
		new_option_button.toggle_mode = true
		option_buttons.append(new_option_button)
		new_option_button.button_group = option_button_group
		%ButtonLayout.add_child(new_option_button)
		index += 1


func _select_option_button(index : int, message : Message):
	current_selection = index
	if index >= len(option_buttons):
		return
	option_buttons[index].grab_focus()
	_render_response_info(message.responses[index])


func _render_response_info(response : Response):
	var task : TaskData = response.task
	%TaskTitle.text = response.response_name
	if task != null:
		if task.expected_completion_time == 0:
			%EstimatedTime.text = "Choosing not to do anything could have consequences and damage relationships."
			%EstimatedTimeLabel.visible = false
		else:
			%EstimatedTimeLabel.visible = true
			%EstimatedTime.text = str(task.expected_completion_time) + "hrs"
		%GainLabel.visible =  task.resources_gained != {}
		%GainResources.resources =task.resources_gained
		%CostLabel.visible = task.resources_required != {}
		%CostResource.resources = task.resources_required

		#Resource Validation
		var insufficient_resources = {}
		for resource in task.resources_required.keys():
			if not ResourceManager.has_sufficient_resource(resource, task.resources_required[resource]):
				insufficient_resources[resource] = -1

		var has_sufficient_resource : bool = len(insufficient_resources) == 0
		%CostResource.set_increments(insufficient_resources, false)
		%InvalidResourcesLabel.visible = !has_sufficient_resource
		%ConfirmButton.visible = has_sufficient_resource
	else:
		%EstimatedTime.text = ""
		%GainResources.resources = {}
		%GainResources.resources = {}
		%CostLabel.visible = false
		%GainLabel.visible = false
		%EstimatedTimeLabel.visible = false
