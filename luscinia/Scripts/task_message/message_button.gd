extends Node

var messageScene = preload("res://Nodes/task_message_buttons/text_message.tscn")
@export var to_be_deleted: Array[ColorRect] = []
@onready var msg_board = $".."
@onready var gm = $"../../../.."
var press: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(self.button_pressed)

func button_pressed():
	if(!press):
		gm.show_alert = false
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
		press = true
		get_child(0).visible = true
	
func choice_picked():
	for i in to_be_deleted:
		i.free()
	to_be_deleted = []
	msg_board.reset()
	msg_board.enable_buttons()
	if(!gm.is_reward):
		gm.decrease_resources("funds",10)
		gm.decrease_resources("people", 4)
		gm.decrease_resources("supplies", 5)
		gm.decrease_resources("vehicles", 1)
	else:
		gm.increase_resources("supplies",10)
	get_child(0).visible = false
	
