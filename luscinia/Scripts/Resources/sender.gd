class_name Sender
extends Resource

## Name of the sender
@export var name : String 
## Image of senders profile, similar to WhatsApp/iMessage profile picture
@export var image : Image
## Negative numbers represent poor relations, positive numbers represent positive relations
@export var relationship : float

func _init(name = "", image = null, relationship = 0) -> void:
	self.name = name
	self.image = image
	self.relationship = relationship
