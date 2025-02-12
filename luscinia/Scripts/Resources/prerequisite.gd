class_name Prerequisite
extends Resource

## Array of prerequisite task ids
@export var task_id : Array[String]
## Array of prerequisite events
@export var events : Array[Event.EventType]
## Chance of prerequisite triggering. 1 is 100% likely.
@export_range(0,1)  var chance : float
## Minimum turn for the prerequisite to be valid
@export var min_turn: int = 0
## Maximim turn for the prerequisite to be valid (i.e. no maximum)
@export var max_turn: int = -1

func _init(task_id : Array[String] = [], chance: float = 0, events : Array[Event.EventType]= [], min_turn: int = 0, max_turn: int = 0) -> void:
	self.task_id = task_id
	self.chance = chance
	self.events = events
	self.min_turn = min_turn
	self.max_turn = max_turn
