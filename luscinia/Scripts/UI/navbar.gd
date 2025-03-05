extends Control

func _ready() -> void:
	%ViewResourcesButton.pressed.connect(_view_resource_button_pressed)
	%SkipTimeButton.pressed.connect(_skip_time_button_pressed)
	%ViewMessageHistoryButton.pressed.connect(_message_button_pressed)
	MessageManager.message_sent.connect(func(message): %NewMessageNotif.visible = true)
	EventBus.all_messages_read.connect(func(): %NewMessageNotif.visible = false)
	EventBus.message_page_open.connect(_message_button_pressed_sprite)
	EventBus.message_page_close.connect(_message_button_sprite)
	EventBus.resource_page_open.connect(_resource_button_pressed_sprite)
	EventBus.resource_page_close.connect(_resource_button_sprite)


func _view_resource_button_pressed():
	EventBus.navbar_resource_button_pressed.emit()


func _skip_time_button_pressed():
	GlobalTimer.next_turn(GlobalTimer.time_step) #skip a turn


func _message_button_pressed():
	EventBus.navbar_message_button_pressed.emit()


func _message_button_pressed_sprite():
	%ViewMessageHistoryButton.icon = load("res://Sprites/UI/Icons/MessageButton_selected.png")


func _message_button_sprite():
	%ViewMessageHistoryButton.icon = load("res://Sprites/UI/Icons/MessageButton.png")


func _resource_button_pressed_sprite():
	%ViewResourcesButton.icon = load("res://Sprites/UI/Icons/information_icon_selected.png")


func _resource_button_sprite():
	%ViewResourcesButton.icon = load("res://Sprites/UI/Icons/information_icon.png")
