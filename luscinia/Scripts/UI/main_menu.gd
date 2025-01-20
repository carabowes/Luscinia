extends Control

func _ready() -> void:
	%play_button.connect("button_down", show_modesbutton)
	%scenario1_button.connect("button_down", change_to_scenario1)
	%back_button.connect("button_down",backbutton)
	%personalmode_button.connect("button_down", single_mode)
	%discussionmode_button.connect("button_down", discuss_mode)

func _process(delta: float) -> void:
	GlobalTimer.second_accumulator = 0

func show_scenariosbutton():
	hide_playbutton()
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	#var tween3 = get_tree().create_tween()
	tween1.tween_property(%scenario1_button,"position", Vector2(41,56),0.2)
	tween2.tween_property(%scenario2_button,"position", Vector2(41,152),0.2)
	#tween3.tween_property(%back_button,"position", Vector2(41,248),0.2)

func show_modesbutton():
	hide_playbutton()
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	tween1.tween_property(%personalmode_button,"position", Vector2(41,56),0.2)
	tween2.tween_property(%discussionmode_button,"position", Vector2(41,152),0.2)
	tween3.tween_property(%back_button,"position", Vector2(41,248),0.2)

func single_mode():
	GlobalTimer.set_time(1,0)
	show_scenariosbutton()

func discuss_mode():
	GlobalTimer.set_time(5,0)
	show_scenariosbutton()

func backbutton():
	hide_scenariobutton()
	show_playbutton()

func show_playbutton():
	var tween = get_tree().create_tween()
	tween.tween_property(%play_button,"position", Vector2(41,56),0.2)

func hide_playbutton():
	var tween = get_tree().create_tween()
	tween.tween_property(%play_button,"position", Vector2(-280,56),0.2)

func hide_scenariobutton():
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	var tween4 = get_tree().create_tween()
	var tween5 = get_tree().create_tween()
	tween1.tween_property(%scenario1_button,"position", Vector2(384,56),0.2)
	tween2.tween_property(%scenario2_button,"position", Vector2(384,152),0.2)
	tween3.tween_property(%back_button,"position", Vector2(384, 248),0.2)
	tween4.tween_property(%personalmode_button, "position", Vector2(384,56),0.2)
	tween5.tween_property(%discussionmode_button,"position", Vector2(384,152),0.2)

func change_to_scenario1():
	GlobalTimer.game_start = true
	get_tree().change_scene_to_file("res://main.tscn")
