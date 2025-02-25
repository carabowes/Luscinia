extends Control

@export var message_history : Control

func _ready() -> void:
	
	%ViewResourcesButton.pressed.connect(_view_resource_button_pressed)
	%SkipTimeButton.pressed.connect(_skip_time_button_pressed)
	%ViewMessageHistoryButton.pressed.connect(_message_button_pressed)


func _view_resource_button_pressed():
	EventBus.navbar_resource_button_pressed.emit()


func _skip_time_button_pressed():
	GlobalTimer.next_turn(GlobalTimer.time_step) #skip a turn


func _message_button_pressed():
	if(message_history == null):
		print("Message Manager not assigned")
		return
	message_history.visible = !message_history.visible
