class_name MapTasks
extends Control

@export var widget_size : float
@export var zoom_level_medium_detail : float

var task_widgets : Array[TaskWidget]
var task_widget_prefab = "res://Scenes/task_widget.tscn"


func _ready() -> void:
	EventBus.task_started.connect(func(task : TaskInstance): create_widget(task))
	GlobalTimer.turn_progressed.connect(func(time : int): render_widgets())
	$MapView.zoom_changed.connect(render_widgets)


func create_widget(task_instance : TaskInstance):
	var task_widget_instance : TaskWidget = load(task_widget_prefab).instantiate()
	task_widget_instance.task_info = task_instance
	task_widget_instance.position = task_instance.task_data.start_location

	$MapView/MapTexture.add_child(task_widget_instance)
	task_widgets.append(task_widget_instance)

	task_widget_instance.widget_selected.connect(update_selected_widget)
	EventBus.task_finished.connect(
		func(task: TaskInstance, cancelled: bool): 
			if task == task_instance: 
				delete_widget(task_widget_instance)
	)

	render_widgets()


func delete_widget(task_widget : TaskWidget):
	task_widget.queue_free()
	task_widgets.erase(task_widget)


func set_level_of_details(affect_high_detail_widgets = false):
	var current_scale = $MapView.current_scale
	for widget in task_widgets:
		if widget.current_level_of_detail == widget.LevelOfDetail.HIGH and affect_high_detail_widgets:
			widget.set_level_of_detail(widget.LevelOfDetail.MEDIUM if current_scale >= zoom_level_medium_detail else widget.LevelOfDetail.LOW)
		elif widget.current_level_of_detail != widget.LevelOfDetail.HIGH:
			widget.set_level_of_detail(widget.LevelOfDetail.MEDIUM if current_scale >= zoom_level_medium_detail else widget.LevelOfDetail.LOW)


func update_selected_widget(selected_widget : TaskWidget):
	var current_scale = $MapView.current_scale
	for widget in task_widgets:
		if widget != selected_widget:
			widget.set_level_of_detail(widget.LevelOfDetail.MEDIUM if current_scale >= zoom_level_medium_detail else widget.LevelOfDetail.LOW)
	$MapView/MapTexture.move_child(selected_widget, $MapView/MapTexture.get_child_count()-1)


func render_widgets():
	for widget in task_widgets:
		var current_scale = $MapView.current_scale
		widget.scale = Vector2.ONE * widget_size / current_scale
		set_level_of_details()
		widget.queue_redraw()


func _gui_input(event: InputEvent) -> void:
	#if the task widget has been clicked off, then make sure theres no high level detail widget
	if event.is_action_pressed("interact"):
		set_level_of_details(true)
