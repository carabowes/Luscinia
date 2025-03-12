extends GutTest

var scenario_manager
var mock_scenario


func before_each():
	scenario_manager = load("res://Scripts/Resources/scenario_manager.gd").new()
	
	# Mocking Scenario
	mock_scenario = Scenario.new()
	mock_scenario.starting_hour = 10
	mock_scenario.time_step = 2
	mock_scenario.resources = {"people": 60, "funds": 20000000, "vehicles": 50, "supplies": 10000}
	mock_scenario.available_resources = {"people": 60, "vehicles": 50}


func test_set_scenario_valid():
	scenario_manager.set_scenario(mock_scenario)
	assert_eq(scenario_manager.current_scenario, mock_scenario, "Scenario should be set correctly")


func test_set_scenario_invalid():
	scenario_manager.set_scenario(null)
	assert_eq(scenario_manager.current_scenario, null, "Scenario should remain null if input is invalid")


func test_apply_scenario_settings():
	scenario_manager.current_scenario = mock_scenario
	scenario_manager.apply_scenario_settings()
	
	assert_eq(GlobalTimer.in_game_hours, 10, "Hour should be set correctly")
	assert_eq(GlobalTimer.time_step, 2, "Time step should be set correctly")
	
	assert_eq(ResourceManager.resources["people"], 60, "People should be set correctly")
	assert_eq(ResourceManager.resources["funds"], 20000000, "Funds should be set correctly")
	assert_eq(ResourceManager.resources["vehicles"], 50, "Vehicles should be set correctly")
	assert_eq(ResourceManager.resources["supplies"], 10000, "Supplies should be set correctly")
	
	assert_eq(ResourceManager.available_resources["people"], 60, "Available people should be set correctly")
	assert_eq(ResourceManager.available_resources["vehicles"], 50, "Available vehicles should be set correctly")
	
	assert_eq(MessageManager.scenario, mock_scenario, "MessageManager should have the correct scenario")
