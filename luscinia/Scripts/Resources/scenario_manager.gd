extends Node

# Stores the currently active scenario
var current_scenario: Scenario = null


# Sets the active scenario and applies its settings
func set_scenario(scenario: Scenario) -> void:
	# Ensure a valid scenario is provided
	if scenario == null:
		push_error("Invalid scenario provided")
		return

	# Assign the new scenario and apply its settings
	current_scenario = scenario
	apply_scenario_settings()


# Applies the settings of the currently loaded scenario
func apply_scenario_settings() -> void:
	# Ensure a scenario is loaded before applying settings
	if current_scenario == null:
		push_error("No scenario loaded")
		return

	# Set the starting hour and time step from the scenario
	GlobalTimer.set_hour(current_scenario.starting_hour)
	GlobalTimer.set_time_step(current_scenario.time_step)

	# Update the resource manager with scenario-defined resources
	for resource_name in current_scenario.resources:
		if resource_name in ResourceManager.resources:
			ResourceManager.resources[resource_name] = current_scenario.resources[resource_name]

	# Update available resources based on the scenario
	for resource_name in current_scenario.available_resources:
		if resource_name in ResourceManager.available_resources:
			ResourceManager.available_resources[resource_name] = \
				current_scenario.available_resources[resource_name]

	# Assign the scenario to the message manager and reset messages
	MessageManager.scenario = current_scenario
	MessageManager.reset_messages()


# Resets the game to a default scenario configuration, this is just used for tests
func default_scenario():
	# Default time settings (starting at hour 0 with a time step of 60)
	GlobalTimer.set_hour(0)
	GlobalTimer.set_time_step(60)
