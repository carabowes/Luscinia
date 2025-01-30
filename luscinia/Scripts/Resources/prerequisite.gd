class_name Prerequisite
extends Resource

## Array of prerequisite task ids
@export var task_id: Array[int]
## Array of prerequisite events
@export var events: Array[Event.EventType]
## Chance of prerequisite triggering. 1 is 100% likely.
@export_range(0, 1) var chance: float


func _init(task_id: Array[int] = [], chance = 0, events: Array[Event.EventType] = []) -> void:
	self.task_id = task_id
	self.chance = chance
	self.events = events
