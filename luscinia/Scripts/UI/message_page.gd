class_name MessagePage
extends Control

signal back_button_pressed
signal respond_button_pressed(message : Message)

var message  = preload("res://Scenes/UI/message.tscn")


func _ready():
	%BackButton.pressed.connect(func(): back_button_pressed.emit())


# Show a specific message instance on the page
func show_message(message_instance : MessageInstance):
	_clear_old_message()
	_connect_response_button(message_instance)
	if message_instance == null: return
	_set_contact_info(message_instance.message.sender)
	_render_message(message_instance)


# Connect the respond button to a function that will emit the respond signal
func _connect_response_button(message_instance : MessageInstance):
	for connection in %RespondButton.pressed.get_connections():
		%RespondButton.pressed.disconnect(connection["callable"])
	if message_instance == null: return
	%RespondButton.pressed.connect(func(): respond_button_pressed.emit(message_instance))
	%RespondButton.visible = message_instance.message_status != MessageInstance.MessageStatus.REPLIED


# Clear any old message content before rendering a new one
func _clear_old_message():
	for child in %MessagesLayout.get_children():
		child.free()


# Render the message and its response (if available) on the message page
func _render_message(message_instance : MessageInstance):
	var message_object : MessageRenderer = message.instantiate()
	message_object.render_message(message_instance.message.message)
	message_object.is_player_message = false
	%MessagesLayout.add_child(message_object)

	var spacer = Control.new()
	spacer.custom_minimum_size.y = 10
	%MessagesLayout.add_child(spacer)

	# If there is a player response, render it as well
	if message_instance.player_response:
		message_object = message.instantiate()
		message_object.is_player_message = true
		message_object.render_message(message_instance.player_response)
		%MessagesLayout.add_child(message_object)


# Set the contact information (sender profile, name, relationship status)
func _set_contact_info(sender : Sender):
	%ContactProfile.texture = sender.image
	%ContactNameLabel.text = sender.name
	%ContactRelationBar.self_modulate = sender.get_relationship_color()
	%ContactRelationBar.value = sender.relationship
	%ContactRelationLabel.text = sender.get_relationship_status()
