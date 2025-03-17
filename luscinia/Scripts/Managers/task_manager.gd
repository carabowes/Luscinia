class_name TaskManager
extends Node
## The role of the TaskManager is to dispatch and manage tasks through their lifecycle
##
## The TaskManager has 3 main functions, dispatching a task, updating a task, and ending
## a task. The lifecycle of a task should not be handled in any other script

## The list of tasks that are currently active in the game world
var active_tasks : Array[TaskInstance]
## The list of completed tasks.
## Tasks should only enter this array if the property .is_completed is true.
var completed_tasks: Array[TaskInstance]


func _init() -> void:
	GameManager.turn_progressed.connect(_update_tasks)
	GameManager.message_responded.connect(_on_message_responded)


func _on_message_responded(response : Response, message_instance : MessageInstance):
	var message : Message = message_instance.message
	var new_task_instance = TaskInstance.new(response.task, message, response.relationship_change)
	_start_task(new_task_instance)


func _start_task(task_instance : TaskInstance):
	active_tasks.append(task_instance)
	GameManager.task_started.emit(task_instance)
	if task_instance.task_data.expected_completion_time == 0:
		task_instance.is_completed = true
		_complete_task(task_instance)


func _update_tasks(_new_turn : int):
	var tasks_to_finish : Array[TaskInstance] = []
	for task in active_tasks:
		task.update_task()
		if task.is_completed:
			tasks_to_finish.append(task)
	for task in tasks_to_finish:
		_complete_task(task)


func _complete_task(task_instance : TaskInstance, cancelled : bool = false):
	if task_instance.is_completed:
		completed_tasks.append(task_instance)
	active_tasks.erase(task_instance)

	var task_data : TaskData = task_instance.task_data

	GameManager.task_finished.emit(task_instance, cancelled)


func cancel_task(task_instance : TaskInstance):
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
	_complete_task(task_instance, true)
