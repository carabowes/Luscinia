# Defines a class called MessageInstance, extending the Resource class
class_name MessageInstance
extends Resource

# Enum representing the different statuses a message can have
enum MessageStatus {
	UNREAD = 0,   # Message has not been read
	READ = 1,     # Message has been read
	REPLIED = 2   # Message has been replied to
}

## Message information that is associated with the instance
var message: Message

## The current number of turns remaining to respond to the message
var turns_remaining: int

## Current status of the message: unread, read, or replied
var message_status: MessageStatus

## The player's response to the message
var player_response: String


# Constructor (_init) that initialises a MessageInstance
func _init(message: Message = Message.default_message) -> void:
	# Set the initial message status to UNREAD
	message_status = MessageStatus.UNREAD

	# Assign the provided message to this instance
	self.message = message

	# Set the remaining turns to answer the message
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

	# Set the message status to REPLIED
	message_status = MessageStatus.REPLIED


# Method to mark a message as read
func read():
	# If the message is currently unread, mark it as read and emit an event
	if message_status == MessageStatus.UNREAD:
		EventBus.message_read.emit(self)
		message_status = MessageStatus.READ
