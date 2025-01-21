extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_return_button_pressed() -> void:
	var main_parent = $"."
	main_parent.visible = false

#extends Control
#
#@onready var message_list_vbox = $ScrollContainer/MessageListVBox
#@onready var message_board = $"../../message_board"
#
#func _ready():
	#if not message_board:
		#print("MessageBoard node not found!")
		#return
	#populate_message_history()
	#
	#
#func _on_return_button_pressed() -> void:
	#var main_parent = $"."
	#main_parent.visible = false
	#
	#
#func populate_message_history():
	#var history = message_board.message_history  # Get the stored message history
#
	#for sender_id in history.keys():
		#var sender_messages = history[sender_id]
		#var last_message = sender_messages[-1]  # Get the most recent message for the sender
		#var contact_info = preload("res://Nodes/task_message_buttons/messenger_screen.tscn").instance()
		#populate_contact_info(contact_info, sender_id, last_message)
		#message_list_vbox.add_child(contact_info)
		#contact_info.connect("gui_input", self, "_on_sender_selected", [sender_id])
		#
		#
#func populate_contact_info(contact_info, sender_id, last_message):
	#var sender = message_board.get_sender_by_id(sender_id)
#
	#if sender:
		#contact_info.get_node("%ContactProfile").texture = sender.image
		#contact_info.get_node("%ContactNameLabel").text = sender.name
		#contact_info.get_node("%ContactRelationLabel").text = sender.get_relationship_status()
		#contact_info.get_node("%ContactRelationBar").value = clamp(sender.relationship, -85, 95)
		#contact_info.get_node("%ContactRelationBar").self_modulate = sender.get_relationship_color()
	#contact_info.get_node("%ContactLastMessageLabel").text = last_message["message"]
	#
	#
#func _on_sender_selected(event, sender_id):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#var sender = message_board.get_sender_by_id(sender_id)  # Get sender object
		#if not sender:
			#print("Sender not found!")
			#return
		#var sender_messages = message_board.message_history[sender_id]  # Get message history
		#get_tree().change_scene("res://scenes/message_board.tscn")
		#var message_board_node = get_tree().root.get_node("main/message_board")
		#message_board_node.load_messages_for_sender(sender, sender_messages)
##
##extends Control
##
##@onready var message_list = $VBoxContainer  # Path to VBoxContainer for message history
##
##func _ready():
	##populate_message_history()
##
##func populate_message_history():
	##var message_manager = get_node("/root/messenger")  # Adjust path if necessary
	##if not is_instance_valid(message_manager):
		##print("Error: Message Manager not found or valid!")
		##return
		##
	##for child in message_list.get_children():
		##child.queue_free()
	##for entry in message_manager.message_history:
		##var history_item = create_history_item(entry)
		##message_list.add_child(history_item)
##
##func create_history_item(entry):
	##var label = Label.new()
	##label.text = "[" + entry.sender + "]: " + entry.message + " (Response: " + entry.response + ")"
	##return label
