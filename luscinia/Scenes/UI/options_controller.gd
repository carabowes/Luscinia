extends Control

@onready var pause_button = $"../../Timer/PauseButton"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause_button.connect("pressed", _pause_game)
	$ResumeButton.connect("pressed", _resume_game)
	$RestartButton.connect("pressed", _restart_game)
	$ExitButton.connect("pressed", _exit_game)


func _pause_game():
	if(self.visible):
		pause_button.icon = load("res://Sprites/UI/Icons/OptionsButton.png")
		_resume_game()
	else:
		pause_button.icon = load("res://Sprites/UI/Icons/OptionsButton_selected.png")
		GameManager.pause_game()
		self.visible = true


func _resume_game():
	pause_button.icon = load("res://Sprites/UI/Icons/OptionsButton.png")
	self.visible = false
	GameManager.resume_game()


func _restart_game():
	GameManager.restart_game()


func _exit_game():
	GameManager.exit_game()
