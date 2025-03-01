extends Node
## The role of the TaskManager is to dispatch and manage tasks through their lifecycle
##
## The TaskManager has 3 main functions, dispatching a task, updating a task, and ending
## a task. The lifecycle of a task should not be handled in any other script, although
## requests can be made to a tasks lifecycle such as using the signal 
## [signal EventBus.task_cancelled]

## The list of tasks that are currently active in the game world
var active_tasks : Array[TaskInstance]
## The list of completed tasks.
## Tasks should only enter this array if the property .is_completed is true.
var completed_tasks: Array[TaskInstance]


func _ready() -> void:
	GlobalTimer.turn_progressed.connect(_update_tasks)
	EventBus.message_responded.connect(_start_task)
	EventBus.task_cancelled.connect(_on_task_cancelled)


func _start_task(response : Response, message_instance : MessageInstance):
	var message : Message = message_instance.message
	var new_task_instance = TaskInstance.new(response.task, 0, 0, 0, response.task.start_location, false, response.task.resources_required, message)
	ResourceManager.queue_relationship_change(new_task_instance.task_data.task_id, response.relationship_change)
	ResourceManager.apply_start_task_resources(response.task.resources_required)
	#If the task has a completion time of 0 just mark it complete already
	if new_task_instance.task_data.expected_completion_time == 0:
		new_task_instance.is_completed = true
		_finish_task(new_task_instance)
	else:
		active_tasks.append(new_task_instance)
		EventBus.task_started.emit(new_task_instance)


func _update_tasks():
	var tasks_to_finish : Array[TaskInstance] = []
	for task in active_tasks:
		task.update_task()
		if task.is_completed:
			tasks_to_finish.append(task)
	for task in tasks_to_finish:
		_finish_task(task)


func _finish_task(task_instance : TaskInstance, cancelled = false):
	if task_instance.is_completed:
		completed_tasks.append(task_instance)
	active_tasks.erase(task_instance)

	var task_data = task_instance.task_data
	var completion_rate = 1
	if task_data.expected_completion_time != 0:
		completion_rate = task_instance.current_progress/task_data.expected_completion_time
	var resources_gained = task_data.resources_gained
	if cancelled:
		# If cancelled gain back the resources used, except funds and supplies
		resources_gained = task_data.resources_required 
		resources_gained["funds"]  = 0
		resources_gained["supplies"] = 0
	_apply_task_end_changes(resources_gained, completion_rate, task_data)

	EventBus.task_finished.emit(task_data)


func _apply_task_end_changes(resources : Dictionary, completion_rate : int, task_data : TaskData):
	ResourceManager.apply_end_task_resources(resources, task_data.resources_required)
	ResourceManager.apply_relationship_change(
		task_data.task_id, task_data.sender, completion_rate
	)


func _on_task_cancelled(task_instance : TaskInstance):
	var cancel_behaviour = task_instance.message.cancel_behaviour
	var message : Message = task_instance.message
	if cancel_behaviour == Message.CancelBehaviour.ACT_AS_COMPLETED:
		task_instance.is_completed
	elif cancel_behaviour == Message.CancelBehaviour.PICK_DEFAULT:
		if message.default_response == -1 or message.default_response >= len(message.responses):
			return
		var default_response : Response = message.responses[message.default_response]
		var new_instance = TaskInstance.new(default_response.task)
		new_instance.is_completed = true
		completed_tasks.append(new_instance)
	_finish_task(task_instance, true)
