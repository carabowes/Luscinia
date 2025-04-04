class_name MessageResponsePage
extends Control

signal back_button_pressed
signal response_option_selected(response : Response, message : MessageInstance)

var option_button_prefab : PackedScene
var option_buttons : Array[Button]

var option_button_group : ButtonGroup

var current_selection : int = 0
var game_timer : GameTimer
var resource_manager : ResourceManager


func _ready() -> void:
	option_button_group = ButtonGroup.new()
	option_button_group.allow_unpress = false

	%OptionButton.toggle_mode = true

	option_button_prefab = PackedScene.new()
	option_button_prefab.pack(%OptionButton)

	%BackButton.pressed.connect(func(): back_button_pressed.emit())


# This function is triggered when a response option is selected
func _option_selected(message_instance : MessageInstance):
	var response : Response = message_instance.message.responses[current_selection]
	response_option_selected.emit(response, message_instance)


# This function sets the message instance and prepares the options to be displayed
func set_message(message_instance : MessageInstance):
	var message: Message = null
	if message_instance != null:
		message = message_instance.message

	# Disconnect any existing connections from the ConfirmButton (if any)
	for connection in %ConfirmButton.pressed.get_connections():
		%ConfirmButton.pressed.disconnect(connection["callable"])

	if message != null:
		%ConfirmButton.pressed.connect(func(): _option_selected(message_instance))

	# Render the option buttons and select the first option by default
	_render_option_buttons(message)
	_select_option_button(0, message)


# This function renders the response option buttons for the message
func _render_option_buttons(message : Message):
	option_buttons.clear()
	for child in %ButtonLayout.get_children():
		child.free()

	var index = 0
	# If the message is valid, create a button for each response option
	if message != null:
		for response : Response in message.responses:
			var new_option_button : Button = option_button_prefab.instantiate()
			new_option_button.text = response.response_name
			new_option_button.pressed.connect(func(): _select_option_button(index, message))
			option_buttons.append(new_option_button)
			%ButtonLayout.add_child(new_option_button)
			new_option_button.button_group = option_button_group
			index += 1


# This function selects a specific option button based on the given index
func _select_option_button(index : int, message : Message):
	if message == null:
		_render_response_info(null, null)
		return

	current_selection = index
	if index >= len(option_buttons):
		return

	option_buttons[index].grab_focus()
	_render_response_info(message.responses[index], message)


# This function checks if the required resources are sufficient for the selected response
func _set_sufficient_resources(resources : Dictionary):
	var insufficient_resources = {}
	for resource in resources:
		var resource_amount = resources[resource]
		if not resource_manager.has_sufficient_resource(resource, resources[resource]):
			insufficient_resources[resource] = -1

	# If there are no insufficient resources, allow the ConfirmButton to be visible and valid
	var has_sufficient_resource : bool = len(insufficient_resources) == 0
	%CostResources.set_increments(insufficient_resources, false)
	%InvalidResourcesLabel.visible = !has_sufficient_resource
	%ConfirmButton.visible = has_sufficient_resource


# This function renders the response information for the selected response option
func _render_response_info(response : Response, message : Message):
	var task : TaskData = null if response == null else response.task

	%TaskTitle.text = "Invalid Response" if response == null else response.response_name

	# If the message has a default response, highlight it in the UI
	if message != null and message.default_response != -1:
		var is_default = message.default_response < len(message.responses) and \
				response == message.responses[message.default_response]
		%TaskTitle.modulate = Color(1.0, 0.6, 0.6, 1.0) if is_default else Color(1.0, 1.0, 1.0, 1.0)
		if is_default:
			%TaskTitle.text = "[Default] " + %TaskTitle.text

	# If a task is associated with the response, render the task details
	if task != null:
		if task.name.to_lower() == "nothing":
			var txt= "Choosing not to do anything could have consequences and damage relationships."
			%EstimatedTime.text = txt
			%EstimatedTimeLabel.visible = false
		else:
			%EstimatedTimeLabel.visible = true
			%EstimatedTime.text = GameTimer.turns_to_time_string(
				game_timer, task.expected_completion_time, "hr", "min", "s", true, true
			)
		%GainLabel.visible =  task.resources_gained != {}
		%GainResources.resources = task.resources_gained
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
