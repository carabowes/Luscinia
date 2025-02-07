class_name MessageRenderer
extends Control

var message_bubble = preload("res://Scenes/UI/message_bubble.tscn")
var is_player_message : bool = false

func _ready():
	%BubbleContainer.resized.connect(func(): custom_minimum_size.y = %BubbleContainer.size.y)


func render_message(text : String):
	var messages : PackedStringArray = text.split(".", false)
	var count = 0
	for message in messages:
		var message_bubble_instance : MessageBubble = message_bubble.instantiate()
		%BubbleContainer.add_child(message_bubble_instance)
		message_bubble_instance.set_player_message(is_player_message)
		message_bubble_instance.set_text(message + ".")
		if len(messages) == 1:
			message_bubble_instance.set_join(false, false)
		elif count == 0 :
			message_bubble_instance.set_join(false, true)
		elif count == len(messages)-1:
			message_bubble_instance.set_join(true, false)
		else:
			message_bubble_instance.set_join(true, true)
		
		count += 1
