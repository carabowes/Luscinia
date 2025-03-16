class_name TaskDetails
extends Control

signal return_button_pressed

var current_task_instance : TaskInstance
var resource_manager : ResourceManager
var game_timer : GameTimer:
	set(value):
		game_timer = value
		%TaskProgressBar.game_timer = game_timer
var task_manager : TaskManager


func _ready() -> void:
	%ConfirmEndButton.pressed.connect(_confirm_end_early_button_pressed)
	%CancelEndButton.pressed.connect(_show_task_details)
	%ReturnButton.pressed.connect(func(): return_button_pressed.emit())
	%EndEarlyButton.pressed.connect(_show_end_early_page)
	UIEvent.task_widget_view_details_pressed.connect(_open_task_details)
	GameManager.turn_progressed.connect(_on_time_progressed)


func _open_task_details(task_instance : TaskInstance):
	_set_task_instance(task_instance)
	%TaskCancellation.visible = false;
	_show_task_details()


func _set_task_instance(task_instance : TaskInstance):
	current_task_instance = task_instance
	_set_details_ui(task_instance)
	_set_end_early_ui(task_instance)


func _set_details_ui(task_instance : TaskInstance):
	current_task_instance = task_instance
	%ScrollingBackground.texture = task_instance.task_data.icon
	%TaskProgressBar.value = task_instance.current_progress
	%TaskProgressBar.total_task_time = task_instance.get_total_time()
	%TaskTitle.text = task_instance.task_data.name
	%ResourcesUsed.resources = task_instance.actual_resources
	%OnCompletion.resources = task_instance.task_data.resources_gained
	%SenderIcon.texture = task_instance.sender.image


func _set_end_early_ui(task_instance : TaskInstance):
	var end_early_resources : Dictionary
	var resource_increase_end_early : Dictionary
	var resources : Dictionary = resource_manager.resources
	for resource in resources.keys():
		var current_resource = resources[resource]
		if task_instance.actual_resources.has(resource):
			end_early_resources[resource] = task_instance.actual_resources[resource] + current_resource
			resource_increase_end_early[resource] = task_instance.actual_resources[resource]
		else:
			end_early_resources[resource] = current_resource

	%EndNowResources.resources = end_early_resources
	%EndNowResources.set_increments(resource_increase_end_early)

	var task_data = task_instance.task_data
	var end_on_time_resources: Dictionary
	var resource_increase_on_time: Dictionary
	for resource in resources.keys():
		var current_resource = resources[resource]
		if task_data.resources_gained.has(resource):
			end_on_time_resources[resource] = task_data.resources_gained[resource] + current_resource
			resource_increase_on_time[resource] = task_data.resources_gained[resource]
		else:
			end_on_time_resources[resource] = current_resource

	%FullTimeResources.resources = end_on_time_resources
	%FullTimeResources.set_increments(resource_increase_on_time)


func _show_task_details():
	visible = true;
	%TaskDetails.pivot_offset = %TaskDetails.size
	%TaskDetails.scale.y = 0;
	%TaskDetails.visible = true
	get_tree().create_tween().tween_property(
		%TaskDetails, "scale", Vector2.ONE, 0.25
	).set_trans(Tween.TRANS_QUAD)


func _hide_task_details():
	%TaskDetails.pivot_offset = %TaskDetails.size
	var hide_tween = get_tree().create_tween()
	hide_tween.tween_property(
		%TaskDetails, "scale", Vector2(1, 0), 0.25
	).set_trans(Tween.TRANS_QUAD)
	hide_tween.finished.connect(func(): %TaskDetails.visible = false)


func _show_end_early_page():
	%TaskCancellation.visible = true;
	_hide_task_details()


func _on_time_progressed(_new_turn : int):
	if(current_task_instance != null and visible):
		_set_task_instance(current_task_instance)


func _confirm_end_early_button_pressed():
	%TaskCancellation.visible = false;
	visible = false;
	task_manager.cancel_task(current_task_instance)
