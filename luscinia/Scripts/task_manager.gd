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
	EventBus.message_responded.connect(_on_message_responded)
	EventBus.task_cancelled.connect(_on_task_cancelled)


func _on_message_responded(response : Response, message_instance : MessageInstance):
	var message : Message = message_instance.message
	var new_task_instance = TaskInstance.new(response.task, message)
	_start_task(new_task_instance, response.relationship_change)


func _start_task(task_instance : TaskInstance, relationship_change : float):
	ResourceManager.queue_relationship_change(task_instance.task_data.task_id, relationship_change)
	ResourceManager.apply_start_task_resources(task_instance.task_data.resources_required)
	#If the task has a completion time of 0 just mark it complete already
	active_tasks.append(task_instance)
	EventBus.task_started.emit(task_instance)
	if task_instance.task_data.expected_completion_time == 0:
		task_instance.is_completed = true
		_finish_task(task_instance)


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

	var task_data : TaskData = task_instance.task_data
	var resources_gained = task_data.resources_gained
	if cancelled:
		# If cancelled gain back the current resources of the task
		resources_gained = task_instance.actual_resources
	_apply_task_end_changes(resources_gained, task_instance)

	EventBus.task_finished.emit(task_instance)


func _apply_task_end_changes(
	resources : Dictionary, task_instance : TaskInstance
):
	var task_data : TaskData = task_instance.task_data
	ResourceManager.apply_end_task_resources(resources, task_data.resources_required)
	ResourceManager.apply_relationship_change(
		task_data.task_id, task_instance.sender, task_instance.get_completion_rate()
	)


func _on_task_cancelled(task_instance : TaskInstance):
	var cancel_behaviour = task_instance.message.cancel_behaviour
	var message : Message = task_instance.message
	if cancel_behaviour == Message.CancelBehaviour.ACT_AS_COMPLETED:
		task_instance.is_completed = true
	elif cancel_behaviour == Message.CancelBehaviour.PICK_DEFAULT:
		if message.default_response == -1 or message.default_response >= len(message.responses):
			return
		var default_response : Response = message.responses[message.default_response]
		var new_instance = TaskInstance.new(default_response.task)
		new_instance.is_completed = true
		completed_tasks.append(new_instance)
	_finish_task(task_instance, true)
