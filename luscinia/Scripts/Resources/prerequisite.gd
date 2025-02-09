class_name Prerequisite
extends Resource

## Array of prerequisite task ids
@export var task_id : Array[String]
## Array of prerequisite events
@export var events : Array[Event.EventType]
## Chance of prerequisite triggering. 1 is 100% likely.
@export_range(0,1)  var chance : float
## Minimum turn for the prerequisite to be valid
@export var turns: int = 0

func _init(task_id : Array[String] = [], chance: float = 0, events : Array[Event.EventType]= []) -> void:
	self.task_id = task_id
	self.chance = chance
	self.events = events
	
	
func validate(task_instances: Array[TaskInstance], occurred_events: Array[Event.EventType], current_turn: int, rng: RandomNumberGenerator) -> bool:
	for required_task_id in task_id:
		var is_task_completed = false
		for task_instance in task_instances:
			if str(task_instance.task_data.task_id) == str(required_task_id) and task_instance.is_completed:
				is_task_completed = true
				break
		if not is_task_completed:
			return false
	for event in events:
		if event not in occurred_events:
			return false
	if current_turn < turns:
		return false
	if rng.randf() > chance:
		return false
		
	return true
