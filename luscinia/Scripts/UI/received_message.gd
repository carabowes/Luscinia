class_name ReceivedMessage
extends Control

@export_enum("SideBadge:0", "ProfileBadge:1") var unread_badge_location : int
@export var answer_now_color: Color
@export var time_remaining_color: Color

var message_info : MessageInstance
static var default_message : MessageInstance = MessageInstance.new()


func _draw():
	_render_badge_location()
	_render_message_status()
	_render_message_info()


func _gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		#Go to messages screen
		pass


func _render_message_info():
	%MessagePreviewLabel.text = message_info.message.message
	%ContactNameLabel.text = message_info.message.sender.name
	%ContactImage.texture = message_info.message.sender.image
	%TimeRemainingLabel.self_modulate = time_remaining_color
	if message_info.message_status != MessageInstance.MessageStatus.REPLIED:
		if message_info.turns_remaining == -1:
			%TimeRemainingLabel.self_modulate.a = 0
		elif message_info.turns_remaining == 1:
			%TimeRemainingLabel.text = "ANSWER NOW!"
			%TimeRemainingLabel.self_modulate = answer_now_color
		else:
			%TimeRemainingLabel.text = str(message_info.turns_remaining * GlobalTimer.time_step/60) + " HOURS"


func _render_message_status():
	if message_info.message_status == MessageInstance.MessageStatus.UNREAD:
		%UnreadBadge.self_modulate.a = 1
		%ContactUnreadBadge.self_modulate.a = 1
	elif message_info.message_status == MessageInstance.MessageStatus.READ:
		%UnreadBadge.self_modulate.a = 0
		%ContactUnreadBadge.self_modulate.a = 0
	elif message_info.message_status == MessageInstance.MessageStatus.REPLIED:
		%UnreadBadge.self_modulate.a = 0
		%ContactUnreadBadge.self_modulate.a = 0
		%Layout.modulate = Color.DIM_GRAY
		%Layout.modulate.a = 0.5
		%TimeRemainingLabel.text = "REPLIED"


func _render_badge_location():
	if unread_badge_location == 0: #Side Badge
		%UnreadBadge.visible =  true
		%ContactUnreadBadge.visible = false
	else: #Profile badge
		%UnreadBadge.visible = false
		%ContactUnreadBadge.visible = true


static func new_instance(message_info : MessageInstance = default_message) -> ReceivedMessage:
	var message_scene : PackedScene = load("res://Scenes/UI/received_message.tscn")
	var message_object : ReceivedMessage = message_scene.instantiate()
	message_object.message_info = message_info
	return message_object
