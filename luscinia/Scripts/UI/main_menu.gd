extends Control

# Scenario resource that will be loaded when Scenario 1 is selected
@export var scenario1_resource: Scenario
var cd_minutes : int
var cd_seconds : int


# Called when the node enters the scene tree (initialisation)
func _ready() -> void:
	# Connect button signals to their respective functions
	%PlayButton.connect("button_down", show_modes_button)
	%Scenario1Button.connect("button_down", change_to_scenario1)
	%BackButton.connect("button_down", backbutton)
	%PersonalmodeButton.connect("button_down", single_mode)
	%DiscussionmodeButton.connect("button_down", discuss_mode)


# Displays scenario selection buttons by animating them into view
func show_scenarios_button():
	hide_play_button()  # Hide the play button before showing scenarios
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()

	# Animate scenario buttons into position
	tween1.tween_property(%Scenario1Button, "position", Vector2(41, 56), 0.2)
	tween2.tween_property(%Scenario2Button, "position", Vector2(41, 152), 0.2)


# Displays game mode selection buttons by animating them into view
func show_modes_button():
	hide_play_button()  # Hide the play button before showing modes
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()

	# Animate mode buttons into position
	tween1.tween_property(%PersonalmodeButton, "position", Vector2(41, 56), 0.2)
	tween2.tween_property(%DiscussionmodeButton, "position", Vector2(41, 152), 0.2)
	tween3.tween_property(%BackButton, "position", Vector2(41, 248), 0.2)


# Sets the game mode to single-player mode and shows the scenario selection
func single_mode():
	cd_minutes = 1
	cd_seconds = 0
	show_scenarios_button()


# Sets the game mode to discussion mode and shows the scenario selection
func discuss_mode():
	cd_minutes = 5
	cd_seconds = 0
	show_scenarios_button()


# Handles the back button press by hiding scenario buttons and showing play button
func backbutton():
	hide_scenario_button()  # Hide the scenario selection buttons
	show_play_button()  # Show the play button again


# Animates the play button into view
func show_play_button():
	var tween = get_tree().create_tween()
	tween.tween_property(%PlayButton, "position", Vector2(41, 56), 0.2)


# Animates the play button out of view
func hide_play_button():
	var tween = get_tree().create_tween()
	tween.tween_property(%PlayButton, "position", Vector2(-280, 56), 0.2)


# Hides all scenario and mode selection buttons by animating them out of view
func hide_scenario_button():
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	var tween4 = get_tree().create_tween()
	var tween5 = get_tree().create_tween()

	# Move buttons out of the screen
	tween1.tween_property(%Scenario1Button, "position", Vector2(384, 56), 0.2)
	tween2.tween_property(%Scenario2Button, "position", Vector2(384, 152), 0.2)
	tween3.tween_property(%BackButton, "position", Vector2(384, 248), 0.2)
	tween4.tween_property(%PersonalmodeButton, "position", Vector2(384, 56), 0.2)
	tween5.tween_property(%DiscussionmodeButton, "position", Vector2(384, 152), 0.2)


# Changes to Scenario 1 by applying its settings and starting the game
func change_to_scenario1():
	if scenario1_resource:
		# Set the scenario and apply its settings
		GameManager.start_game(scenario1_resource, cd_minutes, cd_seconds)
	else:
		print("Error: Scenario 1 resource not assigned")
