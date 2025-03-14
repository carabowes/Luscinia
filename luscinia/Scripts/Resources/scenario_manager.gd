extends Node

var current_scenario: Scenario = null


# Sets the active scenario and applies its settings
func set_scenario(scenario: Scenario) -> void:
	if scenario == null:
		push_error("Invalid scenario provided")
		return

	current_scenario = scenario
	apply_scenario_settings()


# Applies the settings of the currently loaded scenario
func apply_scenario_settings() -> void:
	if current_scenario == null:
		push_error("No scenario loaded")
		return

	GlobalTimer.set_hour(current_scenario.starting_hour)
	GlobalTimer.set_time_step(current_scenario.time_step)

	for resource_name in current_scenario.resources:
		if resource_name in ResourceManager.resources:
			ResourceManager.resources[resource_name] = current_scenario.resources[resource_name]

	for resource_name in current_scenario.available_resources:
		if resource_name in ResourceManager.available_resources:
			ResourceManager.available_resources[resource_name] = \
				current_scenario.available_resources[resource_name]

	MessageManager.scenario = current_scenario
	MessageManager.reset_messages()


# Resets the game to a default scenario configuration, this is just used for tests
func default_scenario():
	GlobalTimer.set_hour(0)
	GlobalTimer.set_time_step(60)
