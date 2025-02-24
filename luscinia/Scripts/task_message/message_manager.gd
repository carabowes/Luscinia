extends Node

signal message_sent(message: MessageInstance)

@export var scenario : Scenario
var messages_to_send : Array[Message] = []
var messages_to_receive: Array[Message]
var unreplied_messages : int = 0
#var task_completed: Array[TaskData]
var message_start_turn = {}
var occurred_events: Array[Event.EventType]
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready():
	rng.randomize() ##Randomize the RNG for chance-based validation
	if scenario != null:
		messages_to_send = scenario.messages
	GlobalTimer.turn_progressed.connect(find_messages_to_send)
	GlobalTimer.turn_progressed.connect(check_expired_messages)
	EventBus.task_finished.connect(_on_task_finished)
	EventBus.message_responded.connect(func(message, response): unreplied_messages -= 1; if unreplied_messages == 0: EventBus.all_messages_read.emit())


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


func handle_expired_message(message : Message):
	print("Handling expired message:", message.message)
	if message.default_response != -1 and message.default_response < len(message.responses):
		var default_response: Response = message.responses[message.default_response]
		print("Picking default response:", default_response.response_text)
		EventBus.message_responded.emit(default_response, message)  
	else:
		print("No default response available. Message ignored.")
	# Remove expired messages
	messages_to_send.erase(message)
	messages_to_receive.erase(message)
	EventBus.navbar_message_button_pressed.emit()


func send_message(message : Message):
	var message_instance = MessageInstance.new(message)
	EventBus.message_responded.connect(
		func(response : Response, message : Message): 
			if message == message_instance.message: 
				message_instance.reply(response)
	)
	message_sent.emit(message_instance)


func check_expired_messages():
	print("Checking expired messages for turn:", GlobalTimer.turns)
	for message in messages_to_receive:
		if message.turns_to_answer > 0 and (GlobalTimer.turns - message_start_turn.get(message, 0)) >= message.turns_to_answer:
			handle_expired_message(message)
		elif message.turns_to_answer == -1:
			print("Message", message.message, "has no limit. It should never expire.")


func _on_task_finished(task_instance : TaskInstance, cancelled : bool):
	if task_instance.message.is_repeatable:
		messages_to_send.append(task_instance.message)
	if cancelled:
		_on_task_cancelled(task_instance)


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
