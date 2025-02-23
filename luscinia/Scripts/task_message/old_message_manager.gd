extends Control

@export_group("Messages")
@export var message_data : Array[Message]
@export var random_task_data : Array[Message]

@export_group("UI Elements")
@export var message_board : MessageBoard
@export var rand_notif_button : Button
@export var map_tasks : MapTasks

var message_sent_this_turn = false

@export var current_message = 0
@export var current_rand = 0
@export var send_rand : bool = false


func _ready() -> void:
	randomize()
	rand_notif_button.pressed.connect(_on_alert_pressed)
	message_board.response_picked.connect(func(): message_board.visible = false)
	GlobalTimer.turn_progressed.connect(func(): message_sent_this_turn = false)


func _on_alert_pressed() -> void:
	_main_messages()


func _main_messages():
	message_list.visible = true
	message_board.visible = true


func _rand_messages():
	message_list.visible = true
	message_board.visible = true
	print(random_task_data)
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
