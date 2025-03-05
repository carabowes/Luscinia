extends Resource
class_name TaskData


## ID of task, is not enforced to be unique by the program. User must ensure task ID is unique.
@export var task_id : String
## Name of task
@export var name : String
## Icon of task
@export var icon : Texture2D
## Corresponds to pixel location on map image for starting location
@export var start_location : Vector2
## Dictionary of Resource to Integer indicating how much of each resource is needed
@export var resources_required : Dictionary
## Dictionary of Resource to Integer indicating how much of each resourced is gained on completion
@export var resources_gained : Dictionary
## Expected time to complete task in whole hours
@export var expected_completion_time : int
## Dictionary of Event to Array of Event 
@export var effects_of_random_events : Array[EventEffect]


static var default_task = TaskData.new(
	"TaskID", "Task", null, Vector2(0,0), {"funds": 10}, {"funds": 15}, 8, []
):
	get:
		return default_task.duplicate(true)
	set(value):
		return


func _init(
	task_id = "",
	name = "",
	icon = null,
	start_location = Vector2.ZERO,
	resources_required = {},
	resources_gained = {},
	expected_completion_time = 0,
	effects_of_random_events: Array[EventEffect] = []
) -> void:
	self.task_id = task_id
	self.name = name
	self.icon = icon
	self.start_location = start_location
	self.resources_required = resources_required
	self.resources_gained = resources_gained
	self.expected_completion_time = expected_completion_time
	self.effects_of_random_events = effects_of_random_events
