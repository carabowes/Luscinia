extends GutTest

var resources : Dictionary = {
	"funds": 100,
	"people": 100,
	"vehicles": 80,
	"supplies": 100000
}
var available_resources : Dictionary = {
	"people": 100,
	"vehicles": 80
}

func test_default_initialisation():
	var scenario = Scenario.new()
	assert_eq(scenario.scenario_name, "Scenario")
	assert_eq(scenario.messages, [])
	assert_eq(scenario.time_step, 60)
	assert_eq(scenario.starting_hour, 0)
	assert_eq(scenario.resources, resources)
	assert_eq(scenario.available_resources, available_resources)


func test_value_initialisation():
	var scenario = Scenario.new("Name", [Message.new()], 5, 40, 4, {}, {})
	assert_eq(scenario.scenario_name, "Name")
	assert_eq(len(scenario.messages), 1)
	assert_eq(scenario.time_step, 40)
	assert_eq(scenario.starting_hour, 4)
	assert_eq(scenario.resources, {})
	assert_eq(scenario.available_resources, {})
	assert_eq(scenario.number_of_turns, 5)


func test_bad_time_step_value_initialisation():
	var scenario = Scenario.new("Name", [], 0, 0)
	assert_eq(scenario.time_step, 1)


func test_bad_time_step_value_set():
	var scenario = Scenario.new()
	scenario.time_step = -10
	assert_eq(scenario.time_step, 1)


func test_bad_starting_hour_value_initialisation():
	var scenario = Scenario.new("Name", [], 0, 1, 24)
	assert_eq(scenario.starting_hour, 23)


func test_bad_starting_hour_value_set():
	var scenario = Scenario.new()
	scenario.starting_hour = -1
	assert_eq(scenario.starting_hour, 0)
