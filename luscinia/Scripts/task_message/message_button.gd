extends Node

var messageScene = preload("res://Nodes/task_message_buttons/text_message.tscn")
@export var to_be_deleted: Array[ColorRect] = []
@onready var msg_board = $".."
@onready var gm = $"../../../.."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(self.button_pressed)

func button_pressed():
	msg_board.disable_buttons()
	for i in msg_board.msg_amt[gm.message_amount-1]:
		var message = messageScene.instantiate()
		if i != 1:
			message.position += Vector2(0,108)
		message.get_child(0).text = msg_board.msg_content[msg_board.msg_shown]
		msg_board.msg_shown += 1
		to_be_deleted.append(message)
		add_child(message)
	msg_board.add_button(self)
	get_child(0).visible = true
	
func choice_picked():
	for i in to_be_deleted:
		i.free()
	to_be_deleted = []
	msg_board.reset()
	msg_board.enable_buttons()
	get_child(0).visible = false
	
