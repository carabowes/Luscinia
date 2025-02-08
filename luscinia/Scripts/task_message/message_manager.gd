extends Node

signal message_sent(message: MessageInstance)

@export var messages_to_send: Array[Message]
var messages_to_receive: Array[Message]
#var task_completed: Array[TaskData]

var task_instances: Array[TaskInstance]
var occurred_events: Array[Event.EventType]
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize() ##Randomize the RNG for chance-based validation
	GlobalTimer.turn_progressed.connect(find_messages_to_send)


func find_messages_to_send(time_progressed: int):
	var selected_messages: Array[Message]
	for message in messages_to_send:
		var antirequisite_failed : bool = false
		for antirequisite in message.prerequisites:
			if validate_prerequisite(antirequisite, GlobalTimer.turns):
				antirequisite_failed = true
				break
		if antirequisite_failed:
			continue
		for prerequisite in message.prerequisites:
			if validate_prerequisite(prerequisite, GlobalTimer.turns):
				messages_to_receive.append(message)
				selected_messages.append(message)
				send_message(message)
				break
		if len(message.prerequisites) == 0:
			messages_to_receive.append(message)
			selected_messages.append(message)
			send_message(message)
	for message in selected_messages:
		messages_to_send.erase(message)


func send_message(message : Message):
	var message_instance = MessageInstance.new(message)
	EventBus.response_option_selected.connect(func(response : Response, message : Message): if message == message_instance.message: message_instance.reply(response))
	message_sent.emit(message_instance)


func validate_prerequisite(prerequisite: Prerequisite, current_turn: int) -> bool:
	return prerequisite.validate(task_instances, occurred_events, current_turn, rng)
