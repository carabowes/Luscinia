class_name Sender
extends Resource


# A default sender instance with the name "Anonymous", no image, and a neutral relationship (0)
static var default_sender : Sender = Sender.new("Anonymous", null, 0):
	get():
		return default_sender.duplicate(true)
	set(value):
		return


@export var name: String
## Profile image of the sender (similar to WhatsApp/iMessage profile picture)
@export var image: Texture2D
## Relationship value:
## - Negative values represent poor relations
## - Positive values represent good relations
## - 0 represents neutrality
@export var relationship: float


func _init(name = "", image = null, relationship = 0) -> void:
	self.name = name
	self.image = image
	self.relationship = relationship


# Returns a textual representation of the sender's relationship status
func get_relationship_status() -> String:
	var relationship_word = "Hostile"  # Default to the worst-case scenario

	if relationship > 100:
		relationship_word = "Outstanding"
	elif relationship > 75:
		relationship_word = "Excellent"
	elif relationship > 50:
		relationship_word = "Good"
	elif relationship > 15:
		relationship_word = "Cooperative"
	elif relationship > -15:
		relationship_word = "Neutral"
	elif relationship > -50:
		relationship_word = "Strained"
	elif relationship > -75:
		relationship_word = "Difficult"

	return relationship_word


# Returns a color representing the sender's relationship status using a gradient
func get_relationship_color() -> Color:
	var gradient = Gradient.new()

	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR

	gradient.add_point(0.01, Color.DARK_RED)   # Very poor relationship
	gradient.add_point(0.25, Color.RED)        # Poor relationship
	gradient.add_point(0.5, Color.ORANGE)      # Neutral relationship
	gradient.add_point(0.75, Color.LAWN_GREEN) # Good relationship
	gradient.add_point(0.99, Color.LIME_GREEN) # Excellent relationship

	var value = (clampf(relationship, -95, 95) + 100) / 200.0

	return gradient.sample(value)
