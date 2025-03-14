# Defines a class called Prerequisite, extending the Resource class
class_name Prerequisite
extends Resource

@export var task_id: Array[String]

@export var events: Array[Event.EventType]

@export_range(0, 1) var chance: float

@export var min_turn: int = 0

@export var max_turn: int = -1


func _init(task_id: Array[String] = [], chance: float = 0, events: Array[Event.EventType] = [],
	min_turn: int = 0, max_turn: int = -1) -> void:
	self.task_id = task_id
	self.chance = clamp(chance, 0, 1)
	self.events = events
	self.min_turn = min_turn
	self.max_turn = max_turn


# Function to validate if the prerequisite conditions are met
func validate(task_instances: Array[TaskInstance], occurred_events: Array[Event.EventType],
	current_turn: int, rng: RandomNumberGenerator) -> bool:

	# Check if all required tasks have been completed
	for required_task_id in task_id:
		var is_task_completed = false

		for task_instance in task_instances:
			var task_id_matches := str(task_instance.task_data.task_id) == str(required_task_id)
			var task_is_completed := task_instance.is_completed

			if task_id_matches and task_is_completed:
				is_task_completed = true
				break  # Exit loop early if task is found and completed

		if not is_task_completed:
			return false

	# Check if all required events have occurred
	for event in events:
		if event not in occurred_events:
			return false

	# Check if the current turn is within the valid range
	if current_turn < min_turn:
		return false
	if max_turn != -1 and current_turn > max_turn:
		return false

	# Use random chance to determine if the prerequisite is triggered
	if rng.randf() > chance:
		return false

	return true
