extends Node

@onready var gm = $"../../../.."

var messageScene = preload("res://Nodes/text_message.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(self.button_pressed)


func button_pressed():
	var message = messageScene.instantiate()
	var message2 = messageScene.instantiate()
	add_child(message)
	add_child(message2)
	message2.position += Vector2(0,108)
	#message.layout.transform.position.x += 16
	get_child(0).visible = true
	#get_parent().get_parent().get_parent().visible = false
