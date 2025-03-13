extends Control

# Boolean flags to track unread messages and if the message page is open
var has_unread_messages : bool = false
var message_page_open : bool = false


# Called when the scene is ready, initialises various button connections
func _ready() -> void:
	%ViewResourcesButton.pressed.connect(_view_resource_button_pressed)
	%SkipTimeButton.pressed.connect(_skip_time_button_pressed)
	%ViewMessageHistoryButton.pressed.connect(_message_button_pressed)
	MessageManager.message_sent.connect(_show_notif_bubble)
	EventBus.all_messages_read.connect(_hide_notif_bubble)
	EventBus.message_page_open.connect(_message_button_pressed_sprite)
	EventBus.message_page_close.connect(_message_button_sprite)
	EventBus.resource_page_open.connect(_resource_button_pressed_sprite)
	EventBus.resource_page_close.connect(_resource_button_sprite)


# Shows the notification bubble when a new message is received
func _show_notif_bubble(_message : MessageInstance):
	has_unread_messages = true  # Mark that there are unread messages
	%NewMessageNotif.scale = Vector2.ZERO  # Start with a scale of zero (invisible)
	%NewMessageNotif.visible = true  # Make the notification visible
	var bubble_tween = get_tree().create_tween()  # Create a tween to animate the notification bubble
	# Animate the scale of the notification bubble to grow (bounce effect)
	bubble_tween.tween_property(
		%NewMessageNotif, "scale", Vector2.ONE * 1.3, 0.25
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Animate the scale back to its original size
	bubble_tween.tween_property(
		%NewMessageNotif, "scale", Vector2.ONE * 1, 0.1
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# Hides the notification bubble once all messages are read
func _hide_notif_bubble():
	has_unread_messages = false  # Mark there are no unread messages
	var bubble_tween = get_tree().create_tween()  # Create a tween to animate the notification bubble
	# Animate the notification bubble to shrink to zero (disappear)
	bubble_tween.tween_property(
		%NewMessageNotif, "scale", Vector2.ZERO, 0.25
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	# Once the tween is finished, set the visibility of the notification bubble
	# to match the has_unread_messages state
	bubble_tween.finished.connect(
		func(): %NewMessageNotif.visible = has_unread_messages
	)


# Called every frame to apply shake effect on the message history button
# if there are unread messages
func _process(_delta: float):
	if has_unread_messages and not message_page_open:
		%ViewMessageHistoryButton.pivot_offset = %ViewMessageHistoryButton.size / 2

		# Applying a shake effect to the message history button
		var shake_intensity = 45  # Intensity of the shake
		var shake_time = 2.5  # Time period for shake (longer time means slower shake)
		var time = Time.get_unix_time_from_system()  # Get the current time
		var c = max(0, sin(shake_time * time))  # Create a smooth shake pattern
		var rot = sin(shake_intensity * time) * c  # Calculate the rotation for the shake effect
		%ViewMessageHistoryButton.rotation = rot / 10  # Apply rotation to the button


# Button press for viewing resources
func _view_resource_button_pressed():
	EventBus.navbar_resource_button_pressed.emit() # Emit an event for the navbar resource button


# Button press for skipping time (next turn)
func _skip_time_button_pressed():
	GlobalTimer.next_turn(GlobalTimer.time_step)  # Skip to the next turn in the global timer


# Button press for viewing messages
func _message_button_pressed():
	EventBus.navbar_message_button_pressed.emit()  # Emit an event for the navbar message button press


# Update UI when the message page is opened (update button icon and reset shake effect)
func _message_button_pressed_sprite():
	message_page_open = true  # Mark the message page as open
	%ViewMessageHistoryButton.pivot_offset = %ViewMessageHistoryButton.size / 2  # Reset pivot
	%ViewMessageHistoryButton.rotation = 0  # Reset the rotation to 0 (remove shake effect)
	%ViewMessageHistoryButton.icon = load("res://Sprites/UI/Icons/MessageButton_selected.png")


# Update UI when the message page is closed (reset button icon)
func _message_button_sprite():
	message_page_open = false  # Mark the message page as closed
	%ViewMessageHistoryButton.icon = load("res://Sprites/UI/Icons/MessageButton.png")


# Update UI when the resource page is opened (highlight resource button)
func _resource_button_pressed_sprite():
	%ViewResourcesButton.icon = load("res://Sprites/UI/Icons/information_icon_selected.png")


# Update UI when the resource page is closed (reset resource button icon)
func _resource_button_sprite():
	%ViewResourcesButton.icon = load("res://Sprites/UI/Icons/information_icon.png")
