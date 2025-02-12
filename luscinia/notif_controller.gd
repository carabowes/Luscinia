extends Control

@export var message_board : MessageBoard
@export var task_widget_renderer : TaskWidgetRenderer
@export var start_task_notif_label: Label
@export var end_task_notif_label: Label

var task_start_notif_text = ""
var got_name: bool = false

var task_end_notif_text = ""
var got_report: bool = false

func _ready() -> void:
	GlobalTimer.connect("turn_progressed",show_turn_notif)
	message_board.connect("resource_spent", format_spent_resource_text)
	message_board.connect("response_picked",show_task_start_notif)
	task_widget_renderer.connect("resource_gained", format_gained_resource_text)
	task_widget_renderer.connect("task_ended", show_task_end_notif)

func format_gained_resource_text(resource: String, amt: int):
	if(!got_report):
		task_end_notif_text += "Task %s has ended! \n Resources gained:\n" % name
		got_report = true
	task_end_notif_text += "%s +%d\n" % [resource, amt]


func show_task_end_notif():
	end_task_notif_label.text = task_end_notif_text
	task_end_notif_text = ""
	got_report = false
	var tween1 = get_tree().create_tween()
	tween1.tween_property(%task_end_notification,"position", Vector2(0,205),0.2)
	await get_tree().create_timer(2).timeout #2s
	var tween2 = get_tree().create_tween()
	tween2.tween_property(%task_end_notification,"position", Vector2(-360,205),0.2)


func format_spent_resource_text(name:String, resource: String, amt: int):
	if(!got_name):
		task_start_notif_text += "Task %s has begun! \n Resources taken:\n" % name
		got_name = true
	task_start_notif_text += "%s -%d\n" % [resource, amt]


func show_task_start_notif():
	start_task_notif_label.text = task_start_notif_text
	task_start_notif_text = ""
	got_name = false
	var tween1 = get_tree().create_tween()
	#og -360, 205
	#center 0, 205
	tween1.tween_property(%task_start_notification,"position", Vector2(0,205),0.2)
	await get_tree().create_timer(2).timeout #2s
	var tween2 = get_tree().create_tween()
	tween2.tween_property(%task_start_notification,"position", Vector2(-360,205),0.2)


func show_turn_notif(time_skipped: int):
	await turn_notif_coroutine(time_skipped)


func turn_notif_coroutine(time_skipped: int):
	var tween1 = get_tree().create_tween()
	#og -360, 205
	#center 0, 205
	tween1.tween_property(%time_skip_notification,"position", Vector2(0,205),0.2)
	await get_tree().create_timer(0.5).timeout #2s
	var tween2 = get_tree().create_tween()
	tween2.tween_property(%time_skip_notification,"position", Vector2(-360,205),0.2)
