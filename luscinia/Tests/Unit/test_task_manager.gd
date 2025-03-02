extends GutTest

var task : TaskData
var message : Message
var task_instance : TaskInstance

func before_each():
	TaskManager.active_tasks = []
	TaskManager.completed_tasks = []
	task = TaskData.default_task
	message = Message.default_message
	task_instance = TaskInstance.new(task, message)


func test_message_responded():
	watch_signals(EventBus)
	var response : Response = Response.new("", "", 10, task)
	var message_instance : MessageInstance = MessageInstance.new(message)
	EventBus.message_responded.emit(response, message_instance)
	assert_signal_emitted(EventBus, "task_started")


func test_start_task():
	watch_signals(EventBus)
	TaskManager._start_task(task_instance, 10)
	assert_eq(len(TaskManager.active_tasks), 1, "Task should be in active tasks")
	assert_eq(len(ResourceManager.relationships_to_update), 1, "Relationship not queued")
	assert_signal_emitted_with_parameters(EventBus, "task_started", [task_instance])


func test_finish_task():
	task_instance.current_progress = task.expected_completion_time
	task_instance.is_completed = true
	watch_signals(EventBus)
	TaskManager._start_task(task_instance, 10)
	TaskManager._finish_task(task_instance, false)
	assert_eq(len(TaskManager.active_tasks), 0, "Task was not removed from active tasks")
	assert_eq(len(TaskManager.completed_tasks), 1, "Task was not added to completed tasks")
	assert_eq(message.sender.relationship, 10.0, "Relationship should be 10 after task completion")
	assert_signal_emitted_with_parameters(EventBus, "task_finished", [task_instance])


func test_zero_time_task():
	task_instance.task_data.expected_completion_time = 0
	TaskManager._start_task(task_instance, 0)
	assert_eq(len(TaskManager.completed_tasks), 1)


func test_positive_relationship_applied_zero_time_task():
	task_instance.task_data.expected_completion_time = 0
	var sender = message.sender
	TaskManager._start_task(task_instance, 10)
	assert_eq(sender.relationship, 10.0, "Relationship should be 10 after task completion")


func test_negative_relationship_applied_zero_time_task():
	task_instance.task_data.expected_completion_time = 0
	var sender = message.sender
	TaskManager._start_task(task_instance, -20)
	assert_eq(sender.relationship, -20.0, "Relationship should be -20 after task completion")
