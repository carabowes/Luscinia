extends Resource
class_name TaskInstance

#This resource will only be created at runtime

enum CurrentStatus {IDLING, WORKING, TRAVELLING}

@export var task_data : TaskData
@export var current_status : CurrentStatus
#measured in hours of task time, so if task has been gonig for 4 hours, current progress is 4
@export var current_progress : int 
@export var extra_time : int
@export var current_location : Vector2
@export var is_completed : bool
@export var actual_resources : Dictionary
@export var message : Message
var sender : Sender: #sender property to allow shorthand of task_instance.sender rather than task_instance.message.sender
	get:
		if message:
			return message.sender
		return Message.default_sender

func _init(task_data = null, current_status = 0, current_progress = 0, extra_time = 0, current_location = Vector2.ZERO, is_completed = false, actual_resources = {}, message = null) -> void:
	self.task_data = task_data
	self.current_status = current_status
	self.current_progress = current_progress
	self.extra_time = extra_time
	self.current_location = current_location
	self.is_completed = is_completed
	self.actual_resources = actual_resources
	self.message = message


func get_total_time():
	return task_data.expected_completion_time + extra_time


func get_remaining_time():
	return get_total_time() - current_progress


func update_task(time_progressed : int):
	current_progress += time_progressed/60
	if current_progress >= get_total_time():
		is_completed = true
