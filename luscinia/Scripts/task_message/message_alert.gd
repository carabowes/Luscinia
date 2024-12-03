extends Node

@onready var message_list = $"../Control"
@onready var gm = $".."
@onready var message_board = $"../Control/ScrollContainer/VBoxContainer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(self.button_pressed)

func button_pressed():
	message_list.visible = true
	gm.message_amount += 1
	gm.print_msg_amt()
	gm.game_manager.incre_game_step()
	message_board.add_message()
	#gm.show_alert = false
