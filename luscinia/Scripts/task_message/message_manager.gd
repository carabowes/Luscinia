extends Control

@export_group("Messages")
@export var message_data : Array[Message]
@export var random_task_data : Array[Message]

@export_group("UI Elements")
@export var message_board : MessageBoard
@onready var message_list = $"../pages/text_message_list"
@export var message_notif_button : Button
@export var rand_notif_button : Button
@export var map_tasks : TaskWidgetRenderer

var message_sent_this_turn = false

@export var current_message = 0
@export var current_rand = 0
@export var send_rand : bool = false


func _ready() -> void:
	randomize()
	message_notif_button.pressed.connect(_on_alert_pressed)
	rand_notif_button.pressed.connect(_on_alert_pressed)
	message_notif_button.visible = true
	message_board.map = map_tasks
	message_board.response_picked.connect(func(): message_board.visible = false)
	message_board.response_picked.connect(func(): random_chance())
	GlobalTimer.turn_progressed.connect(func(time : int): message_sent_this_turn = false)

func _on_alert_pressed() -> void:
	if(!send_rand):
		_main_messages()
	else:
		_rand_messages()

func _main_messages():
	message_list.visible = true
	message_board.visible = true
	print(message_data[current_message])
	message_list.add_message()
	message_board.add_message(message_data[current_message])
	current_message += 1
	message_sent_this_turn = true

func _rand_messages():
	message_list.visible = true
	message_board.visible = true
	print(random_task_data)
	message_list.add_message()
	message_board.add_message(random_task_data[current_rand])
	current_rand += 1

func random_chance():
	if(send_rand):
		send_rand = false
	else:
		print("response detected")
		var probability : int = 2 #1/x chance
		if(randi() % probability) == (probability - 1):
			print("random task rolled true")
			send_rand = true

func _process(delta: float) -> void:
	if message_data.size() == current_message or message_sent_this_turn:
		message_notif_button.visible = false
	else:
		message_notif_button.visible = true
	if random_task_data.size() == current_rand or !send_rand:
		rand_notif_button.visible = false
	else:
		rand_notif_button.visible = true
