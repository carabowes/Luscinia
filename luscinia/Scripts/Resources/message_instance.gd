class_name MessageInstance
extends Resource

# Enum representing the different statuses a message can have
enum MessageStatus {
	UNREAD = 0,
	READ = 1,
	REPLIED = 2
}

var message: Message

var turns_remaining: int

var message_status: MessageStatus

var player_response: String


func _init(message: Message = Message.default_message) -> void:
	message_status = MessageStatus.UNREAD

	self.message = message

	self.turns_remaining = message.turns_to_answer

	# If the message does not require a response, set turns_remaining to -1
	if self.turns_remaining < 1:
		self.turns_remaining = -1


# Method to handle replying to a message
func reply(response: Response):
	# If a valid response is provided, store the player's response text
	if response != null:
		player_response = response.response_text

	# If the message was unread before, emit an event indicating it has been read
	if message_status == MessageStatus.UNREAD:
		EventBus.message_read.emit(self)

	message_status = MessageStatus.REPLIED


# Method to mark a message as read
func read():
	# If the message is currently unread, mark it as read and emit an event
	if message_status == MessageStatus.UNREAD:
		EventBus.message_read.emit(self)
		message_status = MessageStatus.READ
