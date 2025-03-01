class_name TaskDetails
extends Control

signal return_button_pressed

func _ready() -> void:
	%CancelEndButton.pressed.connect(func(): $TaskCancelConfirmationPage.visible = false)
	EventBus.task_widget_view_details_pressed.connect(show_details)
	%ReturnButton.pressed.connect(func(): return_button_pressed.emit())


func show_details(task_instance : TaskInstance) -> void:
	%TaskProgressBar.value = task_instance.current_progress
	%TaskProgressBar.total_task_time = task_instance.get_total_time()
	%TaskTitle.text = task_instance.task_data.name
	%ResourcesUsed.resources = task_instance.task_data.resources_required
	%OnCompletion.resources = task_instance.task_data.resources_gained
	visible = true

	for connection in %ConfirmEndButton.pressed.get_connections():#Remove previous connections
		%ConfirmEndButton.pressed.disconnect(connection.callable)
	%ConfirmEndButton.pressed.connect(func(): _confirm_end_early_button_pressed(task_instance))

	for connection in %EndEarlyButton.pressed.get_connections(): #Remove previous connections
		%EndEarlyButton.pressed.disconnect(connection.callable)
	%EndEarlyButton.pressed.connect(func(): _end_early_button_pressed(task_instance))


func hide_details() -> void:
	visible = false


func _end_early_button_pressed(task_instance : TaskInstance):
	%EndEarlyProgressBar.value = task_instance.current_progress
	%EndEarlyProgressBar.total_task_time = task_instance.get_total_time()
	
	var end_early_resources : Dictionary
	var resource_increase_end_early : Dictionary
	for resource in ResourceManager.resources.keys():
		var current_resource = ResourceManager.resources[resource] 
		if resource in task_instance.task_data.resources_required and (resource == "people" or resource == "vehicles"):
			end_early_resources[resource] = task_instance.task_data.resources_required[resource] + current_resource
			resource_increase_end_early[resource] = task_instance.task_data.resources_required[resource]
		else:
			end_early_resources[resource] = current_resource

	%EndEarlyResources.resources = end_early_resources
	%EndEarlyResources.set_increments(resource_increase_end_early)

	var end_on_time_resources: Dictionary
	var resource_increase_on_time: Dictionary
	for resource in ResourceManager.resources.keys():
		var current_resource = ResourceManager.resources[resource] 
		if resource in task_instance.task_data.resources_gained:
			end_on_time_resources[resource] = task_instance.task_data.resources_gained[resource] + current_resource
			resource_increase_on_time[resource] = task_instance.task_data.resources_gained[resource]
		else:
			end_on_time_resources[resource] = current_resource

	%FullTimeResources.resources = end_on_time_resources
	%FullTimeResources.set_increments(resource_increase_on_time)
	$TaskCancelConfirmationPage.visible = true


func _confirm_end_early_button_pressed(task_instance : TaskInstance):
	$TaskCancelConfirmationPage.visible = false
	visible = false
	EventBus.task_cancelled.emit(task_instance)
