class_name TaskInstance
extends Resource


@export var task_data : TaskData
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
var sender : Sender:
	get:
		if message:
			return message.sender
		return Sender.default_sender


func _init(
	task_data : TaskData = TaskData.default_task, message : Message = Message.default_message
):
	self.task_data = task_data
	self.current_progress = 0
	self.extra_time = 0
	self.current_location = task_data.start_location
	self.is_completed = false
	self.actual_resources = task_data.resources_required.duplicate()
	if(self.actual_resources.has("funds")):
		self.actual_resources["funds"] = 0
	self.message = message


func get_total_time():
	return task_data.expected_completion_time + extra_time


func get_remaining_time():
	return get_total_time() - current_progress


func get_completion_rate() -> float:
	if task_data.expected_completion_time == 0:
		return 1.0
	return float(current_progress)/float(get_total_time())


func update_task():
	current_progress += 1
	if(actual_resources.has("supplies")):
		var supplies = task_data.resources_required["supplies"]
		var completion_rate = get_completion_rate()
		var new_supplies = int(lerp(supplies, 0, completion_rate))
		actual_resources["supplies"] = min(new_supplies, supplies)

	if current_progress >= get_total_time():
		is_completed = true
