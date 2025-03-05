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


func test_update_task():
	task_instance.current_progress = 0
	task_instance.task_data.expected_completion_time = 2
	TaskManager._start_task(task_instance, 0)
	TaskManager._update_tasks()
	assert_eq(task_instance.current_progress, 1)
	assert_eq(len(TaskManager.active_tasks), 1)
	assert_eq(len(TaskManager.completed_tasks), 0)
	TaskManager._update_tasks()
	assert_eq(task_instance.current_progress, 2)
	assert_eq(task_instance.is_completed, true)
	assert_eq(len(TaskManager.active_tasks), 0)
	assert_eq(len(TaskManager.completed_tasks), 1)


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


func test_task_cancelled():
	watch_signals(EventBus)
	TaskManager._start_task(task_instance, 0)
	TaskManager._on_task_cancelled(task_instance)
	assert_eq(len(TaskManager.active_tasks), 0)
	assert_false(task_instance in TaskManager.completed_tasks)
	assert_signal_emitted(EventBus, "task_finished")


func test_task_cancelled_act_as_completed():
	message.cancel_behaviour = Message.CancelBehaviour.ACT_AS_COMPLETED
	watch_signals(EventBus)
	TaskManager._start_task(task_instance, 0)
	TaskManager._on_task_cancelled(task_instance)
	assert_eq(task_instance.is_completed, true)
	assert_eq(len(TaskManager.active_tasks), 0)
	assert_true(task_instance in TaskManager.completed_tasks)
	assert_signal_emitted(EventBus, "task_finished")


func test_task_cancelled_pick_default():
	message.cancel_behaviour = Message.CancelBehaviour.PICK_DEFAULT
	message.responses.append(Response.new("","",0,TaskData.default_task))
	message.default_response = len(message.responses)-1
	watch_signals(EventBus)
	TaskManager._start_task(task_instance, 0)
	TaskManager._on_task_cancelled(task_instance)
	assert_eq(len(TaskManager.completed_tasks), 1)
	assert_eq(len(TaskManager.active_tasks), 0)
	assert_false(task_instance.is_completed)
	assert_false(task_instance in TaskManager.completed_tasks)
	assert_signal_emitted(EventBus, "task_finished")


func test_multiple_tasks():
	task_instance.current_progress = 0
	task_instance.task_data.expected_completion_time = 1
	var task_one : TaskInstance = task_instance.duplicate(true)
	var task_two : TaskInstance = task_instance.duplicate(true)
	task_one.task_data.task_id = "TaskOne"
	task_one.message = message
	task_two.task_data.task_id = "TaskTwo"
	task_two.message = message
	watch_signals(EventBus)
	TaskManager._start_task(task_one, 20)
	TaskManager._start_task(task_two, -10)
	TaskManager._update_tasks()
	assert_eq(len(TaskManager.completed_tasks), 2, "There should be 2 completed tasks1")
	assert_eq(len(TaskManager.active_tasks), 0, "There should be no active tasks")
	assert_eq(message.sender.relationship, 10.0, "Relationship should be 10")
	assert_signal_emit_count(EventBus, "task_finished", 2)


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
