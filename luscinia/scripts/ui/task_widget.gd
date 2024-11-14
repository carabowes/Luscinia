extends Control

#Anywhere the acronym lod has been used, just means level of detail

enum LevelOfDetail {LOW, MEDIUM, HIGH}

@export var current_level_of_detail : LevelOfDetail
@export var task_info_text: String:
	set(text):
		task_info_text = text
		set_task_info()
@export var task_icon: Texture:
	set(icon):
		task_icon = icon
		set_task_info()

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


#Should be some sort of object that is passed in, but for now we will just use
#properties from this task and then update when they are set
func set_task_info():
	$WidgetBackground/InfoMarginContrainer/WidgetInfo/TaskInfoHigh/TaskInfoContainer/TaskInfoLabel.text = task_info_text
	$WidgetBackground/TaskInfoMed.text = task_info_text
	$WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/TaskIcon.texture = task_icon
	pass


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
