extends Node

var game : Game

#Time Signals
signal turn_progressed(new_turn : int)

#Message signals
signal message_sent(message: MessageInstance)
signal message_read(message : MessageInstance)
signal message_responded(response : Response, message : MessageInstance)
signal all_messages_read(message : Message)

#Task signals
signal task_started(task_instance : TaskInstance)
signal task_updated(task_instance : TaskInstance)
signal task_finished(task_instance : TaskInstance, cancelled : bool)

#Resource signals
signal resource_added(resource_name : String, add_amount : int)
signal resource_removed(resource_name : String, remove_amount : int)
signal resource_lost(resource_name : String, loss_amount : int)
signal resource_gained(resource_name : String, gain_amount : int)
signal resource_updated()

#Game Signals
signal game_started(game : Game)
signal game_finished(game : Game)
signal game_paused()
signal game_resumed()
signal game_exited()

#General UI Signals
signal task_widget_view_details_pressed(task_instance : TaskInstance)
signal navbar_message_button_pressed
signal message_page_open
signal message_page_close
signal navbar_resource_button_pressed
signal resource_page_open
signal resource_page_close


func start_game(scenario : Scenario, cd_minutes : int, cd_seconds : int):
	game = Game.new(scenario.deep_duplicate(), cd_minutes, cd_seconds)
	add_child(game)
	get_tree().change_scene_to_file("res://main.tscn")
	game_started.emit(game)


func restart_game():
	var scenario = game.base_scenario
	game.queue_free()
	start_game(scenario, game.game_timer.cd_minutes, game.game_timer.cd_seconds)


func pause_game():
	game_paused.emit()


func resume_game():
	game_resumed.emit()


func exit_game():
	game_exited.emit()
	game.free()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func get_timer() -> GameTimer:
	if game == null:
		return null
	return game.game_timer


func get_resource_manager() -> ResourceManager:
	if game == null:
		return null
	return game.resource_manager


func get_task_manager() -> TaskManager:
	if game == null:
		return null
	return game.task_manager


func next_turn(timer : GameTimer):
	if timer == null:
		push_error("Timer is null, can not move to next_turn")
		return
	timer.next_turn(timer.time_step)
