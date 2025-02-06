extends GutTest

var task_instance
var task_data
var test_sender


func before_each():
	task_data = TaskData.new(1,"Test",null,Vector2(0,0),Vector2(10,10),{"funds":10},{"funds":10},5,[])
	test_sender = Sender.new("Test Sender",null,0)
	task_instance = TaskInstance.new(
		task_data,
		TaskInstance.CurrentStatus.IDLING,
		4,  # current_progress
		2,  # extra_time
		Vector2(5, 5),
		false,
		{ "funds": 5 },
		test_sender
	)

func test_task_data_initialisation():
	assert_eq(task_data.task_id, 1, "Task ID should be correctly assigned")
	assert_eq(task_data.name, "Test", "Task name should be correctly assigned")
	assert_eq(task_data.icon, null, "Task icon should be null by default")
	assert_eq(task_data.start_location, Vector2(0,0), "Start location should be correctly assigned")
	assert_eq(task_data.end_location, Vector2(10,10), "End location should be correctly assigned")
	assert_eq(task_data.resources_required, {"funds":10}, "Resources required should match the dictionary")
	assert_eq(task_data.resources_gained, {"funds":10}, "Resources gained should match the dictionary")
	assert_eq(task_data.expected_completion_time, 5, "Expected completion time should be correctly assigned")
	assert_eq(task_data.effects_of_random_events, [], "Effects of random events should be an empty array")



func test_initialisation():
	assert_eq(task_instance.task_data, task_data, "Task data should be correctly assigned")
	assert_eq(task_instance.current_status, TaskInstance.CurrentStatus.IDLING, "Current status should be IDLING")
	assert_eq(task_instance.current_progress, 4, "Current progress should be 4")
	assert_eq(task_instance.extra_time, 2, "Extra time should be 2")
	assert_eq(task_instance.current_location, Vector2(5, 5), "Current location should be (5,5)")
	assert_eq(task_instance.is_completed, false, "is_completed should be false")
	assert_eq(task_instance.actual_resources, { "funds": 5 }, "Actual resources should match the dictionary")
	assert_eq(task_instance.sender.name, "Test Sender", "Sender name should be correctly set")
	assert_eq(task_instance.sender.image, null, "Sender image should be null by default")
	assert_eq(task_instance.sender.relationship, 0, "Relationship should start at neutral (0)")

func test_get_total_time():
	assert_eq(task_instance.get_total_time(), 7, "Total time should be expected completion time (5) + extra time (2)")

func test_get_remaining_time():
	assert_eq(task_instance.get_remaining_time(), 3, "Remaining time should be total time (7) - current progress (4)")
