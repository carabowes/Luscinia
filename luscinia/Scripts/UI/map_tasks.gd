class_name MapTasks
extends Control

# This will be removed and changed with some sort of reference to the singleton task manager once available.
@export var details_page : TaskDetails
@export var task_instance : Array[TaskInstance]
@export var widget_size : float
@export var zoom_level_medium_detail : float

var task_widgets : Array[TaskWidget]
var task_widget_prefab = "res://Scenes/task_widget.tscn"


func _ready() -> void:
	GlobalTimer.turn_progressed.connect(update_widget_task)
	generate_widgets()
	$MapView.zoom_changed.connect(render_widgets)


func add_task_instance(new_instance : TaskInstance):
	task_instance.append(new_instance)
	print("Generating new widgets")
	generate_widgets()


func generate_widgets():
	
	var num_widgets = range(len(task_widgets))
	for i in num_widgets:
		var current_widget = task_widgets[len(task_widgets)-1]
		current_widget.queue_free()
		task_widgets.remove_at(len(task_widgets)-1)
		
	for task in task_instance:
		if task.is_completed:
			continue
		var task_widget_instance : TaskWidget = load(task_widget_prefab).instantiate()
		task_widget_instance.task_info = task
		task.current_location = lerp(task.task_data.start_location, task.task_data.end_location, float(task.current_progress)/float(task.get_total_time()))
		task_widget_instance.position = task.current_location
		$MapView/MapTexture.add_child(task_widget_instance)
		task_widgets.append(task_widget_instance)
		task_widget_instance.connect("widget_selected", update_selected_widget)
		task_widget_instance.task_details_page = details_page
		render_widgets()


func update_widget_task(time : int):
	print("Time skip!")
	for task in task_instance:
		task.current_progress += time/60
		if task.current_progress >= task.get_total_time() and !task.is_completed:
			task.is_completed = true
			ResourceManager.apply_relationship_change(task.task_data.task_id, task.sender, task.current_progress)
			for resource in task.task_data.resources_gained.keys():
				print("Before")
				print(ResourceManager.resources[resource])
				ResourceManager.add_available_resources(resource, task.task_data.resources_gained[resource])
				if(resource == "funds"):
					ResourceManager.add_resources(resource, task.task_data.resources_gained[resource])
				print("After")
				print(ResourceManager.resources[resource])
	generate_widgets()


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


func _gui_input(event: InputEvent) -> void:
	#if the task widget has been clicked off, then make sure theres no high level detail widget
	if event.is_action_pressed("interact"):
		set_level_of_details(true)
