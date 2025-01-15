extends Control
class_name TaskDetails

signal task_cancelled(task_instance : TaskInstance);

var current_task_instance : TaskInstance


func _ready() -> void:
	%EndEarlyButton.connect("button_down", _end_early_button_pressed)

func show_details(task_instance : TaskInstance) -> void:
	current_task_instance = task_instance
	var progress_bar : TimeProgressBar = $Background/ScrollContainer/MarginContainer/Elements/ProgressBar
	progress_bar.value = task_instance.current_progress
	progress_bar.total_task_time = task_instance.task_data.expected_completion_time + task_instance.extra_time
	$Background/ScrollContainer/MarginContainer/Elements/TaskTitle.text = task_instance.task_data.name
	$Background/ScrollContainer/MarginContainer/Elements/ResourcesUsed.resources = task_instance.task_data.resources_required
	$Background/ScrollContainer/MarginContainer/Elements/OnCompletion.resources = task_instance.task_data.resources_gained
	var resources_used : TaskResources = $Background/ScrollContainer/MarginContainer/Elements/ResourcesUsed
	resources_used.resources = task_instance.task_data.resources_required
	visible = true
	pass


func hide_details() -> void:
	visible = false


func _end_early_button_pressed():
	hide_details()
	task_cancelled.emit(current_task_instance)
	
