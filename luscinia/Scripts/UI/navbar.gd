extends Control

@export var resource_page : Control
func _ready() -> void:
	%ViewResourcesButton.pressed.connect(_view_resource_button_pressed)
	%SkipTimeButton.pressed.connect(_skip_time_button_pressed)
	%ViewMessageHistoryButton.pressed.connect(_message_button_pressed)


func _view_resource_button_pressed():
	if(resource_page == null):
		print("Resource Page not assigned!")
		return
	resource_page.visible = !resource_page.visible


func _skip_time_button_pressed():
	GlobalTimer.next_turn(GlobalTimer.time_step) #skip a turn


func _message_button_pressed():
	EventBus.navbar_message_button_pressed.emit()
