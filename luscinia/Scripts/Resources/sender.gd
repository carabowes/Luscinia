class_name Sender
extends Resource

## Name of the sender
@export var name : String 
## Image of senders profile, similar to WhatsApp/iMessage profile picture
@export var image : Texture2D
## Negative numbers represent poor relations, positive numbers represent positive relations, 0 is neutral
@export var relationship : float

func _init(name = "", image = null, relationship = 0) -> void:
	self.name = name
	self.image = image
	self.relationship = relationship


func get_relationship_status() -> String:
	if relationship > 100:
		return "Outstanding"
	elif relationship > 75:
		return "Excellent"
	elif relationship > 50:
		return "Good"
	elif relationship > 15:
		return "Cooperative"
	elif relationship > -15:
		return "Neutral"
	elif relationship > -50:
		return "Strained"
	elif relationship > -75:
		return "Difficult"
	else:
		return "Hostile"


func get_relationship_color() -> Color:
	var gradient = Gradient.new()
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
	
	gradient.add_point(0.01, Color.DARK_RED)
	gradient.add_point(0.25, Color.RED)
	gradient.add_point(0.5, Color.ORANGE)
	gradient.add_point(0.75, Color.LAWN_GREEN)
	gradient.add_point(0.99, Color.LIME_GREEN)
	
	var value = (clampf(relationship, -95, 95) + 100)/200.0
	print("Grad val: ", value, " - ", relationship)
	return gradient.sample(value)
