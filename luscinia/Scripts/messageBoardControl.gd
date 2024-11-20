extends VBoxContainer

@onready var gm = $"../../.."

func add_message():
	var message_instance = load("res://Nodes/button.tscn").instantiate()
	message_instance.text = gm.messages[gm.message_amount-1]
	add_child(message_instance)
	move_child(message_instance, 0)
