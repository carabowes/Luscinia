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


func test_starts_on_low_lod():
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	assert_eq(task_widget_instance.current_level_of_detail, TaskWidget.LevelOfDetail.LOW)


func test_change_of_lod(params = use_parameters(change_lod_parameters)):
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	task_widget_instance.set_level_of_detail(params.lod, false)
	assert_eq(task_widget_instance.current_level_of_detail, params.lod)


func test_low_lod_ui():
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	#Wont switch if its not on other LOD first
	task_widget_instance.set_level_of_detail(TaskWidget.LevelOfDetail.MEDIUM, false)
	task_widget_instance.set_level_of_detail(TaskWidget.LevelOfDetail.LOW, false)
	assert_true(task_widget_instance.get_node("%LowDetailWidget").visible)
	assert_false(task_widget_instance.get_node("%TaskNameMed").visible)
	assert_false(task_widget_instance.get_node("%HighDetailWidget").visible)


func test_med_lod_ui():
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	task_widget_instance.set_level_of_detail(TaskWidget.LevelOfDetail.MEDIUM, false)
	assert_true(task_widget_instance.get_node("%LowDetailWidget").visible)
	assert_true(task_widget_instance.get_node("%TaskNameMed").visible)
	assert_false(task_widget_instance.get_node("%HighDetailWidget").visible)


func test_high_lod_ui():
	var task_widget_instance : TaskWidget = task_widget_scene.instantiate()
	add_child_autofree(task_widget_instance)
	task_widget_instance.set_level_of_detail(TaskWidget.LevelOfDetail.HIGH, false)
	assert_false(task_widget_instance.get_node("%LowDetailWidget").visible)
	assert_false(task_widget_instance.get_node("%TaskNameMed").visible)
	assert_true(task_widget_instance.get_node("%HighDetailWidget").visible)


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
	
	assert_eq(task_widget_instance.get_node("%TaskNameLabelHigh").text, data.name.to_upper())
	assert_eq(task_widget_instance.get_node("%TaskNameMed").text, data.name.to_upper())
	assert_eq(task_widget_instance.get_node("%TaskIconLow").texture, load("res://Sprites/icon.svg"))
	assert_eq(task_widget_instance.get_node("%TaskIconHigh").texture, load("res://Sprites/icon.svg"))
	assert_eq(task_widget_instance.get_node("%ProgressBarLowMed").max_value, float(info.get_total_time()))
	assert_eq(task_widget_instance.get_node("%ProgressBarLowMed").value, float(info.current_progress))
	assert_eq(task_widget_instance.get_node("%ProgressBarHigh").max_value, float(info.get_total_time()))
	assert_eq(task_widget_instance.get_node("%ProgressBarHigh").value, float(info.current_progress))
	assert_eq(task_widget_instance.get_node("%TimeLeftLabelHigh").text, str(info.get_remaining_time()) + " hrs")
