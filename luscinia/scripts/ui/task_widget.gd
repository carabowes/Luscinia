class_name TaskWidget
extends Control

#Anywhere the acronym lod has been used, just means level of detail

enum LevelOfDetail {LOW, MEDIUM, HIGH}

@export var current_level_of_detail : LevelOfDetail
@export var task_info : TaskInstance:
	set(value):
		task_info = value
		set_task_info()
@export var task_details_page : TaskDetails

#Low Med and High refer to the level of detail these elements should be show on
@onready var _progressBarLowMed = $WidgetBackground/ProgressBarLowMed
@onready var _taskInfoMed = $WidgetBackground/TaskInfoMed
@onready var _taskInfoHigh = $WidgetBackground/InfoMarginContrainer/WidgetInfo/TaskInfoHigh
@onready var _progressBarHigh = $WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/ProgressBarHigh
@onready var _hoursLeftLabelHigh = $WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/HoursLeftLabelHigh
@onready var _taskIconMargin = $WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_1):
		set_level_of_detail(LevelOfDetail.LOW)
	if Input.is_key_pressed(KEY_2):
		set_level_of_detail(LevelOfDetail.MEDIUM)
	if Input.is_key_pressed(KEY_3):
		set_level_of_detail(LevelOfDetail.HIGH)


func set_level_of_detail(lod):
	current_level_of_detail = lod
	match lod:
		LevelOfDetail.LOW:
			_switch_to_low_lod()
		LevelOfDetail.MEDIUM:
			_switch_to_med_lod()
		LevelOfDetail.HIGH:
			_switch_to_high_lod()


func _draw() -> void:
	if(task_info != null):
		set_task_info()


func set_task_info():
	print("Setting task info!")
	$WidgetBackground/InfoMarginContrainer/WidgetInfo/TaskInfoHigh/TaskInfoContainer/TaskInfoLabel.text = task_info.task_data.name
	$WidgetBackground/TaskInfoMed.text = task_info.task_data.name
	$WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/TaskIcon.texture = task_info.task_data.icon
	$WidgetBackground/ProgressBarLowMed.max_value = task_info.get_total_time()
	$WidgetBackground/ProgressBarLowMed.value = task_info.current_progress
	$WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/ProgressBarHigh.max_value = task_info.get_total_time()
	$WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/ProgressBarHigh.value = task_info.current_progress
	$WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/HoursLeftLabelHigh.text = str(task_info.get_remaining_time()) + " hrs"
	

func _switch_to_low_lod():
	$".".custom_minimum_size = Vector2(48, 48)
	_progressBarLowMed.visible = true
	_taskInfoMed.visible = false
	_taskInfoHigh.visible = false
	_progressBarHigh.visible = false
	_hoursLeftLabelHigh.visible = false
	_taskIconMargin.add_theme_constant_override("margin_top", 0)


func _switch_to_med_lod():
	$".".custom_minimum_size = Vector2(48, 48)
	_progressBarLowMed.visible = true
	_taskInfoMed.visible = true
	_taskInfoHigh.visible = false
	_progressBarHigh.visible = false
	_hoursLeftLabelHigh.visible = false
	_taskIconMargin.add_theme_constant_override("margin_top", 0)


func _switch_to_high_lod():
	$".".custom_minimum_size = Vector2(220, 120)
	_progressBarLowMed.visible = false
	_taskInfoMed.visible = false
	_taskInfoHigh.visible = true
	_progressBarHigh.visible = true
	_hoursLeftLabelHigh.visible = true
	_taskIconMargin.add_theme_constant_override("margin_top", 8)


func _show_task_details_page():
	task_details_page.show_details(task_info)
