extends Control
class_name TaskWidget

#Anywhere the acronym lod has been used, just means level of detail

signal widget_selected(widget : TaskWidget)
enum LevelOfDetail {LOW, MEDIUM, HIGH}

@export var current_level_of_detail : LevelOfDetail
var task_info : TaskInstance:
	set(value):
		task_info = value

#Low Med and High refer to the level of detail these elements should be show on
@onready var _progressBarLowMed = $WidgetBackground/ProgressBarLowMed
@onready var _taskInfoMed = $WidgetBackground/TaskInfoMed
@onready var _taskWidgetHigh = $WidgetBackground/InfoMarginContrainer/WidgetInfo/TaskInfoHigh
@onready var _taskInfoHigh = $WidgetBackground/InfoMarginContrainer/WidgetInfo/TaskInfoHigh/TaskInfoContainer/TaskInfoLabel
@onready var _progressBarHigh = $WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/ProgressBarHigh
@onready var _hoursLeftLabelHigh = $WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/HoursLeftLabelHigh
@onready var _taskIconMargin = $WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin
@onready var _taskIcon = $WidgetBackground/InfoMarginContrainer/WidgetInfo/IconInfoMargin/IconInfoContainer/TaskIcon
@onready var _fundsResourceImage :TextureRect = $WidgetBackground/InfoMarginContrainer/WidgetInfo/TaskInfoHigh/TaskInfoContainer/ResourcesContainer/ResourceOneIcon
@onready var _fundsResourceText = $WidgetBackground/InfoMarginContrainer/WidgetInfo/TaskInfoHigh/TaskInfoContainer/ResourcesContainer/ResourceOneLabel
@onready var _peopleResourceImage : TextureRect = $WidgetBackground/InfoMarginContrainer/WidgetInfo/TaskInfoHigh/TaskInfoContainer/ResourcesContainer/ResourceTwoIcon
@onready var _peopleResourceText = $WidgetBackground/InfoMarginContrainer/WidgetInfo/TaskInfoHigh/TaskInfoContainer/ResourcesContainer/ResourceTwoLabel

func _ready():
	add_to_group("task_widgets")


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
	if(task_info != null and _progressBarHigh != null):
		set_task_info()


func set_task_info():
	_taskInfoHigh.text = task_info.task_data.name
	_taskInfoMed.text = task_info.task_data.name
	_taskIcon.texture = task_info.task_data.icon
	_progressBarLowMed.max_value = task_info.get_total_time()
	_progressBarLowMed.value = task_info.current_progress
	_progressBarHigh.max_value = task_info.get_total_time()
	_progressBarHigh.value = task_info.current_progress
	_hoursLeftLabelHigh.text = str(task_info.get_remaining_time()) + " hrs"
	
	if "funds" in task_info.task_data.resources_required.keys():
		_fundsResourceImage.texture = ResourceManager.get_resource_texture("funds")
		_fundsResourceText.text = str(task_info.task_data.resources_required["funds"])
		
	if "people" in task_info.task_data.resources_required.keys():
		_peopleResourceImage.texture = ResourceManager.get_resource_texture("people")
		_peopleResourceText.text = str(task_info.task_data.resources_required["people"])
		

func _switch_to_low_lod():
	$".".custom_minimum_size = Vector2(48, 48)
	$".".pivot_offset = Vector2(24, 24)
	_progressBarLowMed.visible = true
	_taskInfoMed.visible = false
	_taskWidgetHigh.visible = false
	_progressBarHigh.visible = false
	_hoursLeftLabelHigh.visible = false
	_taskIconMargin.add_theme_constant_override("margin_top", 0)


func _switch_to_med_lod():
	$".".custom_minimum_size = Vector2(48, 48)
	$".".pivot_offset = Vector2(24, 24)
	_progressBarLowMed.visible = true
	_taskInfoMed.visible = true
	_taskWidgetHigh.visible = false
	_progressBarHigh.visible = false
	_hoursLeftLabelHigh.visible = false
	_taskIconMargin.add_theme_constant_override("margin_top", 0)


func _switch_to_high_lod():
	$".".custom_minimum_size = Vector2(220, 120)
	$".".pivot_offset = Vector2(110, 96)
	_progressBarLowMed.visible = false
	_taskInfoMed.visible = false
	_taskWidgetHigh.visible = true
	_progressBarHigh.visible = true
	_hoursLeftLabelHigh.visible = true
	_taskIconMargin.add_theme_constant_override("margin_top", 8)


func _show_task_details_page():
	EventBus.task_widget_view_details_pressed.emit(task_info)
	#UIStateManager._change_page_state(UIStateManager.UIPageState.TASK_DETAILS)
	
	
func get_current_progress():
	return task_info.current_progress


func set_current_progress(prog: int):
	task_info.current_progress = prog


func _gui_input(event: InputEvent) -> void:
	if(event.is_action_pressed("interact")):
		set_level_of_detail(LevelOfDetail.HIGH)
		widget_selected.emit($".")
