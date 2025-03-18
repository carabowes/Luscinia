class_name TaskWidget
extends Control

signal widget_selected(widget: TaskWidget)

enum LevelOfDetail { LOW, MEDIUM, HIGH }
const DEFAULT_SIZE: int = 48  # Default size for scaling animations

# Exported variables for customisation
@export var current_level_of_detail: LevelOfDetail
@export var use_update_animation : bool = true

var task_info: TaskInstance


func _ready():
	%ViewMoreButton.pressed.connect(_show_task_details_page)
	if use_update_animation:
		GameManager.turn_progressed.connect(_on_new_turn)


# Called when the UI needs to be redrawn
func _draw() -> void:
	if task_info != null:
		render_task_info()


# Handles user interaction with the widget
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		set_level_of_detail(LevelOfDetail.HIGH)
		widget_selected.emit(self)


# Updates the level of detail (LOD) for the widget
func set_level_of_detail(new_lod, use_animation = true):
	if current_level_of_detail == new_lod:
		return

	# Check if switching to/from HIGH detail (for animation purposes)
	var switching_from_or_to_high_detail = (
		current_level_of_detail == LevelOfDetail.HIGH
		or new_lod == LevelOfDetail.HIGH
	)
	current_level_of_detail = new_lod  # Update the current LOD

	# Apply animation when switching between high and other detail levels
	if switching_from_or_to_high_detail and use_animation:
		var tween = get_tree().create_tween()
		tween.tween_property(
			%Scaler, "scale", Vector2.ONE * 0, 0.15
		).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(
			%Scaler, "scale", Vector2.ONE, 0.2
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await tween.step_finished

	# Apply the new LOD by calling the appropriate function
	match new_lod:
		LevelOfDetail.LOW:
			_switch_to_low_lod()
		LevelOfDetail.MEDIUM:
			_switch_to_med_lod()
		LevelOfDetail.HIGH:
			_switch_to_high_lod()


# Updates the displayed task information
func render_task_info():
	%TaskNameLabelHigh.text = task_info.task_data.name.to_upper()
	%TaskNameMed.text = task_info.task_data.name.to_upper()
	%TaskIconLow.texture = task_info.task_data.icon
	%TaskIconHigh.texture = task_info.task_data.icon
	%ProgressBarLowMed.max_value = task_info.get_total_time()
	%ProgressBarLowMed.value = task_info.current_progress
	%ProgressBarHigh.max_value = task_info.get_total_time()
	%ProgressBarHigh.value = task_info.current_progress
	%TimeLeftLabelHigh.text = str(task_info.get_remaining_time()) + " hrs"


# Switches the widget to low detail view
func _switch_to_low_lod():
	%TaskNameMed.visible = false
	%LowDetailWidget.visible = true
	%HighDetailWidget.visible = false


# Switches the widget to medium detail view
func _switch_to_med_lod():
	%TaskNameMed.visible = true
	%LowDetailWidget.visible = true
	%HighDetailWidget.visible = false


# Switches the widget to high detail view
func _switch_to_high_lod():
	%TaskNameMed.visible = false
	%LowDetailWidget.visible = false
	%HighDetailWidget.visible = true


# Emits a signal to open the task details page
func _show_task_details_page():
	UIEvent.task_widget_view_details_pressed.emit(task_info)


# Handles the animation when a new turn progresses
func _on_new_turn(_new_turn : int):
	var tween = get_tree().create_tween()
	tween.tween_property(
		%Scaler, "scale", Vector2.ONE * 0.7, 0.15
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(
		self, "modulate", Color.ROYAL_BLUE, 0.15
	)
	tween.tween_property(
		%Scaler, "scale", Vector2.ONE, 0.15
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(
		self, "modulate", Color.WHITE, 0.15
	)
