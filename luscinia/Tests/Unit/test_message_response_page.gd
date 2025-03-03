extends GutTest

var page_instance : MessageResponsePage
var test_task : TaskData 
var test_response : Response
var test_message : Message 
var test_instance : MessageInstance

func before_each():
	page_instance = load("res://Scenes/UI/message_response_page.tscn").instantiate()
	add_child_autofree(page_instance)
	test_task = TaskData.new("id", "Task", null, Vector2.ZERO, {"funds": 100}, {"funds": 100}, 4)
	test_response = Response.new("Response", "Text", 0, test_task)
	test_message = Message.new("Message", [test_response, test_response])
	test_message.default_response = -1
	test_instance = MessageInstance.new(test_message)


func test_set_message():
	page_instance.set_message(MessageInstance.new())
	assert_eq(len(page_instance.get_node("%ConfirmButton").pressed.get_connections()), 1)
	page_instance.set_message(MessageInstance.new())
	assert_eq(len(page_instance.get_node("%ConfirmButton").pressed.get_connections()), 1)


func test_null_message():
	page_instance.set_message(null)
	assert_eq(len(page_instance.get_node("%ConfirmButton").pressed.get_connections()), 0)
	assert_eq(page_instance.get_node("%ButtonLayout").get_child_count(), 0)
	assert_eq(len(page_instance.option_buttons), 0)
	assert_eq(page_instance.get_node("%TaskTitle").text, "Invalid Response")
	assert_eq(page_instance.get_node("%EstimatedTime").text, "")
	assert_eq(page_instance.get_node("%GainResources").resources, {})
	assert_eq(page_instance.get_node("%CostResources").resources, {})
	assert_eq(page_instance.get_node("%CostLabel").visible, false)
	assert_eq(page_instance.get_node("%GainLabel").visible, false)
	assert_eq(page_instance.get_node("%EstimatedTimeLabel").visible, false)


func test_non_null_message():
	page_instance.set_message(test_instance)
	assert_eq(page_instance.get_node("%TaskTitle").text, test_response.response_name)
	assert_eq(page_instance.get_node("%EstimatedTimeLabel").visible, true)
	assert_eq(page_instance.get_node("%EstimatedTime").text, "4 hrs")
	assert_eq(page_instance.get_node("%GainLabel").visible, true)
	assert_eq(page_instance.get_node("%GainResources").resources, test_task.resources_gained)
	assert_eq(page_instance.get_node("%CostLabel").visible, true)
	assert_eq(page_instance.get_node("%CostResources").resources, test_task.resources_required)


func test_default_response():
	test_message.default_response = 0  
	page_instance.set_message(test_instance)
	assert_eq(page_instance.get_node("%TaskTitle").text, "[Default] " + test_response.response_name)


func test_insufficient_resources():
	page_instance._set_sufficient_resources({"funds": ResourceManager.resources["funds"] + 1})
	assert_eq(page_instance.get_node("%InvalidResourcesLabel").visible, true)
	assert_eq(page_instance.get_node("%ConfirmButton").visible, false)


func test_sufficient_resources():
	page_instance._set_sufficient_resources({"funds": ResourceManager.resources["funds"]})
	assert_eq(page_instance.get_node("%InvalidResourcesLabel").visible, false)
	assert_eq(page_instance.get_node("%ConfirmButton").visible, true)


func test_insufficient_resources_is_called():
	test_message.responses[0].task.resources_required["funds"] = ResourceManager.resources["funds"] + 1
	page_instance._render_response_info(test_message.responses[0], test_message)
	assert_eq(page_instance.get_node("%InvalidResourcesLabel").visible, true)


func test_nothing_task_render():
	test_message.responses[0].task.name = "Nothing"
	page_instance._render_response_info(test_message.responses[0], test_message)
	assert_false(page_instance.get_node("%EstimatedTimeLabel").visible)
	assert_eq(page_instance.get_node("%EstimatedTime").text, "Choosing not to do anything could have consequences and damage relationships.")


func test_nothing_full_caps_task_render():
	test_message.responses[0].task.name = "NOTHING"
	page_instance._render_response_info(test_message.responses[0], test_message)
	assert_false(page_instance.get_node("%EstimatedTimeLabel").visible)
	assert_eq(page_instance.get_node("%EstimatedTime").text, "Choosing not to do anything could have consequences and damage relationships.")


func test_select_option_button():
	page_instance._render_option_buttons(test_message)
	page_instance._select_option_button(1, test_message)
	assert_eq(page_instance.get_node("%TaskTitle").text, test_response.response_name)
	assert_eq(page_instance.get_node("%EstimatedTimeLabel").visible, true)
	assert_eq(page_instance.get_node("%EstimatedTime").text, "4 hrs")
	assert_eq(page_instance.get_node("%GainLabel").visible, true)
	assert_eq(page_instance.get_node("%GainResources").resources, test_task.resources_gained)
	assert_eq(page_instance.get_node("%CostLabel").visible, true)
	assert_eq(page_instance.get_node("%CostResources").resources, test_task.resources_required)


func test_confirm_signal():
	page_instance.set_message(test_instance)
	watch_signals(page_instance)
	page_instance.get_node("%ConfirmButton").pressed.emit()
	assert_signal_emitted_with_parameters(page_instance, "response_option_selected", [test_response, test_instance])


func test_back_signal():
	page_instance.set_message(test_instance)
	watch_signals(page_instance)
	page_instance.get_node("%BackButton").pressed.emit()
	assert_signal_emitted(page_instance, "back_button_pressed")


func test_option_button_prefab_values():
	var option_button = page_instance.option_button_prefab.instantiate()
	assert_false(page_instance.option_button_group.allow_unpress)
	assert_ne(page_instance.get_node("%OptionButton"), page_instance.option_button_prefab, "Prefab should be a duplicate of the option button, not the same.")
	option_button.free()


func test_option_button_values():
	test_message.responses[0].response_name = "2"
	page_instance._render_option_buttons(test_message)
	var index = 0
	for button in page_instance.get_node("%ButtonLayout").get_children():
		assert_eq(button.text, test_message.responses[index].response_name)
		assert_connected(button, page_instance, "pressed")
		index += 1
	assert_eq(len(page_instance.option_buttons), len(test_message.responses))
