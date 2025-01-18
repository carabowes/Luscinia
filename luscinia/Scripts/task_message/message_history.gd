extends Control

@onready var message_list_vbox = $ScrollContainer/MessageListVBox
@onready var message_board = get_node("/root/main/message_board")

func _ready():
	if not message_board:
		print("MessageBoard node not found!")
		return
	populate_message_history()
	
	
func _on_return_button_pressed() -> void:
	var main_parent = $"."
	main_parent.visible = false
	
	
func populate_message_history():
	var history = message_board.message_history  # Get the stored message history

# Loop through each sender in the history
	for sender_id in history.keys():
		var sender_messages = history[sender_id]
		var last_message = sender_messages[-1]  # Get the most recent message for the sender

		# Create a new ContactInfo instance for this sender
		var contact_info = preload("res://Nodes/task_message_buttons/messenger_screen.tscn").instance()

		# Populate the ContactInfo node with sender details
		populate_contact_info(contact_info, sender_id, last_message)

		# Add ContactInfo to the VBoxContainer
		message_list_vbox.add_child(contact_info)

		# Connect a signal to handle clicks on the sender item
		contact_info.connect("gui_input", self, "_on_sender_selected", [sender_id])
		
		
func populate_contact_info(contact_info, sender_id, last_message):
	var sender = message_board.get_sender_by_id(sender_id)

	if sender:
		contact_info.get_node("%ContactProfile").texture = sender.image
		contact_info.get_node("%ContactNameLabel").text = sender.name
		contact_info.get_node("%ContactRelationLabel").text = sender.get_relationship_status()
		contact_info.get_node("%ContactRelationBar").value = clamp(sender.relationship, -85, 95)
		contact_info.get_node("%ContactRelationBar").self_modulate = sender.get_relationship_color()

	# Set the last message preview text
	contact_info.get_node("%ContactLastMessageLabel").text = last_message["message"]
	
	
func _on_sender_selected(event, sender_id):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var sender = message_board.get_sender_by_id(sender_id)  # Get sender object
		if not sender:
			print("Sender not found!")
			return
		var sender_messages = message_board.message_history[sender_id]  # Get message history
		get_tree().change_scene("res://scenes/message_board.tscn")
		# Load the sender's messages in the MessageBoard
		var message_board_node = get_tree().root.get_node("main/message_board")
		message_board_node.load_messages_for_sender(sender, sender_messages)
