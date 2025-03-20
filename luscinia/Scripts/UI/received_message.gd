class_name ReceivedMessage
extends Control

signal message_clicked(message_instace : MessageInstance)

static var default_message : MessageInstance = MessageInstance.new()

# Determines where the unread badge appears: 0 = SideBadge, 1 = ProfileBadge
@export_enum("SideBadge:0", "ProfileBadge:1") var unread_badge_location : int
@export var answer_now_color: Color
@export var time_remaining_color: Color

var message_info : MessageInstance
var game_timer : GameTimer


func _ready() -> void:
	# Redraw the UI whenever the turn progresses
	GameManager.turn_progressed.connect(func(_new_turn : int): queue_redraw())


# Handles drawing custom UI elements
func _draw():
	_render_badge_location()
	_render_message_status()
	_render_message_info()


# Handles input events (e.g., clicking on the message)
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		message_clicked.emit(message_info) # Emits a signal when the message is clicked


# Updates message text, sender name, image, and time remaining
func _render_message_info():
	%MessagePreviewLabel.text = message_info.message.message
	%ContactNameLabel.text = message_info.message.sender.name
	%ContactImage.texture = message_info.message.sender.image
	%TimeRemainingLabel.self_modulate = time_remaining_color

	# Update time remaining label based on message status
	if message_info.message_status != MessageInstance.MessageStatus.REPLIED:
		if message_info.turns_remaining == -1:
			%TimeRemainingLabel.self_modulate.a = 0 # Hide time label if expired
		elif message_info.turns_remaining == 1:
			%TimeRemainingLabel.text = "ANSWER NOW!" # Urgent message
			%TimeRemainingLabel.self_modulate = answer_now_color
		else:
			%TimeRemainingLabel.text = GameTimer.turns_to_time_string(
				game_timer,
				message_info.turns_remaining,
				"HOUR",
				"MIN",
				"S",
				true,
				true
			)


# Updates UI based on the message's read/unread/replied status
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
		# Dim the layout for replied messages
		%Layout.modulate = Color.DIM_GRAY
		%Layout.modulate.a = 0.5
		%TimeRemainingLabel.text = "REPLIED"


# Controls where the unread badge appears based on the setting
func _render_badge_location():
	if unread_badge_location == 0: # Side Badge
		%UnreadBadge.visible = true
		%ContactUnreadBadge.visible = false
	else: # Profile Badge
		%UnreadBadge.visible = false
		%ContactUnreadBadge.visible = true


# Creates a new instance of ReceivedMessage with the given message info
static func new_instance(
	message_info : MessageInstance = default_message, game_timer : GameTimer = null
) -> ReceivedMessage:
	var message_scene : PackedScene = load("res://Scenes/UI/received_message.tscn")
	var message_object : ReceivedMessage = message_scene.instantiate()
	message_object.message_info = message_info
	message_object.game_timer = game_timer
	return message_object
