extends Node

@onready var gm = $"../../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = str(gm.message_amount)
	self.pressed.connect(self.button_pressed)
	
func button_pressed():
	get_parent().get_parent().get_parent().visible = false
