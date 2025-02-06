class_name MessageInstance
extends Resource

enum MessageStatus {
	UNREAD = 0,
	READ = 1,
	REPLIED = 2
}

static var default_message : Message = Message.new("Message failed to load. No message was passed in on initialisation!", [], null, [], [], -1, false)
## Message information that is associated with the instance
var message : Message
## The current number of turns remaining in the message
var turns_remaining : int
## Current status of the message: urnead, read, or replied
var message_status : MessageStatus

func _init(message : Message = default_message) -> void:
	message_status = MessageStatus.UNREAD
	self.message = message
	self.turns_remaining = message.turns_to_answer
