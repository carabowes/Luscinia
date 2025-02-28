class_name TaskWidget
extends Control

signal widget_selected(widget: TaskWidget)
enum LevelOfDetail { LOW, MEDIUM, HIGH }
const DEFAULT_SIZE: int = 48

@export var current_level_of_detail: LevelOfDetail
var task_info: TaskInstance

func _draw() -> void:
	print(position)
	if task_info != null:
		render_task_info()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		set_level_of_detail(LevelOfDetail.HIGH)
		widget_selected.emit($".")


func set_level_of_detail(new_lod, use_animation = true):
	if current_level_of_detail == new_lod:
		return

	var switching_from_or_to_high_detail = (
		current_level_of_detail == LevelOfDetail.HIGH
		or new_lod == LevelOfDetail.HIGH
	)

	# Animation
	if switching_from_or_to_high_detail and use_animation:
		var tween = get_tree().create_tween()
		tween.tween_property(
			self.get_child(0), "scale",
			Vector2.ONE * 0, 0.1
		).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(
			self.get_child(0), "scale",
			Vector2.ONE, 0.15
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		# Wait for first tween step to finish before switching LOD
		await tween.step_finished

	# Switching LOD
	match new_lod:
		LevelOfDetail.LOW:
			_switch_to_low_lod()
		LevelOfDetail.MEDIUM:
			_switch_to_med_lod()
		LevelOfDetail.HIGH:
			_switch_to_high_lod()
	current_level_of_detail = new_lod


func render_task_info():
	%TaskNameHigh.text = task_info.task_data.name
	%TaskNameMed.text = task_info.task_data.name
	%TaskIcon.texture = task_info.task_data.icon
	%ProgressBarLowMed.max_value = task_info.get_total_time()
	%ProgressBarLowMed.value = task_info.current_progress
	%ProgressBarHigh.max_value = task_info.get_total_time()
	%ProgressBarHigh.value = task_info.current_progress
	%HoursLeftLabelHigh.text = str(task_info.get_remaining_time()) + " hrs"

	if "funds" in task_info.task_data.resources_required.keys():
		%ResourceOneIcon.texture = ResourceManager.get_resource_texture("funds")
		%ResourceOneLabel.text = str(task_info.task_data.resources_required["funds"])

	if "people" in task_info.task_data.resources_required.keys():
		%ResourceTwoIcon.texture = ResourceManager.get_resource_texture("people")
		%ResourceTwoLabel.text = str(task_info.task_data.resources_required["people"])


func _switch_to_low_lod():
	custom_minimum_size = Vector2(48, 48)
	pivot_offset = Vector2(24, 24)
	get_child(0).pivot_offset = Vector2(24, 24)
	%ProgressBarLowMed.visible = true
	%TaskNameMed.visible = false
	%TaskInfoHigh.visible = false
	%ProgressBarHigh.visible = false
	%HoursLeftLabelHigh.visible = false
	%IconInfoMargin.add_theme_constant_override("margin_top", 0)


func _switch_to_med_lod():
	custom_minimum_size = Vector2(48, 48)
	pivot_offset = Vector2(24, 24)
	get_child(0).pivot_offset = Vector2(24, 24)
	%ProgressBarLowMed.visible = true
	%TaskNameMed.visible = true
	%TaskInfoHigh.visible = false
	%ProgressBarHigh.visible = false
	%HoursLeftLabelHigh.visible = false
	%IconInfoMargin.add_theme_constant_override("margin_top", 0)


func _switch_to_high_lod():
	custom_minimum_size = Vector2(220, 120)
	pivot_offset = Vector2(110, 80)
	get_child(0).pivot_offset =  Vector2(110, 80)
	%ProgressBarLowMed.visible = false
	%TaskNameMed.visible = false
	%TaskInfoHigh.visible = true
	%ProgressBarHigh.visible = true
	%HoursLeftLabelHigh.visible = true
	%IconInfoMargin.add_theme_constant_override("margin_top", 8)


func _show_task_details_page():
	EventBus.task_widget_view_details_pressed.emit(task_info)
