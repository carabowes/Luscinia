extends Control

# Signals to emit when the back button is pressed and when a response option is selected
signal back_button_pressed
signal response_option_selected(response : Response, message : MessageInstance)

# Prefab for the option buttons and an array to hold the buttons
var option_button_prefab : PackedScene
var option_buttons : Array[Button]

# Button group to ensure only one option button can be selected at a time
var option_button_group : ButtonGroup

# Variable to keep track of the currently selected option
var current_selection : int = 0


# Called when the scene is ready and initialised
func _ready() -> void:
	# Create a new ButtonGroup and disable unpressing (i.e., a button will stay pressed once selected)
	option_button_group = ButtonGroup.new()
	option_button_group.allow_unpress = false

	# Set the OptionButton to toggle mode
	%OptionButton.toggle_mode = true

	# Create the prefab for the option button from the current scene
	option_button_prefab = PackedScene.new()
	option_button_prefab.pack(%OptionButton)

	# Connect the back button press signal to emit the back_button_pressed signal
	%BackButton.pressed.connect(func(): back_button_pressed.emit())


# This function is triggered when a response option is selected
func _option_selected(message_instance : MessageInstance):
	# Get the selected response from the message instance and emit the response_option_selected signal
	var response : Response = message_instance.message.responses[current_selection]
	response_option_selected.emit(response, message_instance)


# This function sets the message instance and prepares the options to be displayed
func set_message(message_instance : MessageInstance):
	var message: Message = null
	# If the message_instance is valid, assign its message to 'message'
	if message_instance != null:
		message = message_instance.message

	# Disconnect any existing connections from the ConfirmButton (if any)
	for connection in %ConfirmButton.pressed.get_connections():
		%ConfirmButton.pressed.disconnect(connection["callable"])

	# If a message exists, connect the ConfirmButton press to call _option_selected
	if message != null:
		%ConfirmButton.pressed.connect(func(): _option_selected(message_instance))

	# Render the option buttons and select the first option by default
	_render_option_buttons(message)
	_select_option_button(0, message)


# This function renders the response option buttons for the message
func _render_option_buttons(message : Message):
	# Clear any existing buttons
	option_buttons.clear()
	for child in %ButtonLayout.get_children():
		child.free()

	var index = 0
	# If the message is valid, create a button for each response option
	if message != null:
		for response : Response in message.responses:
			# Instantiate a new option button from the prefab
			var new_option_button : Button = option_button_prefab.instantiate()
			# Set the text of the button to the response name
			new_option_button.text = response.response_name
			# Connect the button press event to the _select_option_button function
			new_option_button.pressed.connect(func(): _select_option_button(index, message))
			# Add the button to the list of option buttons
			option_buttons.append(new_option_button)
			# Add the button to the ButtonLayout
			%ButtonLayout.add_child(new_option_button)
			# Assign the button to the option_button_group to ensure only one button
			# can be selected at a time
			new_option_button.button_group = option_button_group
			index += 1


# This function selects a specific option button based on the given index
func _select_option_button(index : int, message : Message):
	# If the message is null, clear the response info
	if message == null:
		_render_response_info(null, null)
		return

	# Update the current selection with the given index
	current_selection = index
	# If the index is out of bounds, return
	if index >= len(option_buttons):
		return

	# Focus on the selected button
	option_buttons[index].grab_focus()
	# Render the response information for the selected option
	_render_response_info(message.responses[index], message)


# This function checks if the required resources are sufficient for the selected response
func _set_sufficient_resources(resources : Dictionary):
	# Create a dictionary to track insufficient resources
	var insufficient_resources = {}
	for resource in resources:
		# Check if there are sufficient resources for the given resource type
		if not ResourceManager.has_sufficient_resource(resource, resources[resource]):
			# If not, mark the resource as insufficient
			insufficient_resources[resource] = -1

	# If there are no insufficient resources, allow the ConfirmButton to be visible and valid
	var has_sufficient_resource : bool = len(insufficient_resources) == 0
	%CostResources.set_increments(insufficient_resources, false)
	%InvalidResourcesLabel.visible = !has_sufficient_resource
	%ConfirmButton.visible = has_sufficient_resource


# This function renders the response information for the selected response option
func _render_response_info(response : Response, message : Message):
	# If no response is selected, set task to null
	var task : TaskData = null if response == null else response.task

	# Set the task title text based on the response or "Invalid Response" if no response
	%TaskTitle.text = "Invalid Response" if response == null else response.response_name

	# If the message has a default response, highlight it in the UI
	if message != null and message.default_response != -1:
		var is_default = message.default_response < len(message.responses) and \
				response == message.responses[message.default_response]
		%TaskTitle.modulate = Color(1.0, 0.6, 0.6, 1.0) if is_default else Color(1.0, 1.0, 1.0, 1.0)
		# Mark the default response with "[Default]" in the title
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
			# Render the expected completion time of the task
			%EstimatedTime.text = GlobalTimer.turns_to_time_string(
			task.expected_completion_time, "hr", "min", "s", true, true)
		%GainLabel.visible =  task.resources_gained != {}
		%GainResources.resources = task.resources_gained
		%CostLabel.visible = task.resources_required != {}
		%CostResources.resources = task.resources_required
		# Check if sufficient resources are available
		_set_sufficient_resources(task.resources_required)
	else:
		%EstimatedTime.text = ""
		%CostResources.resources = {}
		%GainResources.resources = {}
		%CostLabel.visible = false
		%GainLabel.visible = false
		%EstimatedTimeLabel.visible = false
