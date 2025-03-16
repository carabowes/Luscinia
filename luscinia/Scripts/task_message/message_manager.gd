extends Node

signal message_sent(message: MessageInstance)

@export var scenario : Scenario

var messages_to_send : Array[Message] = []
var messages_to_receive: Array[MessageInstance]
var unread_messages : Array[MessageInstance]
var message_start_turn = {}
var occurred_events: Array[Event.EventType]
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready():
	rng.randomize()  # Randomise the RNG for chance-based validation
	if scenario != null:
		messages_to_send = scenario.messages.duplicate(true)
	# Connect signals to their respective handler functions
	GlobalTimer.turn_progressed.connect(check_expired_messages)
	GlobalTimer.turn_progressed.connect(find_messages_to_send)
	EventBus.task_finished.connect(_on_task_finished)
	EventBus.task_cancelled.connect(_on_task_cancelled)
	EventBus.message_responded.connect(update_responded_message)
	EventBus.message_read.connect(_on_message_read)


# Resets all message-related variables and randomises the RNG
func reset_messages():
	rng.randomize()
	messages_to_send.clear()
	messages_to_send = scenario.messages.duplicate(true)
	messages_to_receive.clear()
	unread_messages = []
	message_start_turn.clear()
	occurred_events.clear()


# Function that finds and sends the messages that are ready based on their prerequisites
func find_messages_to_send():
	var selected_messages: Array[Message]
	for message in messages_to_send:
		message_start_turn[message] = GlobalTimer.turns
		var antirequisite_failed : bool = false

		# Check if any antirequisites are failed for this message
		for antirequisite in message.antirequisites:
			if validate_prerequisite(antirequisite, GlobalTimer.turns):
				antirequisite_failed = true
				break
		if antirequisite_failed:
			continue

		# Check if all prerequisites are satisfied before sending
		for prerequisite in message.prerequisites:
			if validate_prerequisite(prerequisite, GlobalTimer.turns):
				selected_messages.append(message)
				send_message(message)
				break

		# If there are no prerequisites, send the message directly
		if len(message.prerequisites) == 0:
			selected_messages.append(message)
			send_message(message)

	for message in selected_messages:
		messages_to_send.erase(message)


# Handles the logic when a message expires, i.e., its "turns_to_answer" runs out
func handle_expired_message(message_instance : MessageInstance):
	var message : Message = message_instance.message
	if message.default_response != -1 and message.default_response < len(message.responses):
		var default_response: Response = message.responses[message.default_response]
		EventBus.message_responded.emit(default_response, message_instance)
	else:
		# No default response; mark the message as replied without a response
		message_instance.reply(null)
		if message_instance.message.is_repeatable:
			messages_to_send.append(message_instance.message)


# Updates the message with the response provided by the player
func update_responded_message(response : Response, message_instance : MessageInstance):
	message_instance.reply(response)


# Sends a message by creating a new MessageInstance and adding it to the received messages list
func send_message(message : Message):
	var message_instance = MessageInstance.new(message)
	unread_messages.append(message_instance)
	messages_to_receive.append(message_instance)
	message_sent.emit(message_instance)
	print("Unread:", len(unread_messages))


# Checks if any received messages have expired and need handling
func check_expired_messages():
	for message_instance : MessageInstance in messages_to_receive:
		if message_instance.message.turns_to_answer > 0:
			message_instance.turns_remaining -= 1

		# Skip already replied messages
		if message_instance.message_status == MessageInstance.MessageStatus.REPLIED:
			continue

		if message_instance.turns_remaining == 0:
			handle_expired_message(message_instance)


# Handles the event when a message is marked as read
func _on_message_read(message: MessageInstance):
	unread_messages.erase(message)
	print("Unread:", len(unread_messages))

	# If no unread messages remain, emit the "all messages read" event
	if len(unread_messages) == 0:
		EventBus.all_messages_read.emit()


# Handles the event when a task is finished; may involve resending repeatable messages
func _on_task_finished(task_instance : TaskInstance):
	if task_instance.message.is_repeatable:
		messages_to_send.append(task_instance.message)


# Handles the event when a task is cancelled; may involve resending certain messages
func _on_task_cancelled(task_instance : TaskInstance):
	var cancel_behaviour = task_instance.message.cancel_behaviour
	var message : Message = task_instance.message

	if cancel_behaviour == Message.CancelBehaviour.FORCE_RESEND and not message.is_repeatable:
		var message_copy : Message = message.duplicate()
		message.prerequisites = []
		message.antirequisites = []
		messages_to_send.append(message_copy)
	elif cancel_behaviour == Message.CancelBehaviour.PREREQ_RESEND and not message.is_repeatable:
		messages_to_send.append(message)


# Validates whether the given prerequisite is met based on completed tasks, events, and current turn
func validate_prerequisite(prerequisite: Prerequisite, current_turn: int) -> bool:
	return prerequisite.validate(TaskManager.completed_tasks, occurred_events, current_turn, rng)
