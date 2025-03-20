class_name TaskData
extends Resource


static var default_task = TaskData.new(
	"TaskID", "Task", null, Vector2(0,0), {"funds": 10}, {"funds": 15}, 8, []
):
	get:
		return default_task.duplicate(true)
	set(value):
		return



@export var task_id : String
@export var name : String
@export var icon : Texture2D
@export var start_location : Vector2
@export var resources_required : Dictionary
@export var resources_gained : Dictionary
@export var expected_completion_time : int
@export var effects_of_random_events : Array[EventEffect]


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
