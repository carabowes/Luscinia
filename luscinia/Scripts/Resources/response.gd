class_name Repsonse
extends Resource

@export var response_text : String
@export var task : TaskData

func _init(response_text = "", task = null) -> void:
	self.response_text = response_text
	self.task = task
	
