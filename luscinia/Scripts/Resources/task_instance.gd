class_name TaskInstance
extends Resource

#This resource will only be created at runtime

@export var task_data : TaskData
## Measured in turns so if task has been going for 4 turns, current progress is 4
@export var current_progress : int 
@export var extra_time : int
@export var current_location : Vector2
@export var is_completed : bool
@export var actual_resources : Dictionary
@export var message : Message:
	set(value):
		if not value is Message:
			push_error("Invalid type assigned to 'message'. Expected 'Message', got '%s'." % value)
		else:
			message = value
## sender property to allow shorthand of task_instance.sender rather than task_instance.message.sender
var sender : Sender: 
	get:
		if message:
			return message.sender
		return Sender.default_sender


func _init(task_data : TaskData = null, message : Message = null) -> void:
	self.task_data = task_data
	self.current_progress = 0
	self.extra_time = 0
	self.current_location = task_data.start_location
	self.is_completed = false
	self.actual_resources = task_data.resources_required
	self.message = message


func get_total_time():
	return task_data.expected_completion_time + extra_time


func get_remaining_time():
	return get_total_time() - current_progress


func update_task():
	current_progress += 1
	if current_progress >= get_total_time():
		is_completed = true
