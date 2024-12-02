extends Node
@onready var main_parent = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(self.button_pressed)


func button_pressed():
	main_parent.choice_picked()
