extends Control

@export_group("Messages")
@export var message_data : Array[Message]

@export_group("UI Elements")
@export var message_board : MessageBoard
@onready var message_list = $"../pages/text_message_list"
@export var message_notif_button : Button
@export var map_tasks : MapTasks

var message_sent_this_turn = false

var current_message = 0

func _ready() -> void:
	message_notif_button.pressed.connect(_on_alert_pressed)
	message_notif_button.visible = true
	message_board.map = map_tasks
	message_board.response_picked.connect(func(): message_board.visible = false)
	GlobalTimer.turn_progressed.connect(func(time : int): message_sent_this_turn = false)

func _on_alert_pressed() -> void:#
	message_list.visible = true
	message_board.visible = true
	print(message_data)
	message_list.add_message()
	message_board.add_message(message_data[current_message])
	current_message += 1
	message_sent_this_turn = true

func _process(delta: float) -> void:
	if message_data.size() == current_message or message_sent_this_turn:
		message_notif_button.visible = false
	else:
		message_notif_button.visible = true
