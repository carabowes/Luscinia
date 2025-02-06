class_name ReceivedMessage
extends Control

enum MessageStatus {
	UNREAD = 0,
	READ = 1,
	REPLIED = 2
}

@export_enum("SideBadge:0", "ProfileBadge:1") var unread_badge_location : int
@export var answer_now_color: Color
@export var time_remaining_color: Color

var current_message_status : MessageStatus 
var message_info : Message
static var default_message : Message = Message.new("Message failed to load. No message was passed in on initialisation!", [], null, [], [], 3, false)


func _draw():
	_render_badge_location()
	_render_message_status()
	_render_message_info()


func _render_message_info():
	%MessagePreviewLabel.text = message_info.message
	%ContactNameLabel.text = message_info.sender.name
	%ContactImage.texture = message_info.sender.image
	%TimeRemainingLabel.self_modulate = time_remaining_color
	if current_message_status != MessageStatus.REPLIED:
		if message_info.turns_to_answer == -1:
			%TimeRemainingLabel.self_modulate.a = 0
		elif message_info.turns_to_answer == 1:
			%TimeRemainingLabel.text = "ANSWER NOW!"
			%TimeRemainingLabel.self_modulate = answer_now_color
		else:
			%TimeRemainingLabel.text = str(message_info.turns_to_answer * GlobalTimer.time_step/60) + " HOURS"


func _render_message_status():
	if current_message_status == MessageStatus.UNREAD:
		%UnreadBadge.self_modulate.a = 1
		%ContactUnreadBadge.self_modulate.a = 1
	elif current_message_status == MessageStatus.READ:
		%UnreadBadge.self_modulate.a = 0
		%ContactUnreadBadge.self_modulate.a = 0
	elif current_message_status == MessageStatus.REPLIED:
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


static func new_instance(message_info : Message = default_message) -> ReceivedMessage:
	var message_scene : PackedScene = load("res://Scenes/UI/received_message.tscn")
	var message_object : ReceivedMessage = message_scene.instantiate()
	message_object.message_info = message_info
	message_object.current_message_status = MessageStatus.UNREAD
	return message_object
