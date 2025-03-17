class_name MessageManager
extends Node

var messages_to_send : Array[Message]
var messages_to_receive: Array[MessageInstance]
var unread_messages : Array[MessageInstance]
var occurred_events: Array[Event.EventType]
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var task_manager : TaskManager


func _init(messages_to_send : Array[Message], task_manager : TaskManager) -> void:
	rng.randomize() # Randomize the RNG for chance-based validation
	self.messages_to_send = messages_to_send
	self.task_manager = task_manager
	GameManager.turn_progressed.connect(check_expired_messages)
	GameManager.turn_progressed.connect(find_messages_to_send)
	GameManager.task_finished.connect(_on_task_finished)
	GameManager.message_responded.connect(update_responded_message)
	GameManager.message_read.connect(_on_message_read)


func find_messages_to_send(new_turn : int):
	var selected_messages: Array[Message]
	for message in messages_to_send:
		var antirequisite_failed : bool = false
		for antirequisite in message.antirequisites:
			if validate_prerequisite(antirequisite, new_turn):
				antirequisite_failed = true
				break
		if antirequisite_failed:
			continue
		for prerequisite in message.prerequisites:
			if validate_prerequisite(prerequisite, new_turn):
				selected_messages.append(message)
				send_message(message)
				break
		if len(message.prerequisites) == 0:
			selected_messages.append(message)
			send_message(message)
	for message in selected_messages:
		messages_to_send.erase(message)#


func handle_expired_message(message_instance : MessageInstance):
	var message : Message = message_instance.message
	if message.default_response != -1 and message.default_response < len(message.responses):
		var default_response: Response = message.responses[message.default_response]
		GameManager.message_responded.emit(default_response, message_instance)
	else:
		message_instance.reply(null) #No default response, but still set message to responded
		if message_instance.message.is_repeatable:
			messages_to_send.append(message_instance.message)


func update_responded_message(response : Response, message_instance : MessageInstance):
	message_instance.reply(response)


func send_message(message : Message):
	var message_instance = MessageInstance.new(message)
	unread_messages.append(message_instance)
	messages_to_receive.append(message_instance)
	GameManager.message_sent.emit(message_instance)


func check_expired_messages(_new_turn : int):
	for message_instance : MessageInstance in messages_to_receive:
		if message_instance.message.turns_to_answer > 0:
			message_instance.turns_remaining -= 1
		if message_instance.message_status == MessageInstance.MessageStatus.REPLIED:
			continue
		if message_instance.turns_remaining == 0:
			handle_expired_message(message_instance)


func _on_message_read(message: MessageInstance):
	unread_messages.erase(message)
	if(len(unread_messages) == 0):
		GameManager.all_messages_read.emit()


func _on_task_finished(task_instance : TaskInstance, cancelled : bool):
	if cancelled:
		_on_task_cancelled(task_instance)
	if task_instance.message.is_repeatable:
		messages_to_send.append(task_instance.message)


func _on_task_cancelled(task_instance : TaskInstance):
	var cancel_behaviour = task_instance.message.cancel_behaviour
	var message : Message = task_instance.message
	if cancel_behaviour == Message.CancelBehaviour.FORCE_RESEND  and not message.is_repeatable:
		#This is the only way to queue a message send at the moment. Resending the message to
		#the pool with no prereqs
		var message_copy : Message = message.duplicate()
		message.prerequisites = []
		message.antirequisites = []
		messages_to_send.append(message_copy)
	elif cancel_behaviour == Message.CancelBehaviour.PREREQ_RESEND and not message.is_repeatable:
		messages_to_send.append(message)


func validate_prerequisite(prerequisite: Prerequisite, current_turn: int) -> bool:
	return prerequisite.validate(task_manager.completed_tasks, occurred_events, current_turn, rng)
