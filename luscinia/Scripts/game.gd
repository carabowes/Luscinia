class_name Game
extends Node

var resource_manager : ResourceManager
var task_manager : TaskManager
var message_manager : MessageManager
var game_timer : GameTimer
var base_scenario : Scenario

func _init(scenario : Scenario, cd_minutes : int, cd_seconds : int) -> void:
	base_scenario = scenario.deep_duplicate()
	resource_manager = ResourceManager.new(scenario.resources, scenario.available_resources)
	task_manager = TaskManager.new()
	message_manager = MessageManager.new(scenario.messages, task_manager)
	game_timer = GameTimer.new(
		cd_minutes, cd_seconds, scenario.time_step,
		scenario.starting_hour, scenario.number_of_turns
	)

	add_child(resource_manager)
	add_child(task_manager)
	add_child(message_manager)
	add_child(game_timer)
	game_timer.game_finished.connect(end_game)


func end_game():
	GameManager.game_finished.emit(self)
