class_name StaffEntry
extends Resource

@export var name : String
@export var image : Texture2D

func _init(name : String, image : Texture2D):
	self.name = name
	self.image = image
