class_name MessageInstance
extends Resource

enum MessageStatus {
	UNREAD = 0,
	READ = 1,
	REPLIED = 2
}

## Message information that is associated with the instance
var message : Message
## The current number of turns remaining in the message
var turns_remaining : int
## Current status of the message: urnead, read, or replied
var message_status : MessageStatus
## The player response to the message
var player_response : String


func _init(message : Message = Message.default_message) -> void:
	message_status = MessageStatus.UNREAD
	self.message = message
	self.turns_remaining = message.turns_to_answer
	if self.turns_remaining < 1:
		self.turns_remaining = -1


func reply(response : Response):
	if response != null:
		player_response = response.response_text
	message_status = MessageStatus.REPLIED


func read():
	if message_status == MessageStatus.UNREAD:
		message_status = MessageStatus.READ
