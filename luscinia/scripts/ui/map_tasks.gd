extends Node

# This will be removed and changed with some sort of reference to the singleton task manager once available.
@export var task_instance : Array[TaskInstance]
@export var widget_size : float
@export var zoom_level_medium_detail : float

var task_widgets : Array[TaskWidget]
var task_widget_prefab = "res://scenes/task_widget.tscn"


func _ready() -> void:
	generate_widgets()
	$MapView.zoom_changed.connect(render_widgets)


func generate_widgets():
	for task in task_instance:
		var task_widget_instance : TaskWidget = load(task_widget_prefab).instantiate()
		task_widget_instance.task_info = task
		task_widget_instance.position = task.current_location
		$MapView/MapTexture.add_child(task_widget_instance)
		task_widgets.append(task_widget_instance)


func render_widgets():
	for widget in task_widgets:
		var current_scale = $MapView.current_scale
		widget.scale = Vector2.ONE * widget_size / current_scale
		if(current_scale >= zoom_level_medium_detail):
			widget.set_level_of_detail(widget.LevelOfDetail.MEDIUM)
		else:
			widget.set_level_of_detail(widget.LevelOfDetail.LOW)
