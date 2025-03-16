class_name Scenario
extends Resource

@export var scenario_name : String

@export var messages : Array[Message]
@export var time_step : int:
	set(value):
		time_step = max(1, value)
## The in game time that the scenrio starts at, stored in 24 hour time e.g 16 = 4pm
@export var starting_hour : int:
	set(value):
		starting_hour = clamp(value, 0, 23)
@export var resources : Dictionary = {
	"funds": 100,
	"people": 100,
	"vehicles": 80,
	"supplies": 100000
}
@export var available_resources : Dictionary = {
	"people": 100,
	"vehicles": 80
}

func _init(
	scenario_name : String = "Scenario",
	messages : Array[Message] = [],
	time_step: int = 60,
	starting_hour : int = 0,
	resources : Dictionary = resources,
	available_resources : Dictionary = available_resources
) -> void:
	self.scenario_name = scenario_name
	self.messages = messages
	self.time_step = time_step
	self.starting_hour = starting_hour
	self.resources = resources
	self.available_resources = available_resources
