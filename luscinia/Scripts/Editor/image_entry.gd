class_name ImageEntry
extends Resource

@export var image_name : String
@export var image : Texture

func _init(image_name : String = "", image : Texture = null):
	self.image_name = image_name
	self.image = image
