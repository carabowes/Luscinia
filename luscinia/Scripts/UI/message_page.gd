extends Control

var message  = preload("res://Scenes/UI/message.tscn")

func _ready():
	var msg = MessageInstance.new()
	show_message(msg)


func show_message(message_instance : MessageInstance):
	_clear_old_message()
	_set_contact_info(message_instance.message.sender)
	_render_message(message_instance)
	

func _clear_old_message():
	for child in %MessagesLayout.get_children():
		child.free()


func _render_message(message_instance : MessageInstance):
	var message_object : MessageRenderer = message.instantiate()
	message_object.render_message(message_instance.message.message)
	message_object.is_player_message = false
	%MessagesLayout.add_child(message_object)
	
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 10
	%MessagesLayout.add_child(spacer)
	
	if message_instance.player_response:
		message_object = message.instantiate()
		message_object.is_player_message = true
		message_object.render_message(message_instance.player_response)
		%MessagesLayout.add_child(message_object)


func _set_contact_info(sender : Sender):
	%ContactProfile.texture = sender.image
	%ContactNameLabel.text = sender.name
	%ContactRelationBar.self_modulate = sender.get_relationship_color()
	%ContactRelationBar.value = sender.relationship
	%ContactRelationLabel.text = sender.get_relationship_status()
