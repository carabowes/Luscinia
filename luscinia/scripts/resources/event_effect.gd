class_name EventEffect
extends Resource

@export var event : Event.EventType
@export var effects : Array[Effect]

func _init(event = 0, effects = []) -> void:
	self.event = event
	self.effects = effects
