extends Control

var has_unread_messages : bool = false
var message_page_open : bool = false
var game_timer : GameTimer


func _ready() -> void:
	%ViewResourcesButton.pressed.connect(_view_resource_button_pressed)
	%SkipTimeButton.pressed.connect(_skip_time_button_pressed)
	%ViewMessageHistoryButton.pressed.connect(_message_button_pressed)
	GameManager.message_sent.connect(_show_notif_bubble)
	GameManager.all_messages_read.connect(_hide_notif_bubble)
	UIEvent.message_page_open.connect(_message_button_pressed_sprite)
	UIEvent.message_page_close.connect(_message_button_sprite)
	UIEvent.resource_page_open.connect(_resource_button_pressed_sprite)
	UIEvent.resource_page_close.connect(_resource_button_sprite)


# Shows the notification bubble when a new message is received
func _show_notif_bubble(_message : MessageInstance):
	has_unread_messages = true
	%NewMessageNotif.scale = Vector2.ZERO
	%NewMessageNotif.visible = true
	var bubble_tween = get_tree().create_tween()
	bubble_tween.tween_property(
		%NewMessageNotif, "scale", Vector2.ONE * 1.3, 0.25
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	bubble_tween.tween_property(
		%NewMessageNotif, "scale", Vector2.ONE * 1, 0.1
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# Hides the notification bubble once all messages are read
func _hide_notif_bubble():
	has_unread_messages = false
	var bubble_tween = get_tree().create_tween()
	bubble_tween.tween_property(
		%NewMessageNotif, "scale", Vector2.ZERO, 0.25
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	bubble_tween.finished.connect(
		func(): %NewMessageNotif.visible = has_unread_messages
	)


# Called every frame to apply shake effect on the message history button
# if there are unread messages
func _process(_delta: float):
	if has_unread_messages and not message_page_open:
		%ViewMessageHistoryButton.pivot_offset = %ViewMessageHistoryButton.size/2
		# Equation: https://www.desmos.com/calculator/kexu1pkndk
		var shake_intensity = 45
		var shake_time = 2.5
		var time = Time.get_unix_time_from_system()
		var c = max(0, sin(shake_time * time))
		var rot = sin(shake_intensity * time) * c
		%ViewMessageHistoryButton.rotation = rot / 10


# Button press for viewing resources
func _view_resource_button_pressed():
	UIEvent.navbar_resource_button_pressed.emit()


# Button press for skipping time (next turn)
func _skip_time_button_pressed():
	GameManager.next_turn(game_timer)
	%SkipTimeButton.icon = load("res://Sprites/UI/Icons/ProceedButtonSelected.png")
	%SkipTimeButton.pivot_offset = %SkipTimeButton.size/2
	var tween = get_tree().create_tween()
	tween.tween_property(%SkipTimeButton, "scale", Vector2(1.1, 0.95), 0.1)
	tween.tween_property(%SkipTimeButton, "scale", Vector2.ONE, 0.1)
	tween.tween_callback(func(): %SkipTimeButton.icon = load("res://Sprites/UI/Icons/ProceedButton.png"))


# Button press for viewing messages
func _message_button_pressed():
	UIEvent.navbar_message_button_pressed.emit()


# Update UI when the message page is opened (update button icon and reset shake effect)
func _message_button_pressed_sprite():
	message_page_open = true  # Mark the message page as open
	%ViewMessageHistoryButton.pivot_offset = %ViewMessageHistoryButton.size/2
	var tween = get_tree().create_tween()
	tween.tween_property(%ViewMessageHistoryButton, "scale", Vector2(1.1, 0.95), 0.1)
	tween.tween_property(%ViewMessageHistoryButton, "scale", Vector2.ONE, 0.1)
	%ViewMessageHistoryButton.pivot_offset = %ViewMessageHistoryButton.size / 2  # Reset pivot
	%ViewMessageHistoryButton.rotation = 0  # Reset the rotation to 0 (remove shake effect)
	%ViewMessageHistoryButton.icon = load("res://Sprites/UI/Icons/MessageButtonSelected.png")


# Update UI when the message page is closed (reset button icon)
func _message_button_sprite():
	message_page_open = false  # Mark the message page as closed
	%ViewMessageHistoryButton.icon = load("res://Sprites/UI/Icons/MessageButton.png")


# Update UI when the resource page is opened (highlight resource button)
func _resource_button_pressed_sprite():
	%ViewResourcesButton.pivot_offset = %ViewResourcesButton.size/2
	var tween = get_tree().create_tween()
	tween.tween_property(%ViewResourcesButton, "scale", Vector2(1.1, 0.95), 0.1)
	tween.tween_property(%ViewResourcesButton, "scale", Vector2.ONE, 0.1)
	%ViewResourcesButton.icon = load("res://Sprites/UI/Icons/ResourcesButtonPressed.png")


# Update UI when the resource page is closed (reset resource button icon)
func _resource_button_sprite():
	%ViewResourcesButton.icon = load("res://Sprites/UI/Icons/ResourcesButton.png")
