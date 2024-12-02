extends VBoxContainer

@onready var gm = $"../../.."
@onready var message_list = $"../.."
#amount of incoming messages based on current iteration of gm msg loop
@export var msg_amt: Array[int] = []
#content of incoming messages based on current iteration of gm msg loop
@export var msg_content: Array[String] = []

@export var to_be_disabled: Array[Button] = []
@export var msg_shown: int

func add_message():
	var message_instance = load("res://Nodes/task_message_buttons/button.tscn").instantiate()
	message_instance.text = gm.messages[gm.message_amount-1]
	add_child(message_instance)
	move_child(message_instance, 0)

func add_button(b : Button):
	to_be_disabled.append(b)

func disable_buttons():
	for i in to_be_disabled:
		i.visible = false
		
func enable_buttons():
	for i in to_be_disabled:
		i.visible = true

func reset():
	message_list.visible = false
