class_name MessagePage
extends Control

var message  = preload("res://Scenes/UI/message.tscn")

func _ready():
	EventBus.message_selected.connect(show_message)
	%BackButton.pressed.connect(func(): EventBus.message_viewer_page_back_button_pressed.emit())


func show_message(message_instance : MessageInstance):
	_clear_old_message()
	_set_contact_info(message_instance.message.sender)
	_render_message(message_instance)
	%RespondButton.visible = message_instance.message_status != MessageInstance.MessageStatus.REPLIED
	for connection in %RespondButton.pressed.get_connections():
		%RespondButton.pressed.disconnect(connection["callable"])
	%RespondButton.pressed.connect(func(): EventBus.message_respond_button_pressed.emit(message_instance.message))


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
