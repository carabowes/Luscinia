extends GutTest

var ui_timer_instance : UITimer
var ui_timer_scene : PackedScene
var timer : GameTimer

var timer_label_parameters = ParameterFactory.named_parameters(
	['minutes', 'seconds', 'time_label_result'],
	[
		[0, 0, "00:00"],
		[1, 0, "01:00"],
		[0, 1, "00:01"],
		[3, 30, "03:30"],
		[100, 30, "100:30"],
	]
)

var clock_visual_parameters = ParameterFactory.named_parameters(
	['minutes', 'seconds', 'max_value_result'],
	[
		[0, 0, 0.0],
		[1, 0, 60.0],
		[0, 1, 1.0],
		[3, 30, 210.0],
		[100, 30, 6030.0],
	]
)


func before_all():
	ui_timer_scene = load("res://Scenes/UI/timer.tscn")


func before_each():
	ui_timer_instance = ui_timer_scene.instantiate()
	timer = GameTimer.new(5, 0, 60, 0, 0)
	add_child_autofree(timer)
	add_child_autofree(ui_timer_instance)
	ui_timer_instance.game_timer = timer


func test_ui_timer_script_exists():
	var ui_timer = UITimer.new()
	assert_not_null(ui_timer)
	ui_timer.free()


func test_ui_timer_scene_exists():
	assert_not_null(ui_timer_instance)


func test_clock_visual_exists():
	assert_not_null(ui_timer_instance.get_node_or_null("%ClockVisual"))


func test_timer_label_exists():
	assert_not_null(ui_timer_instance.get_node_or_null("%TimerLabel"))


func test_day_label_exists():
	ui_timer_instance = ui_timer_scene.instantiate()
	add_child_autofree(ui_timer_instance)
	assert_not_null(ui_timer_instance.get_node_or_null("%DayLabel"))


func test_clock_label_exists():
	assert_not_null(ui_timer_instance.get_node_or_null("%ClockLabel"))


func test_clock_visual_has_textures():
	var clock_visual : TextureProgressBar = ui_timer_instance.get_node("%ClockVisual")
	assert_not_null(clock_visual.texture_under)
	assert_not_null(clock_visual.texture_progress)
	assert_null(clock_visual.texture_over)


func test_clock_visual_correct_display_settings():
	var clock_visual : TextureProgressBar = ui_timer_instance.get_node("%ClockVisual")
	assert_eq(clock_visual.fill_mode, TextureProgressBar.FillMode.FILL_COUNTER_CLOCKWISE)
	assert_true(clock_visual.nine_patch_stretch)
	assert_eq(clock_visual.radial_initial_angle, 0.0)
	assert_eq(clock_visual.radial_fill_degrees, 360.0)


func test_clock_visual_max_value(params = use_parameters(clock_visual_parameters)):
	timer.set_time(params.minutes,params.seconds)
	ui_timer_instance.game_timer = timer
	assert_eq(ui_timer_instance.get_node("%ClockVisual").max_value, params.max_value_result)


func test_clock_visual_value(params = use_parameters(clock_visual_parameters)):
	timer.set_time(params.minutes,params.seconds)
	ui_timer_instance.game_timer = timer
	assert_eq(ui_timer_instance.get_node("%ClockVisual").value, params.max_value_result)


func test_clock_visual_min_value():
	timer.set_time(50,50)
	ui_timer_instance.game_timer = timer
	assert_eq(ui_timer_instance.get_node("%ClockVisual").min_value, 0.0)


func test_clock_visual_updates():
	timer.set_time(1,0)
	ui_timer_instance.game_timer = timer
	var clock_visual : TextureProgressBar = ui_timer_instance.get_node("%ClockVisual")
	for i in range(15):
		gut.simulate(timer, 1, 5)
		gut.simulate(ui_timer_instance, 1, 5)
		assert_eq(clock_visual.value, float(timer.current_time_left))


func test_timer_label_values(params = use_parameters(timer_label_parameters)):
	timer.set_time(params.minutes,params.seconds)
	ui_timer_instance.game_timer = timer
	assert_eq(ui_timer_instance.get_node("%TimerLabel").text, params.time_label_result)


func test_day_label_values_update():
	timer.set_time(0,1)
	timer.time_step = 60 * 24
	timer.in_game_minutes = 0
	timer.in_game_hours = 0
	timer.in_game_days = 1
	timer.current_turn = 0
	ui_timer_instance.game_timer = timer
	var day_label : Label = ui_timer_instance.get_node("%DayLabel")
	for i in range(15):
		gut.simulate(ui_timer_instance, 1, 1)
		assert_eq(day_label.text, "Day " + str(i+1))
		gut.simulate(timer, 1, 1)


func test_clock_label_values_update():
	timer.set_time(0,1)
	timer.time_step = 7
	var day_label : Label = ui_timer_instance.get_node("%ClockLabel")
	for i in range(15):
		gut.simulate(ui_timer_instance, 1, 1)
		assert_eq(day_label.text, "%02d:%02d" % [timer.in_game_hours, timer.in_game_minutes])
		gut.simulate(timer, 1, 1)
