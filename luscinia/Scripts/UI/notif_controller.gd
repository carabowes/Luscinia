extends Control

@export var task_widget_renderer : TaskWidgetRenderer
@export var start_task_notif_label: Label
@export var end_task_notif_label: Label

var showing: bool = false

var task_start_notif_text = ""
var got_name: bool = false

var task_end_notif_text = ""
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
		task_end_notif_text += "Task %s has begun! \n Resources taken:\n" % task.task_data.name
		for resource in task.task_data.resources_gained:
			task_end_notif_text += "%s +%d\n" % [resource, task.task_data.resources_gained[resource]]
	else:
		return
	$time_skip_notification.visible = false
	showing = true
	end_task_notif_label.text = task_end_notif_text
	task_end_notif_text = ""
	got_report = false
	var tween1 = get_tree().create_tween()
	tween1.tween_property(%task_end_notification,"position", Vector2(0,205),0.2)
	await get_tree().create_timer(1.2).timeout #2s
	var tween2 = get_tree().create_tween()
	tween2.tween_property(%task_end_notification,"position", Vector2(-360,205),0.2)
	await get_tree().create_timer(0.25).timeout #2s
	$time_skip_notification.visible = true
	showing = false


func show_task_start_notif(task: TaskInstance):
	if task != null :
		if task.task_data.resources_required == {}:
			return
		task_start_notif_text += "Task %s has begun! \n Resources taken:\n" % task.task_data.name
		for resource in task.task_data.resources_required:
			task_start_notif_text += "%s -%d\n" % [resource, task.task_data.resources_required[resource]]
	else:
		return
	start_task_notif_label.text = task_start_notif_text
	task_start_notif_text = ""
	var tween1 = get_tree().create_tween()
	#og -360, 205
	#center 0, 205
	tween1.tween_property(%task_start_notification,"position", Vector2(0,205),0.2)
	await get_tree().create_timer(2).timeout #2s
	var tween2 = get_tree().create_tween()
	tween2.tween_property(%task_start_notification,"position", Vector2(-360,205),0.2)


func show_turn_notif(_new_turn : int):
	if(!showing):
		showing = true
		await turn_notif_coroutine()


func turn_notif_coroutine():
	var tween1 = get_tree().create_tween()
	#og -360, 205
	#center 0, 205
	tween1.tween_property(%time_skip_notification,"position", Vector2(0,205),0.2)
	await get_tree().create_timer(0.5).timeout #2s
	var tween2 = get_tree().create_tween()
	tween2.tween_property(%time_skip_notification,"position", Vector2(-360,205),0.2)
	await get_tree().create_timer(0.2).timeout #2s
	showing = false
