extends GutTest

var task_widget_scene : PackedScene
var sender : GutInputSender


var change_lod_parameters = ParameterFactory.named_parameters(
	['lod'],
	[
		[TaskWidget.LevelOfDetail.LOW],
		[TaskWidget.LevelOfDetail.MEDIUM],
		[TaskWidget.LevelOfDetail.HIGH]
	]
)

func before_all():
	task_widget_scene = load("res://Scenes/task_widget.tscn")


func test_task_widget_script_exists():
	var task_widget = TaskWidget.new()
	assert_not_null(task_widget)
	task_widget.free()


func test_task_widget_scene_exists():
	var task_widget_instance = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	assert_not_null(task_widget_instance)


func test_task_widget_in_group():
	var task_widget_instance = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	assert_true("task_widgets" in task_widget_instance.get_groups())


func test_starts_on_low_lod():
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	assert_eq(task_widget_instance.current_level_of_detail, TaskWidget.LevelOfDetail.LOW)


func test_change_of_lod(params = use_parameters(change_lod_parameters)):
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	task_widget_instance.set_level_of_detail(params.lod)
	assert_eq(task_widget_instance.current_level_of_detail, params.lod)


func test_low_lod_ui():
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	task_widget_instance.set_level_of_detail(TaskWidget.LevelOfDetail.LOW)
	assert_eq(task_widget_instance.custom_minimum_size, Vector2(48, 48))
	assert_eq(task_widget_instance.pivot_offset, Vector2(24, 24))
	assert_true(task_widget_instance.get_node("%ProgressBarLowMed").visible)
	assert_false(task_widget_instance.get_node("%TaskNameMed").visible)
	assert_false(task_widget_instance.get_node("%TaskInfoHigh").visible)
	assert_false(task_widget_instance.get_node("%ProgressBarHigh").visible)
	assert_false(task_widget_instance.get_node("%HoursLeftLabelHigh").visible)
	assert_eq(task_widget_instance.get_node("%IconInfoMargin").get_theme_constant("margin_top"), 0)


func test_med_lod_ui():
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	task_widget_instance.set_level_of_detail(TaskWidget.LevelOfDetail.MEDIUM)
	assert_eq(task_widget_instance.custom_minimum_size, Vector2(48, 48))
	assert_eq(task_widget_instance.pivot_offset, Vector2(24, 24))
	assert_true(task_widget_instance.get_node("%ProgressBarLowMed").visible)
	assert_true(task_widget_instance.get_node("%TaskNameMed").visible)
	assert_false(task_widget_instance.get_node("%TaskInfoHigh").visible)
	assert_false(task_widget_instance.get_node("%ProgressBarHigh").visible)
	assert_false(task_widget_instance.get_node("%HoursLeftLabelHigh").visible)
	assert_eq(task_widget_instance.get_node("%IconInfoMargin").get_theme_constant("margin_top"), 0)


func test_high_lod_ui():
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	task_widget_instance.set_level_of_detail(TaskWidget.LevelOfDetail.HIGH)
	assert_eq(task_widget_instance.custom_minimum_size, Vector2(220, 120))
	assert_eq(task_widget_instance.pivot_offset, Vector2(110, 96))
	assert_false(task_widget_instance.get_node("%ProgressBarLowMed").visible)
	assert_false(task_widget_instance.get_node("%TaskNameMed").visible)
	assert_true(task_widget_instance.get_node("%TaskInfoHigh").visible)
	assert_true(task_widget_instance.get_node("%ProgressBarHigh").visible)
	assert_true(task_widget_instance.get_node("%HoursLeftLabelHigh").visible)
	assert_eq(task_widget_instance.get_node("%IconInfoMargin").get_theme_constant("margin_top"), 8)


func test_task_widget_selected():
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	watch_signals(task_widget_instance)
	sender = InputSender.new(task_widget_instance)
	sender.action_down("interact")
	assert_signal_emitted(task_widget_instance, "widget_selected")
	assert_eq(task_widget_instance.current_level_of_detail, TaskWidget.LevelOfDetail.HIGH)
	sender.release_all()
	sender.clear()


func test_task_widget_render():
	var data : TaskData = TaskData.new("TaskID", "Task Name", load("res://Sprites/icon.svg"), Vector2(0,0), {"funds" : 100, "people": 50}, {}, 8, [])
	var info : TaskInstance = TaskInstance.new(data, Message.default_message)
	info.current_progress = 4
	info.extra_time = 2
	
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	task_widget_instance.task_info = info
	task_widget_instance.render_task_info()
	
	assert_eq(task_widget_instance.get_node("%TaskNameHigh").text, data.name)
	assert_eq(task_widget_instance.get_node("%TaskNameMed").text, data.name)
	assert_eq(task_widget_instance.get_node("%TaskIcon").texture, load("res://Sprites/icon.svg"))
	assert_eq(task_widget_instance.get_node("%ProgressBarLowMed").max_value, float(info.get_total_time()))
	assert_eq(task_widget_instance.get_node("%ProgressBarLowMed").value, float(info.current_progress))
	assert_eq(task_widget_instance.get_node("%ProgressBarHigh").max_value, float(info.get_total_time()))
	assert_eq(task_widget_instance.get_node("%ProgressBarHigh").value, float(info.current_progress))
	assert_eq(task_widget_instance.get_node("%HoursLeftLabelHigh").text, str(info.get_remaining_time()) + " hrs")
	assert_eq(task_widget_instance.get_node("%ResourceOneIcon").texture, ResourceManager.get_resource_texture("funds"))
	assert_eq(task_widget_instance.get_node("%ResourceOneLabel").text, str(info.task_data.resources_required["funds"]))
	assert_eq(task_widget_instance.get_node("%ResourceTwoIcon").texture, ResourceManager.get_resource_texture("people"))
	assert_eq(task_widget_instance.get_node("%ResourceTwoLabel").text, str(info.task_data.resources_required["people"]))
