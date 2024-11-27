class_name TaskDetails
extends Control


func show_details(task_instance : TaskInstance) -> void:
	var progress_bar : TimeProgressBar = $Background/ScrollContainer/MarginContainer/Elements/ProgressBar
	progress_bar.value = task_instance.current_progress
	progress_bar.total_task_time = task_instance.task_data.expected_completion_time + task_instance.extra_time
	$Background/ScrollContainer/MarginContainer/Elements/TaskTitle.text = task_instance.task_data.name
	$Background/ScrollContainer/MarginContainer/Elements/ResourcesUsed.resources = task_instance.task_data.resources_required
	$Background/ScrollContainer/MarginContainer/Elements/OnCompletion.resources = task_instance.task_data.resources_gained
	visible = true
	pass


func hide_details() -> void:
	visible = false
