extends Control

func _ready() -> void:
	%ViewResourcesButton.pressed.connect(_view_resource_button_pressed)
	%SkipTimeButton.pressed.connect(_skip_time_button_pressed)
	%ViewMessageHistoryButton.pressed.connect(_message_button_pressed)
	MessageManager.message_sent.connect(func(message): %NewMessageNotif.visible = true)
	EventBus.all_messages_read.connect(func(): %NewMessageNotif.visible = false)


func _view_resource_button_pressed():
	EventBus.navbar_resource_button_pressed.emit()


func _skip_time_button_pressed():
	GlobalTimer.next_turn(GlobalTimer.time_step) #skip a turn


func _message_button_pressed():
	EventBus.navbar_message_button_pressed.emit()
