class_name Scenario
extends Resource

## The name of the scenario
@export var scenario_name : String
## The messages that are relevant to a particular scenario, we only need to store
## the messages as everything else is stored in the messages
@export var messages : Array[Message]
## The amount of time in minutes that the game clock moves forward on a new turn
@export var time_step : int:
	set(value):
		time_step = max(1, value)
## The in game time that the scenrio starts at, stored in 24 hour time e.g 16 = 4pm
## Min value of 0, Max value of 23
@export var starting_hour : int:
	set(value):
		starting_hour = clamp(value, 0, 23)
## The resources that the player starts of with
@export var resources : Dictionary = {
	"funds": 100,
	"people": 100,
	"vehicles": 80,
	"supplies": 100000
}
## Resources that have an upper limit e.g people and vehicles
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
