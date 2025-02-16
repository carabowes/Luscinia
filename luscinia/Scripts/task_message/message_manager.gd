extends Node

signal message_sent(message: MessageInstance)

@export var scenario : Scenario
var messages_to_send
var messages_to_receive: Array[Message]
var unreplied_messages : int = 0
#var task_completed: Array[TaskData]

var occurred_events: Array[Event.EventType]
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize() ##Randomize the RNG for chance-based validation
	messages_to_send = scenario.messages
	GlobalTimer.turn_progressed.connect(find_messages_to_send)
	EventBus.task_finished.connect(_on_task_finished)
	EventBus.message_responded.connect(func(message, response): unreplied_messages -= 1; if unreplied_messages == 0: EventBus.all_messages_read.emit())

func find_messages_to_send(time_progressed: int):
	var selected_messages: Array[Message]
	for message in messages_to_send:
		var antirequisite_failed : bool = false
		for antirequisite in message.antirequisites:
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
	unreplied_messages += len(selected_messages)


func send_message(message : Message):
	var message_instance = MessageInstance.new(message)
	EventBus.message_responded.connect(
		func(response : Response, message : Message): 
			if message == message_instance.message: 
				message_instance.reply(response)
	)
	message_sent.emit(message_instance)


func _on_task_finished(task_instance : TaskInstance, cancelled : bool):
	if cancelled:
		_on_task_cancelled(task_instance)


func _on_task_cancelled(task_instance : TaskInstance):
	var cancel_behaviour = task_instance.message.cancel_behaviour
	var message : Message = task_instance.message
	if cancel_behaviour == Message.CancelBehaviour.FORCE_RESEND:
		#This is the only way to queue a message send at the moment. Resending the message to the pool with no prereqs 
		var message_copy : Message = message.duplicate() 
		message.prerequisites = []
		message.antirequisites = []
		messages_to_send.append(message_copy)
	elif cancel_behaviour == Message.CancelBehaviour.PREREQ_RESEND:
		messages_to_send.append(message)
	elif cancel_behaviour == Message.CancelBehaviour.ACT_AS_COMPLETED:
		task_instance.is_completed
		EventBus.task_finished.emit(task_instance, true)
	elif cancel_behaviour == Message.CancelBehaviour.PICK_DEFAULT:
		if message.default_response == -1 or message.default_response >= len(message.responses):
			return
		var default_response : Response = message.responses[message.default_response]
		var new_instance : TaskInstance = TaskInstance.new(default_response.task, 0, 0, 0, Vector2.ZERO, true)
		EventBus.task_finished.emit(new_instance, true)


func validate_prerequisite(prerequisite: Prerequisite, current_turn: int) -> bool:
	return prerequisite.validate(TaskManager.completed_tasks, occurred_events, current_turn, rng)
