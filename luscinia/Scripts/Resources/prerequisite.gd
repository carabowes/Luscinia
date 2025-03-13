# Defines a class called Prerequisite, extending the Resource class
class_name Prerequisite
extends Resource

## Array of prerequisite task IDs that must be completed
@export var task_id: Array[String]

## Array of prerequisite events that must have occurred
@export var events: Array[Event.EventType]

## Chance of the prerequisite triggering (1.0 = 100%, 0.5 = 50%, etc.)
@export_range(0, 1) var chance: float

## The minimum turn at which the prerequisite becomes valid
@export var min_turn: int = 0

## The maximum turn at which the prerequisite is valid (-1 means no maximum)
@export var max_turn: int = -1


# Constructor (_init) to initialise a Prerequisite instance with default values
func _init(task_id: Array[String] = [], chance: float = 0, events: Array[Event.EventType] = [],
	min_turn: int = 0, max_turn: int = -1) -> void:
	# Assign the provided values or defaults
	self.task_id = task_id
	self.chance = clamp(chance, 0, 1)  # Ensures chance is always between 0 and 1
	self.events = events
	self.min_turn = min_turn
	self.max_turn = max_turn


# Function to validate if the prerequisite conditions are met
func validate(task_instances: Array[TaskInstance], occurred_events: Array[Event.EventType],
	current_turn: int, rng: RandomNumberGenerator) -> bool:

	# Check if all required tasks have been completed
	for required_task_id in task_id:
		var is_task_completed = false  # Flag to track task completion

		for task_instance in task_instances:
			var task_id_matches := str(task_instance.task_data.task_id) == str(required_task_id)
			var task_is_completed := task_instance.is_completed

			if task_id_matches and task_is_completed:
				is_task_completed = true
				break  # Exit loop early if task is found and completed

		# If any required task is not completed, return false immediately
		if not is_task_completed:
			return false

	# Check if all required events have occurred
	for event in events:
		if event not in occurred_events:
			return false  # If a required event is missing, validation fails

	# Check if the current turn is within the valid range
	if current_turn < min_turn:
		return false  # Prerequisite is not valid before min_turn
	if max_turn != -1 and current_turn > max_turn:
		return false  # Prerequisite expires after max_turn (if max_turn is set)

	# Use random chance to determine if the prerequisite is triggered
	if rng.randf() > chance:
		return false  # If the RNG roll fails, the prerequisite does not trigger

	# If all conditions are met, return true
	return true
