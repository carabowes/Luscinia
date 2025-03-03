extends Node

signal message_sent(message: MessageInstance)

@export var scenario : Scenario
var messages_to_send : Array[Message] = []
var messages_to_receive: Array[MessageInstance]
var unreplied_messages : int = 0
#var task_completed: Array[TaskData]
var message_start_turn = {}
var occurred_events: Array[Event.EventType]
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize() ##Randomize the RNG for chance-based validation
	if scenario != null:
		messages_to_send = scenario.messages.duplicate(true)
	GlobalTimer.turn_progressed.connect(check_expired_messages)
	GlobalTimer.turn_progressed.connect(find_messages_to_send)
	EventBus.task_finished.connect(_on_task_finished)
	EventBus.task_cancelled.connect(_on_task_cancelled)
	EventBus.message_responded.connect(update_responded_message)


func reset_messages():
	rng.randomize()
	messages_to_send.clear()
	messages_to_send = scenario.messages.duplicate(true)
	messages_to_receive.clear()
	unreplied_messages = 0
	message_start_turn.clear()
	occurred_events.clear()


func find_messages_to_send():
	var selected_messages: Array[Message]
	for message in messages_to_send:
		message_start_turn[message] = GlobalTimer.turns
		var antirequisite_failed : bool = false
		for antirequisite in message.antirequisites:
			if validate_prerequisite(antirequisite, GlobalTimer.turns):
				antirequisite_failed = true
				break
		if antirequisite_failed:
			continue
		for prerequisite in message.prerequisites:
			if validate_prerequisite(prerequisite, GlobalTimer.turns):
				selected_messages.append(message)
				send_message(message)
				break
		if len(message.prerequisites) == 0:
			selected_messages.append(message)
			send_message(message)
	for message in selected_messages:
		messages_to_send.erase(message)
	unreplied_messages += len(selected_messages)


func handle_expired_message(message_instance : MessageInstance):
	var message : Message = message_instance.message
	if message.default_response != -1 and message.default_response < len(message.responses):
		var default_response: Response = message.responses[message.default_response]
		EventBus.message_responded.emit(default_response, message_instance)  
	else:
		message_instance.reply(null) #No default response, but still set message to responded
		if message_instance.message.is_repeatable:
			messages_to_send.append(message_instance.message)


func update_responded_message(response : Response, message_instance : MessageInstance):
	unreplied_messages -= 1
	if unreplied_messages == 0: 
		EventBus.all_messages_read.emit()
	message_instance.reply(response)


func send_message(message : Message):
	var message_instance = MessageInstance.new(message)
	messages_to_receive.append(message_instance)
	message_sent.emit(message_instance)


func check_expired_messages():
	for message_instance : MessageInstance in messages_to_receive:
		if message_instance.message.turns_to_answer > 0:
			message_instance.turns_remaining -= 1
		if message_instance.message_status == MessageInstance.MessageStatus.REPLIED:
			continue
		if message_instance.turns_remaining == 0:
			handle_expired_message(message_instance)


func _on_task_finished(task_instance : TaskInstance):
	if task_instance.message.is_repeatable:
		messages_to_send.append(task_instance.message)


func _on_task_cancelled(task_instance : TaskInstance):
	var cancel_behaviour = task_instance.message.cancel_behaviour
	var message : Message = task_instance.message
	if cancel_behaviour == Message.CancelBehaviour.FORCE_RESEND  and not message.is_repeatable:
		#This is the only way to queue a message send at the moment. Resending the message to the pool with no prereqs 
		var message_copy : Message = message.duplicate() 
		message.prerequisites = []
		message.antirequisites = []
		messages_to_send.append(message_copy)
	elif cancel_behaviour == Message.CancelBehaviour.PREREQ_RESEND and not message.is_repeatable:
		messages_to_send.append(message)


func validate_prerequisite(prerequisite: Prerequisite, current_turn: int) -> bool:
	return prerequisite.validate(TaskManager.completed_tasks, occurred_events, current_turn, rng)
