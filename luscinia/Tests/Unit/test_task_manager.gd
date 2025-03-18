extends GutTest

var task : TaskData
var message : Message
var task_instance : TaskInstance
var task_manager : TaskManager
var resource_manager : ResourceManager

func before_each():
	task_manager = TaskManager.new()
	resource_manager = ResourceManager.new(Scenario.default_scenario.resources, Scenario.default_scenario.available_resources)
	add_child_autofree(task_manager)
	add_child_autofree(resource_manager)
	task = TaskData.default_task
	message = Message.default_message
	task_instance = TaskInstance.new(task, message)


func test_message_responded():
	watch_signals(GameManager)
	var response : Response = Response.new("", "", 10, task)
	var message_instance : MessageInstance = MessageInstance.new(message)
	GameManager.message_responded.emit(response, message_instance)
	assert_signal_emitted(GameManager, "task_started")


func test_start_task():
	watch_signals(GameManager)
	task_instance.relationship_change = 10
	task_manager._start_task(task_instance)
	assert_eq(len(task_manager.active_tasks), 1, "Task should be in active tasks")
	assert_signal_emitted_with_parameters(GameManager, "task_started", [task_instance])


func test_update_task():
	task_instance.current_progress = 0
	task_instance.task_data.expected_completion_time = 2
	task_manager._start_task(task_instance)
	task_manager._update_tasks(1)
	assert_eq(task_instance.current_progress, 1)
	assert_eq(len(task_manager.active_tasks), 1)
	assert_eq(len(task_manager.completed_tasks), 0)
	task_manager._update_tasks(2)
	assert_eq(task_instance.current_progress, 2)
	assert_eq(task_instance.is_completed, true)
	assert_eq(len(task_manager.active_tasks), 0)
	assert_eq(len(task_manager.completed_tasks), 1)


func test_finish_task():
	task_instance.current_progress = task.expected_completion_time
	task_instance.is_completed = true
	watch_signals(GameManager)
	task_instance.relationship_change = 10
	task_manager._start_task(task_instance)
	task_manager._complete_task(task_instance, false)
	assert_eq(len(task_manager.active_tasks), 0, "Task was not removed from active tasks")
	assert_eq(len(task_manager.completed_tasks), 1, "Task was not added to completed tasks")
	assert_eq(message.sender.relationship, 10.0, "Relationship should be 10 after task completion")
	assert_signal_emitted_with_parameters(GameManager, "task_finished", [task_instance, false])


func test_task_cancelled():
	watch_signals(GameManager)
	task_manager._start_task(task_instance)
	task_manager.cancel_task(task_instance)
	assert_eq(len(task_manager.active_tasks), 0)
	assert_false(task_instance in task_manager.completed_tasks)
	assert_signal_emitted(GameManager, "task_finished")


func test_task_cancelled_act_as_completed():
	message.cancel_behaviour = Message.CancelBehaviour.ACT_AS_COMPLETED
	watch_signals(GameManager)
	task_manager._start_task(task_instance)
	task_manager.cancel_task(task_instance)
	assert_eq(task_instance.is_completed, true)
	assert_eq(len(task_manager.active_tasks), 0)
	assert_true(task_instance in task_manager.completed_tasks)
	assert_signal_emitted(GameManager, "task_finished")


func test_task_cancelled_pick_default():
	message.cancel_behaviour = Message.CancelBehaviour.PICK_DEFAULT
	message.responses.append(Response.new("","",0,TaskData.default_task))
	message.default_response = len(message.responses)-1
	watch_signals(GameManager)
	task_manager._start_task(task_instance)
	task_manager.cancel_task(task_instance)
	assert_eq(len(task_manager.completed_tasks), 1)
	assert_eq(len(task_manager.active_tasks), 0)
	assert_false(task_instance.is_completed)
	assert_false(task_instance in task_manager.completed_tasks)
	assert_signal_emitted(GameManager, "task_finished")


func test_multiple_tasks():
	task_instance.current_progress = 0
	task_instance.task_data.expected_completion_time = 1
	var task_one : TaskInstance = task_instance.duplicate(true)
	var task_two : TaskInstance = task_instance.duplicate(true)
	task_one.task_data.task_id = "TaskOne"
	task_one.message = message
	task_one.relationship_change = 20
	task_two.task_data.task_id = "TaskTwo"
	task_two.message = message
	task_two.relationship_change = -10
	watch_signals(GameManager)
	task_manager._start_task(task_one)
	task_manager._start_task(task_two)
	task_manager._update_tasks(1)
	assert_eq(len(task_manager.completed_tasks), 2, "There should be 2 completed tasks1")
	assert_eq(len(task_manager.active_tasks), 0, "There should be no active tasks")
	assert_eq(message.sender.relationship, 10.0, "Relationship should be 10")
	assert_signal_emit_count(GameManager, "task_finished", 2)


func test_zero_time_task():
	task_instance.task_data.expected_completion_time = 0
	task_manager._start_task(task_instance)
	assert_eq(len(task_manager.completed_tasks), 1)


func test_positive_relationship_applied_zero_time_task():
	task_instance.task_data.expected_completion_time = 0
	task_instance.relationship_change = 10
	var sender = message.sender
	task_manager._start_task(task_instance)
	assert_eq(sender.relationship, 10.0, "Relationship should be 10 after task completion")


func test_negative_relationship_applied_zero_time_task():
	task_instance.task_data.expected_completion_time = 0
	task_instance.relationship_change = -20
	var sender = message.sender
	task_manager._start_task(task_instance)
	assert_eq(sender.relationship, -20.0, "Relationship should be -20 after task completion")
