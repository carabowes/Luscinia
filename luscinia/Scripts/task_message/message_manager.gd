extends Node

signal message_sent(message: Message)

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
			if validate_prerequisite(antirequisite, time_progressed):
				antirequisite_failed = true
				break
		if antirequisite_failed:
			continue
		for prerequisite in message.prerequisites:
			if validate_prerequisite(prerequisite, time_progressed):
				messages_to_receive.append(message)
				selected_messages.append(message)
				message_sent.emit(message)
				break
		if len(message.prerequisites) == 0:
			messages_to_receive.append(message)
			selected_messages.append(message)
			message_sent.emit(message)
	for message in selected_messages:
		messages_to_send.erase(message)
	
func validate_prerequisite(prerequisite: Prerequisite, time_progressed: int) -> bool:
	return prerequisite.validate(task_instances, occurred_events, time_progressed, rng)
