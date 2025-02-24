extends Control

func _ready() -> void:
	%PlayButton.connect("button_down", show_modes_button)
	%Scenario1Button.connect("button_down", change_to_scenario1)
	%BackButton.connect("button_down",backbutton)
	%PersonalmodeButton.connect("button_down", single_mode)
	%DiscussionmodeButton.connect("button_down", discuss_mode)

func show_scenarios_button():
	hide_play_button()
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	#var tween3 = get_tree().create_tween()
	tween1.tween_property(%Scenario1Button,"position", Vector2(41,56),0.2)
	tween2.tween_property(%Scenario2Button,"position", Vector2(41,152),0.2)
	#tween3.tween_property(%back_button,"position", Vector2(41,248),0.2)

func show_modes_button():
	hide_play_button()
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	tween1.tween_property(%PersonalmodeButton,"position", Vector2(41,56),0.2)
	tween2.tween_property(%DiscussionmodeButton,"position", Vector2(41,152),0.2)
	tween3.tween_property(%BackButton,"position", Vector2(41,248),0.2)

func single_mode():
	GlobalTimer.set_time(1,0)
	show_scenarios_button()

func discuss_mode():
	GlobalTimer.set_time(5,0)
	show_scenarios_button()

func backbutton():
	hide_scenario_button()
	show_play_button()

func show_play_button():
	var tween = get_tree().create_tween()
	tween.tween_property(%PlayButton,"position", Vector2(41,56),0.2)

func hide_play_button():
	var tween = get_tree().create_tween()
	tween.tween_property(%PlayButton,"position", Vector2(-280,56),0.2)

func hide_scenario_button():
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	var tween4 = get_tree().create_tween()
	var tween5 = get_tree().create_tween()
	tween1.tween_property(%Scenario1Button,"position", Vector2(384,56),0.2)
	tween2.tween_property(%Scenario2Button,"position", Vector2(384,152),0.2)
	tween3.tween_property(%BackButton,"position", Vector2(384, 248),0.2)
	tween4.tween_property(%PersonalmodeButton, "position", Vector2(384,56),0.2)
	tween5.tween_property(%DiscussionmodeButton,"position", Vector2(384,152),0.2)

func change_to_scenario1():
	GlobalTimer.start_game()
	get_tree().change_scene_to_file("res://main.tscn")
