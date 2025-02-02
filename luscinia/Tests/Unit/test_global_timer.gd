extends GutTest

var set_time_params = ParameterFactory.named_parameters(
	['minutes', 'seconds', 'minutes_result', 'seconds_result','countdown_duration_result', 'current_time_left_result'], 
	[
		[0, 0, 0, 0, 0, 0],
		[0, 30, 0, 30, 30, 30],
		[5, 0, 5, 0, 300, 300],
		[-1, -1, 0, 0, 0, 0],
		[1, 121, 3, 1, 181, 181]
	]
)

var time_update_parmas = ParameterFactory.named_parameters(
	['timestep', 'repeat_times', 'minute_result', 'hour_result', 'day_result'],
	[
		[0, 0, 0, 0, 0],
		[1, 1, 1, 0, 0],
		[60, 1, 0, 1, 0],
		[1440, 1, 0, 0, 1],
		[30, 3, 30, 1, 0],
		[210, 7, 30, 0, 1]
	]
)

func before_each():
	GlobalTimer.reset_clock()


func test_does_global_timer_exist():
	assert_not_null(GlobalTimer)


func test_reset_clock():
	GlobalTimer.reset_clock()
	assert_false(GlobalTimer.game_start)
	assert_eq(GlobalTimer.turns, 0)
	assert_eq(GlobalTimer.in_game_minutes, 0)
	assert_eq(GlobalTimer.in_game_hours, 0)
	assert_eq(GlobalTimer.in_game_days, 0)
	assert_eq(GlobalTimer.second_accumulator, 0.0)


func test_set_time(params = use_parameters(set_time_params)):
	GlobalTimer.set_time(params.minutes, params.seconds)
	assert_eq(GlobalTimer.cd_seconds, params.seconds_result)
	assert_eq(GlobalTimer.cd_minutes, params.minutes_result)
	assert_eq(GlobalTimer.countdown_duration, params.countdown_duration_result)
	assert_eq(GlobalTimer.current_time_left, params.current_time_left_result)


func test_start_game():
	assert_false(GlobalTimer.game_start)
	GlobalTimer.start_game()
	assert_true(GlobalTimer.game_start)


func test_second_accumulator():
	GlobalTimer.set_time(3, 0)
	GlobalTimer.start_game()
	gut.simulate(GlobalTimer, 5, 0.1)
	assert_eq(GlobalTimer.second_accumulator, 0.5)
	gut.simulate(GlobalTimer, 5, 0.1)
	assert_almost_eq(GlobalTimer.second_accumulator, 0.0, 0.01)


func test_second_accumulator_game_start():
	GlobalTimer.set_time(3, 0)
	GlobalTimer.start_game()
	gut.simulate(GlobalTimer, 5, 0.1)
	assert_eq(GlobalTimer.second_accumulator, 0.5)
	GlobalTimer.game_start = false
	gut.simulate(GlobalTimer, 5, 0.1)
	assert_eq(GlobalTimer.second_accumulator, 0.5)


func test_auto_turn_progression():
	var current_turn = GlobalTimer.turns
	GlobalTimer.set_time(0, 1)
	GlobalTimer.start_game()
	for i in range(10):
		gut.simulate(GlobalTimer, 1, 1)
		current_turn += 1
		assert_eq(GlobalTimer.turns, current_turn)


func test_game_time_update_on_next_turn(params = use_parameters(time_update_parmas)):
	for i in range(params.repeat_times):
		GlobalTimer.next_turn(params.timestep)
	assert_eq(GlobalTimer.in_game_minutes, params.minute_result)
	assert_eq(GlobalTimer.in_game_hours, params.hour_result)
	assert_eq(GlobalTimer.in_game_days, params.day_result)


func test_global_timer_has_turn_progressed_signal():
	assert_has_signal(GlobalTimer, "turn_progressed")


func test_turn_progressed_signal_emitted():
	watch_signals(GlobalTimer)
	GlobalTimer.next_turn(0)
	assert_signal_emit_count(GlobalTimer, "turn_progressed", 1)
