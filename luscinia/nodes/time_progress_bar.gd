@tool
extends ProgressBar
class_name TimeProgressBar

@export var total_task_time: float = 0:
	set(value):
		total_task_time = value
		update_text()
@export var text_label: Label
@export var padding: int = 10:
	set(value):
		padding = value
		if Engine.is_editor_hint():
			queue_redraw()


func update_text():
	var current_percent = 1 - (value/max_value)
	var time_percent = total_task_time * current_percent
	var hours = ceil(time_percent)#
	if(text_label != null):
		text_label.text = str(hours) + "hrs left"


func _draw() -> void:
	custom_minimum_size.y = text_label.size.y + padding


func _value_changed(new_value: float) -> void:
	update_text()
	if Engine.is_editor_hint():
		queue_redraw()
	
	
