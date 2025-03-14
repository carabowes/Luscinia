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
	GameManager.message_page_open.connect(_message_button_pressed_sprite)
	GameManager.message_page_close.connect(_message_button_sprite)
	GameManager.resource_page_open.connect(_resource_button_pressed_sprite)
	GameManager.resource_page_close.connect(_resource_button_sprite)


func _show_notif_bubble(_message : MessageInstance):
	has_unread_messages = true
	%NewMessageNotif.scale = Vector2.ZERO
	%NewMessageNotif.visible = true
	var bubble_tween = get_tree().create_tween()
	bubble_tween.tween_property(
		%NewMessageNotif, "scale", Vector2.ONE*1.3, 0.25
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	bubble_tween.tween_property(
		%NewMessageNotif, "scale", Vector2.ONE*1, 0.1
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _hide_notif_bubble():
	has_unread_messages = false
	var bubble_tween = get_tree().create_tween()
	bubble_tween.tween_property(
		%NewMessageNotif, "scale", Vector2.ZERO, 0.25
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	bubble_tween.finished.connect(
		func(): %NewMessageNotif.visible = has_unread_messages
	)


func _process(_delta: float):
	if has_unread_messages and not message_page_open:
		%ViewMessageHistoryButton.pivot_offset = %ViewMessageHistoryButton.size/2
		
		# Equation: https://www.desmos.com/calculator/kexu1pkndk
		var shake_intensity = 45
		var shake_time = 2.5 #A larger value means less time
		var time = Time.get_unix_time_from_system()
		var c = max(0, sin(shake_time*time))
		var rot = sin(shake_intensity * time) * c
		%ViewMessageHistoryButton.rotation = rot/10;


func _view_resource_button_pressed():
	GameManager.navbar_resource_button_pressed.emit()


func _skip_time_button_pressed():
	GameManager.next_turn(game_timer)


func _message_button_pressed():
	GameManager.navbar_message_button_pressed.emit()


func _message_button_pressed_sprite():
	message_page_open = true
	%ViewMessageHistoryButton.pivot_offset = %ViewMessageHistoryButton.size/2
	%ViewMessageHistoryButton.rotation = 0;
	%ViewMessageHistoryButton.icon = load("res://Sprites/UI/Icons/MessageButton_selected.png")


func _message_button_sprite():
	message_page_open = false
	%ViewMessageHistoryButton.icon = load("res://Sprites/UI/Icons/MessageButton.png")


func _resource_button_pressed_sprite():
	%ViewResourcesButton.icon = load("res://Sprites/UI/Icons/information_icon_selected.png")


func _resource_button_sprite():
	%ViewResourcesButton.icon = load("res://Sprites/UI/Icons/information_icon.png")
