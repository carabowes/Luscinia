class_name Message
extends Resource


enum CancelBehaviour {
	NOTHING, ##When task is cancelled, don't do anything
	FORCE_RESEND,  ##Resend the message no matter the prerequisites when the task is cancelled
	PREREQ_RESEND, ##Put the message back into the send pool, will be sent when prerequisites become
					## become true
	ACT_AS_COMPLETED,##When the task is cancelled, the task still enters the tasks completed pool
	PICK_DEFAULT ##Marks the default response option as completed rather than the task that was
				##cancelled, if there is not a valid default_response picked this will behave
				## the same as NOTHING
}


static var default_message : Message = Message.new(
	"Message failed to load. No message was passed in on initialisation!", [], -1,
	Sender.default_sender, [], [], -1, false, Message.CancelBehaviour.NOTHING
):
	get():
		return default_message.duplicate(true)
	set(value):
		return


## Message contents
@export var message: String
## Player responses
@export var responses: Array[Response]
## Index of the default response, if -1 or out of range of the responses
## there is no default response
@export var default_response : int
## Sender of messages
@export var sender: Sender:
	get:
		if sender == null:
			return Sender.default_sender
		return sender
## Array of prerequisites, conditions for the message to become active
## If any of the prerequisites are true the message pops up
@export var prerequisites: Array[Prerequisite]
## Array of antirequisites, or conditions for message to not become active
## If any antirequisite is active the message will not pop up even if there is a true prerequisite
@export var antirequisites: Array[Prerequisite]
## Maximum turns to answer until message dissapears
@export var turns_to_answer: int
## Can the message appear again e.g providing aid messages
@export var is_repeatable: bool
## If true, when a task is cancelled this message will be sent again
## regardless of the prerequisites
@export var cancel_behaviour : CancelBehaviour


func _init(
	message = "",
	responses: Array[Response] = [],
	default_response = -1,
	sender: Sender = Sender.default_sender,
	prerequisites: Array[Prerequisite] = [],
	antirequisites: Array[Prerequisite] = [],
	turns_to_answer = 0,
	is_repeatable = false,
	cancel_behaviour : CancelBehaviour = CancelBehaviour.NOTHING
) -> void:
	self.message = message
	self.responses = responses
	self.default_response = default_response
	self.sender = sender
	self.prerequisites = prerequisites
	self.antirequisites = antirequisites
	self.turns_to_answer = turns_to_answer
	self.is_repeatable = is_repeatable
	self.cancel_behaviour = cancel_behaviour
