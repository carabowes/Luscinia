extends Control

@onready var message_list_vbox = $ScrollContainer/MessageListVBox
@onready var message_board = get_node_or_null("/root/MessageBoard")  
var resource_entry_path = "res://Nodes/UI/resource_entry.tscn" 

func _ready() -> void:
	if not message_board:
		print("Error: MessageBoard node not found!")
		return
	populate_message_history()

func _on_return_button_pressed() -> void:
	$"." .visible = false

func populate_message_history() -> void:
	var history = message_board.message_history if message_board else {}
	
	for child in message_list_vbox.get_children():
		child.queue_free()
	
	for sender_id in history.keys():
		var sender_messages = history[sender_id]
		var last_message = sender_messages[-1]
		
		var contact_info = load(resource_entry_path).instantiate()  
		populate_contact_info(contact_info, sender_id, last_message)
		message_list_vbox.add_child(contact_info)
		
		contact_info.set_meta("sender_id", sender_id)
		contact_info.connect("gui_input", Callable(self, "_on_sender_selected"))

func populate_contact_info(contact_info, sender_id, last_message) -> void:
	var sender = message_board.get_sender_by_id(sender_id) if message_board else null
	if sender:
		contact_info.get_node("%ContactProfile").texture = sender.image
		contact_info.get_node("%ContactNameLabel").text = sender.name
		contact_info.get_node("%ContactRelationLabel").text = sender.get_relationship_status()
		contact_info.get_node("%ContactRelationBar").value = clamp(sender.relationship, -85, 95)
		contact_info.get_node("%ContactRelationBar").self_modulate = sender.get_relationship_color()
	contact_info.get_node("%ContactLastMessageLabel").text = last_message["message"]

func _on_sender_selected(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var sender_id = event.target.get_meta("sender_id")
		var sender = message_board.get_sender_by_id(sender_id) if message_board else null
		if not sender:
			print("Error: Sender not found!")
			return
		
		var sender_messages = message_board.message_history[sender_id]
		get_tree().change_scene("res://Scenes/message_board.tscn")
		var message_board_node = get_tree().root.get_node("main/message_board")
		message_board_node.load_messages_for_sender(sender, sender_messages)
