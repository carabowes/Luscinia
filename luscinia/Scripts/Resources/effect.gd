class_name Effect
extends Resource

enum EffectType { RESOURCE, TIME, FAILURE }

## The type of effect to take place: Resource, Time, Failure
## There is an order of precednece with the events. Resource > Time > Failure.
## This allows all events to take place. If failure took place first,
## there would be no resource loss.
@export var effect_type: EffectType
## Only applicable if effect type is Resource. Indicates what resource is getting reduced.
@export var resource_type: int
## Indicates how much the resource/time is going to change.
@export var change_amount: int
## Chance of event taking place. 1 is 100% likely.
@export_range(0, 1) var chance: float


func _init(effect_type = 0, resource_type = 0, change_amount = 0, chance = 0) -> void:
	self.effect_type = effect_type
	self.resource_type = resource_type
	self.change_amount = change_amount
	self.chance = chance
