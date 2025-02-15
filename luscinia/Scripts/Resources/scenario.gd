class_name Scenario
extends Resource

## The name of the scenario
var scenario_name : String
## The messages that are relevant to a particular scenario, we only need to store
## the messages as everything else is stored in the messages
var messages : Array[Message]
## The amount of time in minutes that the game clock moves forward on a new turn
var time_step : int
## The resources that the player starts of with
var resources : Dictionary = {
	"funds": 100,
	"people": 100,
	"vehicles": 80,
	"supplies": 100000
}
## Resources that have an upper limit e.g people and vehicles
var available_resources : Dictionary = {
	"people": 100,
	"vehicles": 80
}

func _init(
	scenario_name : String = "Scenario", 
	messages : Array[Message] = [], 
	time_step: int = 60,
	resources : Dictionary = resources,
	available_resources : Dictionary = available_resources
) -> void:
	self.scenario_name = scenario_name
	self.messages = messages
	self.time_step = time_step
	self.resources = resources
	self.available_resources = available_resources
