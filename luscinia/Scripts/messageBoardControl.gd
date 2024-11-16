extends VBoxContainer


	
func add_message():
	var message_instance = load("res://button.tscn").instantiate()
	add_child(message_instance)
	move_child(message_instance, 0)
	
