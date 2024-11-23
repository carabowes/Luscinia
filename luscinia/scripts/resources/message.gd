class_name Message
extends Resource

## Message contents
@export var message : String
## Player responses
@export var responses : Array[String]
## Tasks corresponding to the repsonses, ensure both arrays are same size and elements line up
@export var tasks : Array[TaskData]
## Array of prerequisites, conditions for the message to become active
## If any of the prerequisites are true the message pops up
@export var prerequisites : Array[Prerequisite]
## Array of antirequisites, or conditions for message to not become active
## If any antirequisite is active the message will not pop up even if there is a true prerequisite 
@export var antirequisites : Array[Prerequisite]
## Maximum turns to answer until message dissapears
@export var turns_to_answer : int
## Can the message appear again e.g providing aid messages
@export var is_repeatable : bool

func _init(message = "", respones = [], tasks = [], prerequisites = [], antirequisites = [], turns_to_answer = 0, is_repeatable = false) -> void:
	self.message = message
	self.responses = respones
	self.tasks = tasks
	self.prerequisites = prerequisites
	self.antirequisites = antirequisites
	self.turns_to_answer = turns_to_answer
	self.is_repeatable = is_repeatable
