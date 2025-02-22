extends GutTest


func test_turns_to_time_string():
	GlobalTimer.time_step = 60
	assert_eq(GlobalTimer.turns_to_time_string(-1), "0 hours")
	assert_eq(GlobalTimer.turns_to_time_string(0), "0 hours")
	assert_eq(GlobalTimer.turns_to_time_string(1), "1 hour")
	assert_eq(GlobalTimer.turns_to_time_string(2), "2 hours")
	GlobalTimer.time_step = 40
	assert_eq(GlobalTimer.turns_to_time_string(-1), "0 hours")
	assert_eq(GlobalTimer.turns_to_time_string(0), "0 hours")
	assert_eq(GlobalTimer.turns_to_time_string(1), "40 mins")
	assert_eq(GlobalTimer.turns_to_time_string(2), "1 hour 20 mins")
	assert_eq(GlobalTimer.turns_to_time_string(3), "2 hours")


func test_time_to_time_string():
	assert_eq(GlobalTimer.time_to_time_string(1), "1 min")
	assert_eq(GlobalTimer.time_to_time_string(0), "0 hours")
	assert_eq(GlobalTimer.time_to_time_string(-1), "0 hours")
	assert_eq(GlobalTimer.time_to_time_string(59), "59 mins")
	
	assert_eq(GlobalTimer.time_to_time_string(60), "1 hour")
	assert_eq(GlobalTimer.time_to_time_string(61), "1 hour 1 min")
	assert_eq(GlobalTimer.time_to_time_string(62), "1 hour 2 mins")
	assert_eq(GlobalTimer.time_to_time_string(120), "2 hours")
	assert_eq(GlobalTimer.time_to_time_string(121), "2 hours 1 min")
	assert_eq(GlobalTimer.time_to_time_string(122), "2 hours 2 mins")
	
	assert_eq(GlobalTimer.time_to_time_string(122, "HR", "MIN"), "2 HRs 2 MINs")
	assert_eq(GlobalTimer.time_to_time_string(59, "HR", "MIN"), "59 MINs")
	assert_eq(GlobalTimer.time_to_time_string(60, "HR", "MIN"), "1 HR")
	
	assert_eq(GlobalTimer.time_to_time_string(122, "HR", "MIN", "S"), "2 HRS 2 MINS")
	assert_eq(GlobalTimer.time_to_time_string(59, "HR", "MIN", "S"), "59 MINS")
	assert_eq(GlobalTimer.time_to_time_string(60, "HR", "MIN", "S"), "1 HR")
	
	assert_eq(GlobalTimer.time_to_time_string(90, "h", "m", "s", true), "1.5 hs")
	assert_eq(GlobalTimer.time_to_time_string(60, "h", "m", "s", true), "1 h")
	assert_eq(GlobalTimer.time_to_time_string(30, "h", "m", "s", true), "0.5 hs")
	assert_eq(GlobalTimer.time_to_time_string(1, "h", "m", "s", true), "0.01 hs")
	assert_eq(GlobalTimer.time_to_time_string(1, "h", "m", "s", true, false), "0 hs")
	
	assert_eq(GlobalTimer.time_to_time_string(59, "h", "m", "s", false, false), "0 hs")
	assert_eq(GlobalTimer.time_to_time_string(60, "h", "m", "s", false, false), "1 h")
	assert_eq(GlobalTimer.time_to_time_string(61, "h", "m", "s", false, false), "1 h")
	assert_eq(GlobalTimer.time_to_time_string(62, "h", "m", "s", false, false), "1 h")
	assert_eq(GlobalTimer.time_to_time_string(120, "h", "m", "s", false, false), "2 hs")
	assert_eq(GlobalTimer.time_to_time_string(121, "h", "m", "s", false, false), "2 hs")
	assert_eq(GlobalTimer.time_to_time_string(122, "h", "m", "s", false, false), "2 hs")
