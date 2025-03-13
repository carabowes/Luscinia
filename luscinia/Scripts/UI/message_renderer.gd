class_name MessageRenderer
extends Control

# Preload the message bubble scene to be used later for rendering message bubbles
var message_bubble = preload("res://Scenes/UI/message_bubble.tscn")

# A flag to determine if the message is from the player or not
var is_player_message : bool = false


# Called when the scene is loaded and ready
func _ready():
	# Connect the resized signal of BubbleContainer to adjust the custom minimum size based on its size
	%BubbleContainer.resized.connect(func(): custom_minimum_size.y = %BubbleContainer.size.y)


# Function to render the message by breaking it into message bubbles
func render_message(text : String):
	# Strip any escape characters (like \n) from the text
	text = text.strip_escapes()

	# Split the text into an array of sentences (split by period)
	var messages : PackedStringArray = text.split(".", false)
	var count = 0

	# Loop through each message in the array of sentences
	for message in messages:
		# Instantiate a new MessageBubble from the preloaded scene
		var message_bubble_instance : MessageBubble = message_bubble.instantiate()

		# Add the new message bubble to the BubbleContainer
		%BubbleContainer.add_child(message_bubble_instance)

		# Set whether the message is from the player or not
		message_bubble_instance.set_player_message(is_player_message)

		# Set the text for the message bubble (adding a period back after splitting)
		message_bubble_instance.set_text(message + ".")

		# Handle joining the message bubble with its neighbor
		if len(messages) == 1:
			# If there is only one message, don't join with any other message
			message_bubble_instance.set_join(false, false)
		elif count == 0:
			# If it's the first message, join at the bottom (as the start of the sequence)
			message_bubble_instance.set_join(false, true)
		elif count == len(messages)-1:
			# If it's the last message, join at the top (as the end of the sequence)
			message_bubble_instance.set_join(true, false)
		else:
			# For all other messages in the middle, join both the top and the bottom
			message_bubble_instance.set_join(true, true)

		# Increment the counter for the next message in the sequence
		count += 1
