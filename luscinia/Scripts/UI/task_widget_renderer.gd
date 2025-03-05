class_name TaskWidgetRenderer
extends Control

signal resource_gained(resource: String, amt: int)

@export var widget_size : float
@export var zoom_level_medium_detail : float
@export var use_delete_animation : bool = true
@export var use_resource_bubble_animation : bool = true
@export var use_spawn_animation : bool = true

var task_widgets : Array[TaskWidget]
var task_widget_prefab = "res://Scenes/task_widget.tscn"


func _ready() -> void:
	EventBus.task_started.connect(func(task : TaskInstance): create_widget(task))
	GlobalTimer.turn_progressed.connect(render_widgets)
	EventBus.task_finished.connect(delete_widget)
	$MapController.zoom_changed.connect(render_widgets)


func create_widget(task_instance : TaskInstance):
	if(task_instance.current_location == Vector2.ZERO):
		return
	var task_widget_instance : TaskWidget = load(task_widget_prefab).instantiate()
	task_widget_instance.task_info = task_instance
	task_widget_instance.position = task_instance.task_data.start_location

	$MapController/MapTexture.add_child(task_widget_instance)
	task_widgets.append(task_widget_instance)
	
	if(use_spawn_animation):
		task_widget_instance.get_node("%Scaler").scale = Vector2.ZERO
		var widget_tween = get_tree().create_tween()
		widget_tween.tween_interval(0.5)
		widget_tween.tween_property(
			task_widget_instance.get_node("%Scaler"), "scale", Vector2.ONE, 0.3
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		

	task_widget_instance.widget_selected.connect(update_selected_widget)
	task_widget_instance._switch_to_low_lod()
	render_widgets()


func render_resource_bubble(resource : String, widget : TaskWidget, rng : RandomNumberGenerator):
	var resource_bubble : Control = %ResourceBubble.duplicate()
	add_child(resource_bubble)
	resource_bubble.get_child(0).texture = ResourceManager.get_resource_texture(resource)
	# Set initial position to center of widget
	resource_bubble.position = widget.position  + widget.size/2
	# Generate random point in a circle with radius 1
	var offset = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
	# Distribute that point to be around the widget
	var explode_position = resource_bubble.position
	explode_position += offset * widget.DEFAULT_SIZE * rng.randf_range(0.7, 1)
	# Set final position to resources bar at top of screen (with some randomness)
	# Would like a better way to do this so it isn't hardcoded to be the center of  the screen
	var final_position = Vector2(get_viewport_rect().size.x/2, 0)

	var resource_bubble_tween = get_tree().create_tween()
	resource_bubble_tween.tween_property(
		resource_bubble, "position",
		explode_position, rng.randf_range(0.15, 0.2)
	).set_trans(Tween.TRANS_SINE)
	resource_bubble_tween.tween_interval(rng.randf_range(0.2, 0.9))
	resource_bubble_tween.tween_property(
		resource_bubble, "position",
		final_position, rng.randf_range(1.1, 1.5)
	).set_trans(Tween.TRANS_QUINT)
	#resource_bubble_tween.finished.connect(func(): resource_bubble.queue_free())


func render_resource_bubbles(task_instance : TaskInstance, widget : TaskWidget):
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	for resource in task_instance.task_data.resources_gained:
		var amount = task_instance.task_data.resources_gained[resource]
		while amount > 1000:
			amount /= 1000
		for i in range(max(amount, 5)):
			render_resource_bubble(resource, widget, rng)


func delete_widget(task_instance : TaskInstance):
	for widget in task_widgets:
		if widget.task_info != task_instance:
			continue
		# Deleting Animation
		if use_delete_animation:
			var widget_tween = get_tree().create_tween()
			widget_tween.tween_property(
				widget, "scale",
				Vector2.ZERO, 0.3
			).set_trans(Tween.TRANS_SPRING)
			await widget_tween.finished
			if use_resource_bubble_animation:
				widget.reparent(self)
				render_resource_bubbles(task_instance, widget)

		#Deleting Widget
		task_widgets.erase(widget)
		widget.queue_free()


func set_level_of_details(affect_high_detail_widgets = false):
	var current_scale = $MapController.current_scale
	for widget in task_widgets:
		if widget.current_level_of_detail == widget.LevelOfDetail.HIGH and affect_high_detail_widgets:
			widget.set_level_of_detail(widget.LevelOfDetail.MEDIUM \
			if current_scale >= zoom_level_medium_detail else widget.LevelOfDetail.LOW)
		elif widget.current_level_of_detail != widget.LevelOfDetail.HIGH:
			widget.set_level_of_detail(widget.LevelOfDetail.MEDIUM \
			if current_scale >= zoom_level_medium_detail else widget.LevelOfDetail.LOW)


func update_selected_widget(selected_widget : TaskWidget):
	var current_scale = $MapController.current_scale
	for widget in task_widgets:
		if widget != selected_widget:
			widget.set_level_of_detail(widget.LevelOfDetail.MEDIUM \
			if current_scale >= zoom_level_medium_detail else widget.LevelOfDetail.LOW)
	$MapController/MapTexture.move_child(selected_widget, \
	$MapController/MapTexture.get_child_count()-1)


func render_widgets():
	for widget in task_widgets:
		var current_scale = $MapController.current_scale
		widget.scale = Vector2.ONE * widget_size / current_scale
		set_level_of_details()
		widget.queue_redraw()


func _gui_input(event: InputEvent) -> void:
	#if the task widget has been clicked off, then make sure theres no high level detail widget
	if event.is_action_pressed("interact"):
		set_level_of_details(true)
