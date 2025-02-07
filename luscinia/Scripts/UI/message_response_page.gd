extends Control

var option_button_prefab : Button
var option_buttons : Array[Button]
var option_button_group : ButtonGroup

func _ready() -> void:
	option_button_prefab = %OptionButton.duplicate()
	option_button_group = ButtonGroup.new()
	option_button_group.allow_unpress = false


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
	print(index)
	if index >= len(option_buttons):
		return
	option_buttons[index].grab_focus()
	_render_response_info(message.responses[index])


func _render_response_info(response : Response):
	%TaskTitle.text = response.response_name
	if response.task != null:
		if response.task.expected_completion_time == 0:
			%EstimatedTime.text = "Choosing not to do anything could have consequences and damage relationships."
			%EstimatedTimeLabel.visible = false
		else:
			%EstimatedTimeLabel.visible = true
			%EstimatedTime.text = str(response.task.expected_completion_time) + "hrs"
		%GainLabel.visible =  response.task.resources_gained != {}
		%GainResources.resources = response.task.resources_gained
		%CostLabel.visible = response.task.resources_required != {}
		%CostResource.resources = response.task.resources_required
	else:
		%EstimatedTime.text = ""
		%GainResources.resources = {}
		%GainResources.resources = {}
		%CostLabel.visible = false
		%GainLabel.visible = false
		%EstimatedTimeLabel.visible = false
