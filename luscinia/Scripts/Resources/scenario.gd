class_name Scenario
extends Resource

@export var messages : Array[Message]

func _init(messages : Array[Message] = []):
	self.messages = messages
