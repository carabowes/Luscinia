extends Control

@onready var pause_button = $"../../timer/PauseButton"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause_button.connect("pressed", _pause_game)
	$ResumeButton.connect("pressed", _resume_game)
	$RestartButton.connect("pressed", _restart_game)
	$ExitButton.connect("pressed", _exit_game)


func _pause_game():
	if(self.visible):
		pause_button.icon = load("res://Sprites/UI/OptionsButton.png")
		_resume_game()
	else:
		pause_button.icon = load("res://Sprites/UI/OptionsButton_selected.png")
		GlobalTimer.pause_game()
		self.visible = true


func _resume_game():
	pause_button.icon = load("res://Sprites/UI/OptionsButton.png")
	GlobalTimer.start_game()
	self.visible = false


func _restart_game():
	GlobalTimer.reset_clock()
	ResourceManager.reset_resources()
	MessageManager.reset_messages()
	get_tree().reload_current_scene()
	GlobalTimer.start_game()


func _exit_game():
	GlobalTimer.reset_clock()
	ResourceManager.reset_resources()
	MessageManager.reset_messages()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
