extends GutTest

var task_details : TaskDetails


func before_each():
	task_details = load("res://Scenes/task_details.tscn").instantiate()
	add_child_autofree(task_details)


func after_all():
	ResourceManager.reset_resources()


func test_set_details():
	var task_instance : TaskInstance = TaskInstance.new()
	task_details._set_task_instance(task_instance)

	assert_eq(task_details.current_task_instance, task_instance)
	#Just to test if set_details_ui was called
	assert_eq(task_details.get_node("%TaskTitle").text, task_instance.task_data.name)


func test_set_details_ui():
	var task_instance : TaskInstance = TaskInstance.new()
	task_instance.current_progress = 1
	task_instance.extra_time = 1
	task_details._set_details_ui(task_instance)

	assert_eq(task_details.get_node("%ScrollingBackground").texture, task_instance.task_data.icon)
	assert_eq(task_details.get_node("%TaskProgressBar").value, float(task_instance.current_progress))
	assert_eq(task_details.get_node("%TaskProgressBar").total_task_time, float(task_instance.get_total_time()))
	assert_eq(task_details.get_node("%TaskTitle").text, task_instance.task_data.name)
	assert_eq(task_details.get_node("%ResourcesUsed").resources, task_instance.actual_resources)
	assert_eq(task_details.get_node("%OnCompletion").resources, task_instance.task_data.resources_gained)
	assert_eq(task_details.get_node("%SenderIcon").texture, task_instance.sender.image)


func test_set_end_early_ui():
	ResourceManager.resources = {"funds": 0, "people": 0, "vehicles": 0, "supplies": 0}
	var task_data : TaskData = TaskData.default_task
	task_data.resources_gained = {"funds": 500}
	task_data.resources_required = {"people": 100}
	var task_instance : TaskInstance = TaskInstance.new(task_data)
	task_details._set_end_early_ui(task_instance)
	assert_eq(task_details.get_node("%EndNowResources").resources, {"funds": 0, "people": 100, "vehicles": 0, "supplies": 0})
	assert_eq(task_details.get_node("%FullTimeResources").resources, {"funds": 500, "people": 0, "vehicles": 0, "supplies": 0})


func test_show_task_details():
	task_details._show_task_details()
	assert_eq(task_details.visible, true)
	assert_almost_eq(task_details.get_node("%TaskDetails").scale.y, 0.0, 0.01)
	assert_eq(task_details.get_node("%TaskDetails").visible, true)
	await wait_seconds(0.25)
	assert_eq(task_details.get_node("%TaskDetails").scale.y, 1.0)


func test_hide_task_details():
	task_details._hide_task_details()
	await wait_seconds(0.3)
	assert_eq(task_details.get_node("%TaskDetails").visible, false)
	assert_almost_eq(task_details.get_node("%TaskDetails").scale.y, 0.0, 0.01)


func test_connections():
	assert_connected(task_details.get_node("%ConfirmEndButton"), task_details, "pressed")
	assert_connected(task_details.get_node("%CancelEndButton"), task_details, "pressed")
	assert_connected(task_details.get_node("%ReturnButton"), task_details, "pressed")
	assert_connected(task_details.get_node("%EndEarlyButton"), task_details, "pressed")
	assert_connected(EventBus, task_details, "task_widget_view_details_pressed")
	assert_connected(GlobalTimer, task_details, "turn_progressed")
