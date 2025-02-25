extends Node

var active_tasks : Array[TaskInstance]
var completed_tasks: Array[TaskInstance]

func _ready() -> void:
	GlobalTimer.turn_progressed.connect(_update_tasks)
	EventBus.task_finished.connect(_finish_task)
	EventBus.message_responded.connect(_start_task)


func _start_task(response : Response, message_instance : MessageInstance):
	var message : Message = message_instance.message
	var new_task_instance = TaskInstance.new(response.task, 0, 0, 0, response.task.start_location, false, response.task.resources_required, message)
	ResourceManager.queue_relationship_change(new_task_instance.task_data.task_id, response.relationship_change)
	ResourceManager.apply_start_task_resources(response.task.resources_required)
	#If the task has a completion time of 0 just mark it complete already
	if new_task_instance.task_data.expected_completion_time == 0:
		_finish_task(new_task_instance)
	else:
		active_tasks.append(new_task_instance)
	EventBus.task_started.emit(new_task_instance)


func _update_tasks():
	for task in active_tasks:
		task.update_task()
		if task.is_completed:
			EventBus.task_finished.emit(task, false)


func _finish_task(task : TaskInstance, cancelled = false):
	var resources_gained =  task.task_data.resources_gained
	if cancelled:
		resources_gained = task.task_data.resources_required #This is meant to be required
		resources_gained["funds"]  = 0
		resources_gained["supplies"] = 0
	ResourceManager.apply_end_task_resources(resources_gained, task.task_data.resources_required)
	active_tasks.erase(task)
	if task.task_data.expected_completion_time == 0:
		ResourceManager.apply_relationship_change(task.task_data.task_id, task.sender, 1) #Hardcode 1 for current progress to avoid divide by 0 error
	else:
		ResourceManager.apply_relationship_change(task.task_data.task_id, task.sender, task.current_progress/task.task_data.expected_completion_time)
