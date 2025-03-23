extends Control

@export var task_widget_renderer : TaskWidgetRenderer
@export var start_task_notif_label: Label
@export var end_task_notif_label: Label

var got_name: bool = false

var got_report: bool = false

func _ready() -> void:
	GameManager.connect("turn_progressed",show_turn_notif)
	#message_board.connect("resource_spent", format_spent_resource_text)
	GameManager.task_started.connect(show_task_start_notif)
	#task_widget_renderer.connect("resource_gained", format_gained_resource_text)
	GameManager.task_finished.connect(show_task_end_notif)


func show_task_end_notif(task: TaskInstance, _cancelled : bool):
	if task != null :
		if task.task_data.resources_gained == {}:
			return
		for resource in task.task_data.resources_gained:
			if(resource == "Funds"):
				var val = int(task.task_data.resources_gained[resource])
				%EndFunds.text = ": +%s" % ResourceManager.format_resource_value(val,2)
			if(resource == "people"):
				%EndPerson.text = ": +%s" % task.task_data.resources_gained[resource]
			if(resource == "supplies"):
				%EndSupplies.text = ": +%s" % task.task_data.resources_gained[resource]
			if(resource == "vehicles"):
				%EndVehicles.text = ": +%s" % task.task_data.resources_gained[resource]
	else:
		return
	var tween1 = get_tree().create_tween()
	tween1.tween_property(%task_end_notification,"position", Vector2(296,-3),0.2)
	await get_tree().create_timer(1).timeout #2s
	var tween2 = get_tree().create_tween()
	tween2.tween_property(%task_end_notification,"position", Vector2(360,-3),0.2)


func show_task_start_notif(task: TaskInstance):
	if task != null :
		if task.task_data.resources_required == {}:
			return
		for resource in task.task_data.resources_required:
			if(resource == "funds"):
				var val = int(task.task_data.resources_required[resource])
				%StartFunds.text = ": -%s" % ResourceManager.format_resource_value(val,2)
			if(resource == "people"):
				%StartPerson.text = ": -%s" % task.task_data.resources_required[resource]
			if(resource == "supplies"):
				%StartSupplies.text = ": -%s" % task.task_data.resources_required[resource]
			if(resource == "vehicles"):
				%StartVehicles.text = ": -%s" % task.task_data.resources_required[resource]
	else:
		return
	var tween1 = get_tree().create_tween()
	tween1.tween_property(%task_start_notification,"position", Vector2(0,-3),0.2)
	await get_tree().create_timer(1).timeout #2s
	var tween2 = get_tree().create_tween()
	tween2.tween_property(%task_start_notification,"position", Vector2(-72,-3),0.2)


func show_turn_notif(_new_turn : int):
	await turn_notif_coroutine()


func turn_notif_coroutine():
	$time_skip_notification.position = Vector2(-136, 3)
	var tween = get_tree().create_tween()
	var target_position : Vector2 = $time_skip_notification.position
	target_position.x = 0
	$time_skip_notification.position = Vector2(-$time_skip_notification.size.x, target_position.y)
	tween.tween_property($time_skip_notification,"position", target_position, 0.2)
	tween.tween_interval(0.5)
	target_position.x = $time_skip_notification.size.x
	tween.tween_property($time_skip_notification,"position", target_position,0.2)
