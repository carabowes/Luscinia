extends GutTest

var timer : GameTimer
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
		[0, 0, 0, 0, 1],
		[1, 1, 1, 0, 1],
		[60, 1, 0, 1, 1],
		[1440, 1, 0, 0, 2],
		[30, 3, 30, 1, 1],
		[210, 7, 30, 0, 2]
	]
)


func before_each():
	timer = GameTimer.new(0, 0, 0, 0, 0)
	add_child_autofree(timer)


func test_turns_to_time_string():
	timer.time_step = 60
	assert_eq(GameTimer.turns_to_time_string(timer, -1), "0 hours")
	assert_eq(GameTimer.turns_to_time_string(timer, 0), "0 hours")
	assert_eq(GameTimer.turns_to_time_string(timer, 1), "1 hour")
	assert_eq(GameTimer.turns_to_time_string(timer, 2), "2 hours")
	timer.time_step = 40
	assert_eq(GameTimer.turns_to_time_string(timer, -1), "0 hours")
	assert_eq(GameTimer.turns_to_time_string(timer, 0), "0 hours")
	assert_eq(GameTimer.turns_to_time_string(timer, 1), "40 mins")
	assert_eq(GameTimer.turns_to_time_string(timer, 2), "1 hour 20 mins")
	assert_eq(GameTimer.turns_to_time_string(timer, 3), "2 hours")


func test_time_to_time_string():
	timer.time_step = 60
	assert_eq(timer.time_to_time_string(1), "1 min")
	assert_eq(timer.time_to_time_string(0), "0 hours")
	assert_eq(timer.time_to_time_string(-1), "0 hours")
	assert_eq(timer.time_to_time_string(59), "59 mins")
	
	assert_eq(timer.time_to_time_string(60), "1 hour")
	assert_eq(timer.time_to_time_string(61), "1 hour 1 min")
	assert_eq(timer.time_to_time_string(62), "1 hour 2 mins")
	assert_eq(timer.time_to_time_string(120), "2 hours")
	assert_eq(timer.time_to_time_string(121), "2 hours 1 min")
	assert_eq(timer.time_to_time_string(122), "2 hours 2 mins")
	
	assert_eq(timer.time_to_time_string(122, "HR", "MIN"), "2 HRs 2 MINs")
	assert_eq(timer.time_to_time_string(59, "HR", "MIN"), "59 MINs")
	assert_eq(timer.time_to_time_string(60, "HR", "MIN"), "1 HR")
	
	assert_eq(timer.time_to_time_string(122, "HR", "MIN", "S"), "2 HRS 2 MINS")
	assert_eq(timer.time_to_time_string(59, "HR", "MIN", "S"), "59 MINS")
	assert_eq(timer.time_to_time_string(60, "HR", "MIN", "S"), "1 HR")
	
	assert_eq(timer.time_to_time_string(90, "h", "m", "s", true), "1.5 hs")
	assert_eq(timer.time_to_time_string(60, "h", "m", "s", true), "1 h")
	assert_eq(timer.time_to_time_string(30, "h", "m", "s", true), "0.5 hs")
	assert_eq(timer.time_to_time_string(1, "h", "m", "s", true), "0.01 hs")
	assert_eq(timer.time_to_time_string(1, "h", "m", "s", true, false), "0 hs")
	
	assert_eq(timer.time_to_time_string(59, "h", "m", "s", false, false), "0 hs")
	assert_eq(timer.time_to_time_string(60, "h", "m", "s", false, false), "1 h")
	assert_eq(timer.time_to_time_string(61, "h", "m", "s", false, false), "1 h")
	assert_eq(timer.time_to_time_string(62, "h", "m", "s", false, false), "1 h")
	assert_eq(timer.time_to_time_string(120, "h", "m", "s", false, false), "2 hs")
	assert_eq(timer.time_to_time_string(121, "h", "m", "s", false, false), "2 hs")
	assert_eq(timer.time_to_time_string(122, "h", "m", "s", false, false), "2 hs")


func test_set_time(params = use_parameters(set_time_params)):
	timer.set_time(params.minutes, params.seconds)
	assert_eq(timer.cd_seconds, params.seconds_result)
	assert_eq(timer.cd_minutes, params.minutes_result)
	assert_eq(timer.countdown_duration, params.countdown_duration_result)
	assert_eq(timer.current_time_left, params.current_time_left_result)


func test_second_accumulator():
	timer.set_time(3, 0)
	gut.simulate(timer, 5, 0.1)
	assert_eq(timer.second_accumulator, 0.5)
	gut.simulate(timer, 5, 0.1)
	assert_almost_eq(timer.second_accumulator, 0.0, 0.01)


func test_second_accumulator_high_fps(): #10,000fps
	timer.set_time(3, 0)
	gut.simulate(timer, 5000, 0.0001)
	assert_almost_eq(timer.second_accumulator, 0.5, 0.001)
	gut.simulate(timer, 5000, 0.0001)
	assert_almost_eq(timer.second_accumulator, 0.0, 0.001)


func test_second_accumulator_game_start():
	timer.set_time(3, 0)
	gut.simulate(timer, 5, 0.1)
	assert_almost_eq(timer.second_accumulator, 0.5, 0.01)
	gut.simulate(timer, 5, 0.1)
	assert_almost_eq(timer.second_accumulator, 0, 0.01)


func test_auto_turn_progression():
	var current_turn = timer.current_turn
	timer.set_time(0, 1)
	for i in range(10):
		gut.simulate(timer, 1, 1)
		current_turn += 1
		assert_eq(timer.current_turn, current_turn)


func test_game_time_update_on_next_turn(params = use_parameters(time_update_parmas)):
	timer.in_game_days = 1
	
	for i in range(params.repeat_times):
		timer.next_turn(params.timestep)
	assert_eq(timer.in_game_minutes, params.minute_result)
	assert_eq(timer.in_game_hours, params.hour_result)
	assert_eq(timer.in_game_days, params.day_result)


func test_turn_progressed_signal_emitted():
	watch_signals(GameManager)
	timer.next_turn(0)
	assert_signal_emit_count(GameManager, "turn_progressed", 1)
