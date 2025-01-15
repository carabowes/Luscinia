class_name Response
extends Resource

@export var response_text : String
@export var relationship_change : float
@export var task : TaskData

func _init(response_text = "", relationship_change = 0, task = null) -> void:
	self.response_text = response_text
	self.relationship_change = relationship_change
	self.task = task
	
