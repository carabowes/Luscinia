extends GutTest

var task_instance
var task_data
var test_message


func before_each():
	task_data = TaskData.new("TaskID","Test",null,Vector2(0,0),{"funds":10},{"funds":15},5,[])
	test_message =  Message.default_message
	task_instance = TaskInstance.new(
		task_data,
		test_message
	)
	print(test_message.sender)
	task_instance.current_progress = 4
	task_instance.extra_time = 2
	task_instance.current_location = Vector2(5,5)


func test_task_data_initialisation():
	assert_eq(task_data.task_id, "TaskID", "Task ID should be correctly assigned")
	assert_eq(task_data.name, "Test", "Task name should be correctly assigned")
	assert_eq(task_data.icon, null, "Task icon should be null by default")
	assert_eq(task_data.start_location, Vector2(0,0), "Start location should be correctly assigned")
	assert_eq(task_data.resources_required, {"funds":10}, "Resources required should match the dictionary")
	assert_eq(task_data.resources_gained, {"funds":15}, "Resources gained should match the dictionary")
	assert_eq(task_data.expected_completion_time, 5, "Expected completion time should be correctly assigned")
	assert_eq(task_data.effects_of_random_events, [], "Effects of random events should be an empty array")


func test_initialisation():
	assert_eq(task_instance.task_data, task_data, "Task data should be correctly assigned")
	assert_eq(task_instance.current_progress, 4, "Current progress should be 4")
	assert_eq(task_instance.extra_time, 2, "Extra time should be 2")
	assert_eq(task_instance.current_location, Vector2(5, 5), "Current location should be (5,5)")
	assert_eq(task_instance.is_completed, false, "is_completed should be false")
	assert_eq(task_instance.actual_resources, { "funds": 10 }, "Actual resources should match the dictionary")
	assert_eq(task_instance.message, test_message, "Message should be assigned")


func test_get_total_time():
	assert_eq(task_instance.get_total_time(), 7, "Total time should be expected completion time (5) + extra time (2)")


func test_get_remaining_time():
	assert_eq(task_instance.get_remaining_time(), 3, "Remaining time should be total time (7) - current progress (4)")
