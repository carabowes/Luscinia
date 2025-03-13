class_name Sender
extends Resource


# A default sender instance with the name "Anonymous", no image, and a neutral relationship (0)
static var default_sender : Sender = Sender.new("Anonymous", null, 0):
	get():
		# Return a deep copy of the default sender to prevent modifications to the original instance
		return default_sender.duplicate(true)
	set(value):
		# Prevent setting a new value for default_sender
		return


## Name of the sender
@export var name: String
## Profile image of the sender (similar to WhatsApp/iMessage profile picture)
@export var image: Texture2D
## Relationship value:
## - Negative values represent poor relations
## - Positive values represent good relations
## - 0 represents neutrality
@export var relationship: float


# Constructor function to initialise a sender with a name, image, and relationship value
func _init(name = "", image = null, relationship = 0) -> void:
	self.name = name
	self.image = image
	self.relationship = relationship


# Returns a textual representation of the sender's relationship status
func get_relationship_status() -> String:
	var relationship_word = "Hostile"  # Default to the worst-case scenario

	# Determine relationship status based on numerical value
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

	# Use linear interpolation for smooth color transition
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR

	# Define relationship color scale:
	# - Dark Red (very bad) → Red → Orange → Green → Lime Green (very good)
	gradient.add_point(0.01, Color.DARK_RED)   # Very poor relationship
	gradient.add_point(0.25, Color.RED)        # Poor relationship
	gradient.add_point(0.5, Color.ORANGE)      # Neutral relationship
	gradient.add_point(0.75, Color.LAWN_GREEN) # Good relationship
	gradient.add_point(0.99, Color.LIME_GREEN) # Excellent relationship

	# Normalise relationship value between 0 and 1 for gradient sampling
	var value = (clampf(relationship, -95, 95) + 100) / 200.0

	return gradient.sample(value)  # Return the corresponding color
