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
	option_button_prefab.button_group = option_button_group
	option_button_prefab.toggle_mode = true
	%BackButton.pressed.connect(func(): back_button_pressed.emit())


func _option_selected(message : Message):
	var response : Response = message.responses[current_selection]
	response_option_selected.emit(response, message)


func set_message(message : Message):
	for connection in %ConfirmButton.pressed.get_connections():
		%ConfirmButton.pressed.disconnect(connection["callable"])
	if message != null:
		%ConfirmButton.pressed.connect(func(): _option_selected(message))
	_render_option_buttons(message)
	_select_option_button(0, message)


func _render_option_buttons(message : Message):
	option_buttons.clear()
	for child in %ButtonLayout.get_children():
		child.free()
	var index = 0
	if message == null:
		return
	for response : Response in message.responses:
		var new_option_button : Button = option_button_prefab.duplicate()
		new_option_button.text = response.response_name
		new_option_button.pressed.connect(func(): _select_option_button(index, message))
		option_buttons.append(new_option_button)
		%ButtonLayout.add_child(new_option_button)
		index += 1


func _select_option_button(index : int, message : Message):
	if message == null:
		_render_response_info(null, null)
		return
	current_selection = index
	if index >= len(option_buttons):
		return
	option_buttons[index].grab_focus()
	_render_response_info(message.responses[index], message)


func _set_sufficient_resources(resources : Dictionary):
	var insufficient_resources = {}
	for resource in resources:
		if not ResourceManager.has_sufficient_resource(resource, resources[resource]):
			insufficient_resources[resource] = -1

	var has_sufficient_resource : bool = len(insufficient_resources) == 0
	%CostResources.set_increments(insufficient_resources, false)
	%InvalidResourcesLabel.visible = !has_sufficient_resource
	%ConfirmButton.visible = has_sufficient_resource


func _render_response_info(response : Response, message : Message):
	var task : TaskData = null if response == null else response.task
	%TaskTitle.text = "Invalid Response" if response == null else response.response_name
	if message != null and message.default_response != -1:
		var is_default = message.default_response < len(message.responses) and \
				response == message.responses[message.default_response]
		%TaskTitle.modulate = Color(1.0, 0.6, 0.6, 1.0) if is_default else Color(1.0, 1.0, 1.0, 1.0)
		if is_default:
			%TaskTitle.text = "[Default] " + %TaskTitle.text
	if task != null:
		if task.name.to_lower() == "nothing":
			%EstimatedTime.text = "Choosing not to do anything could have consequences and damage relationships."
			%EstimatedTimeLabel.visible = false
		else:
			%EstimatedTimeLabel.visible = true
			%EstimatedTime.text = GlobalTimer.turns_to_time_string(task.expected_completion_time, "hr", "min", "s", true, true)
		%GainLabel.visible =  task.resources_gained != {}
		%GainResources.resources =task.resources_gained
		%CostLabel.visible = task.resources_required != {}
		%CostResources.resources = task.resources_required
		_set_sufficient_resources(task.resources_required)
	else:
		%EstimatedTime.text = ""
		%CostResources.resources = {}
		%GainResources.resources = {}
		%CostLabel.visible = false
		%GainLabel.visible = false
		%EstimatedTimeLabel.visible = false
