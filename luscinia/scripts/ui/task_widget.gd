extends Control

#Anywhere the acronym lod has been used, just means level of detail

enum LevelOfDetail {LOW, MEDIUM, HIGH}

@export var current_level_of_detail : LevelOfDetail:
	set(lod):
		change_level_of_detail(lod)
		current_level_of_detail = lod

#Low Med and High refer to the level of detail these elements should be show on
@onready var _progressBarLowMed = $WidgetBackground/ProgressBarLowMed
@onready var _taskInfoMed = $WidgetBackground/TaskInfoMed
@onready var _taskInfoHigh = $WidgetBackground/InfoMarginContrainer/WidgetInfo/TaskInfoHigh
@onready var _progressBarHigh = $WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/ProgressBarHigh
@onready var _hoursLeftLabelHigh = $WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/HoursLeftLabelHigh
@onready var _taskIconMargin = $WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_1):
		current_level_of_detail = LevelOfDetail.LOW
	if Input.is_key_pressed(KEY_2):
		current_level_of_detail = LevelOfDetail.MEDIUM
	if Input.is_key_pressed(KEY_3):
		current_level_of_detail = LevelOfDetail.HIGH


func change_level_of_detail(lod):
	match lod:
		LevelOfDetail.LOW:
			switch_to_low_lod()
		LevelOfDetail.MEDIUM:
			switch_to_med_lod()
		LevelOfDetail.HIGH:
			switch_to_high_lod()


func switch_to_low_lod():
	$".".custom_minimum_size = Vector2(48, 48)
	_progressBarLowMed.visible = true
	_taskInfoMed.visible = false
	_taskInfoHigh.visible = false
	_progressBarHigh.visible = false
	_hoursLeftLabelHigh.visible = false
	_taskIconMargin.add_theme_constant_override("margin_top", 0)


func switch_to_med_lod():
	$".".custom_minimum_size = Vector2(48, 48)
	_progressBarLowMed.visible = true
	_taskInfoMed.visible = true
	_taskInfoHigh.visible = false
	_progressBarHigh.visible = false
	_hoursLeftLabelHigh.visible = false
	_taskIconMargin.add_theme_constant_override("margin_top", 0)


func switch_to_high_lod():
	$".".custom_minimum_size = Vector2(220, 120)
	_progressBarLowMed.visible = false
	_taskInfoMed.visible = false
	_taskInfoHigh.visible = true
	_progressBarHigh.visible = true
	_hoursLeftLabelHigh.visible = true
	_taskIconMargin.add_theme_constant_override("margin_top", 8)
