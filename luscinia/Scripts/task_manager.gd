extends Node

var active_tasks : Array[TaskInstance]
var completed_tasks: Array[TaskInstance]

func _ready() -> void:
	GlobalTimer.turn_progressed.connect(_update_tasks)
	EventBus.task_finished.connect(_finish_task)
	EventBus.message_responded.connect(_start_task)


func _start_task(response : Response, message : Message):
	var new_task_instance = TaskInstance.new(response.task, 0, 0, 0, response.task.start_location, false, response.task.resources_required, message)
	ResourceManager.queue_relationship_change(new_task_instance.task_data.task_id, response.relationship_change)
	#Remove resources
	for resource in response.task.resources_required.keys():
		if resource == "funds":
			ResourceManager.remove_resources(resource, response.task.resources_required[resource])
		else:
			ResourceManager.remove_available_resources(resource, response.task.resources_required[resource])
	#If the task has a completion time of 0 just mark it complete already
	if new_task_instance.task_data.expected_completion_time == 0:
		_finish_task(new_task_instance)
	else:
		active_tasks.append(new_task_instance)
	EventBus.task_started.emit(new_task_instance)


func _update_tasks(time_progressed : int):
	for task in active_tasks:
		task.update_task(time_progressed)
		if task.is_completed:
			EventBus.task_finished.emit(task, false)


func _finish_task(task : TaskInstance, cancelled = false):
	for resource in task.task_data.resources_gained.keys():
		if not cancelled:
			if resource != "funds":
				ResourceManager.add_available_resources(resource, task.task_data.resources_gained[resource])
			else:
				ResourceManager.add_resources(resource, task.task_data.resources_gained[resource])
		elif resource != "funds" and resource != "supplies":
			ResourceManager.add_available_resources(resource, task.task_data.resources_gained[resource])
	if not cancelled:
		completed_tasks.append(task)
	active_tasks.erase(task)
	ResourceManager.apply_relationship_change(task.task_data.task_id, task.sender, task.current_progress)
