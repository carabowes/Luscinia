extends Control

func _ready() -> void:
	%play_button.connect("button_down", show_scenariosbutton)
	%scenario1_button.connect("button_down", change_to_scenario1)
	%back_button.connect("button_down",backbutton)

func show_scenariosbutton():
	hide_playbutton()
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	tween1.tween_property(%scenario1_button,"position", Vector2(41,56),0.2)
	tween2.tween_property(%scenario2_button,"position", Vector2(41,152),0.2)
	tween3.tween_property(%back_button,"position", Vector2(41,248),0.2)

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
	tween1.tween_property(%scenario1_button,"position", Vector2(384,56),0.2)
	tween2.tween_property(%scenario2_button,"position", Vector2(384,152),0.2)
	tween3.tween_property(%back_button,"position", Vector2(384, 248),0.2)

func change_to_scenario1():
	get_tree().change_scene_to_file("res://main.tscn")
