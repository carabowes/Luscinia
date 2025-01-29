class_name TaskDetails
extends Control

signal task_cancelled(task_instance: TaskInstance)

var current_task_instance: TaskInstance

func _ready() -> void:
	%EndEarlyButton.connect("button_down", _end_early_button_pressed)
	%CancelEndButton.connect("button_down", func(): $TaskCancelConfirmationPage.visible = false)
	%ConfirmEndButton.connect("button_down", _confirm_end_early_button_pressed)


func show_details(task_instance: TaskInstance) -> void:
	current_task_instance = task_instance
	%TaskProgressBar.value = task_instance.current_progress
	%TaskProgressBar.total_task_time = task_instance.get_total_time()
	%TaskTitle.text = task_instance.task_data.name
	%ResourcesUsed.resources = task_instance.task_data.resources_required
	%OnCompletion.resources = task_instance.task_data.resources_gained
	visible = true


func hide_details() -> void:
	visible = false


func _end_early_button_pressed():
	%EndEarlyProgressBar.value = current_task_instance.current_progress
	%EndEarlyProgressBar.total_task_time = current_task_instance.get_total_time()

	var end_early_resources: Dictionary
	var resource_increase_end_early: Dictionary
	for resource in ResourceManager.resources.keys():
		var current_resource = (
			ResourceManager.resources[resource]
			if resource == "funds"
			else ResourceManager.available_resources[resource]
		)
		if (
			resource in current_task_instance.task_data.resources_required
			and (resource == "people" or resource == "vehicles")
		):
			end_early_resources[resource] = (
				current_task_instance.task_data.resources_required[resource] + current_resource
			)
			resource_increase_end_early[resource] = (
				current_task_instance.task_data.resources_required[resource]
			)
		else:
			end_early_resources[resource] = current_resource

	%EndEarlyResources.resources = end_early_resources
	%EndEarlyResources.set_increments(resource_increase_end_early)

	var end_on_time_resources: Dictionary
	var resource_increase_on_time: Dictionary
	for resource in ResourceManager.resources.keys():
		var current_resource = (
			ResourceManager.resources[resource]
			if resource == "funds"
			else ResourceManager.available_resources[resource]
		)
		if resource in current_task_instance.task_data.resources_gained:
			end_on_time_resources[resource] = (
				current_task_instance.task_data.resources_gained[resource] + current_resource
			)
			resource_increase_on_time[resource] = (
				current_task_instance.task_data.resources_gained[resource]
			)
		else:
			end_on_time_resources[resource] = current_resource

	%FullTimeResources.resources = end_on_time_resources
	%FullTimeResources.set_increments(resource_increase_on_time)
	$TaskCancelConfirmationPage.visible = true


func _confirm_end_early_button_pressed():
	$TaskCancelConfirmationPage.visible = false
	task_cancelled.emit(current_task_instance)
	visible = false
