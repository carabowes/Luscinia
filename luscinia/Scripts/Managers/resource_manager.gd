class_name ResourceManager
extends Node2D

static var resource_textures = {
	"people": preload("res://Sprites/UI/User.png"),
	"funds": preload("res://Sprites/UI/Dollar sign.png"),
	"vehicles": preload("res://Sprites/UI/Truck.png"),
	"supplies": preload("res://Sprites/Package.png"),
}


var resources = {}
var available_resources = {}
var relationships_to_update: Dictionary


func _init(resources : Dictionary, available_resources : Dictionary) -> void:
	self.resources = resources
	self.available_resources = available_resources
	GameManager.task_started.connect(apply_start_task_resources)
	GameManager.task_started.connect(queue_relationship_change)
	GameManager.task_finished.connect(apply_end_task_resources)
	GameManager.task_finished.connect(apply_relationship_change)


# Rounds a floating-point value to a specified number of decimal places
static func round_to_dp(value: float, dp: int) -> float:
	var factor = pow(10, dp)
	return round(value * factor) / factor


# Formats large numerical resource values into readable text (e.g., "1.5M" for millions)
static func format_resource_value(value: int, decimal_points: int) -> String:
	if value >= 1000000:
		return str(round_to_dp(value / 1000000.0, decimal_points)) + "M"
	if value >= 1000:
		return str(round_to_dp(value / 1000.0, decimal_points)) + "K"
	return str(value)


# Adds resources to the total resource pool and clamps them within available limits
func add_resources(resource_name: String, amount: int):
	if resource_name in resources:
		resources[resource_name] += amount
		if resource_name in available_resources:
			var clamped = clamp(resources[resource_name], 0, available_resources[resource_name])
			resources[resource_name] = clamped
	else:
		print("Resource not found:", resource_name)
	GameManager.resource_updated.emit()


# Removes resources from the total resource pool and emits a signal if necessary
func remove_resources(resource_name: String, amount: int):
	if resource_name in resources:
		resources[resource_name] -= amount
		if resources[resource_name] < 0:
			resources[resource_name] = 0
	else:
		print("Resource not found:", resource_name)
	GameManager.resource_updated.emit()
	GameManager.resource_removed.emit(resource_name, amount)


# Adds to the available resources pool
func add_available_resources(resource_name: String, amount: int):
	if resource_name in resources:
		available_resources[resource_name] += amount
	else:
		print("Resource not found:", resource_name)
	GameManager.resource_updated.emit()


# Removes available resources and ensures they don't drop below zero
func remove_available_resources(resource_name: String, amount: int):
	if resource_name in resources:
		available_resources[resource_name] -= amount
		if available_resources[resource_name] < 0:
			available_resources[resource_name] = 0
	else:
		print("Resource not found:", resource_name)
	GameManager.resource_updated.emit()


# Adds or removes available resources depending on whether the amount is positive or negative
func add_or_remove_available_resources(resource_name: String, amount: int):
	if amount < 0:
		amount = abs(amount)
		remove_available_resources(resource_name, amount)
	else:
		add_available_resources(resource_name, amount)


# Checks if there is enough of a specified resource available
func has_sufficient_resource(resource_name: String, amount: int) -> bool:
	return amount <= resources[resource_name]


# Deducts resources when a task starts
func apply_start_task_resources(task_instance : TaskInstance):
	var resources_required = task_instance.task_data.resources_required
	for resource_name in resources_required:
		var resource_cost = resources_required[resource_name]
		remove_resources(resource_name, resource_cost)


# Adjusts resources when a task ends, considering both resource costs and gains
func apply_end_task_resources(task_instance : TaskInstance, cancelled : bool):
	var resources_gained = task_instance.get_gained_resources(cancelled)
	var resources_required = task_instance.task_data.resources_required
	for resource_name in resources.keys():
		# Ensure dictionaries contain all resource keys with a default value of 0
		if not resources_gained.has(resource_name):
			resources_gained[resource_name] = 0
		if not resources_required.has(resource_name):
			resources_required[resource_name] = 0

		var resource_cost = resources_required[resource_name]
		var resource_gain = resources_gained[resource_name]

		# If the resource is a limited resource (tracked in available_resources)
		if resource_name in available_resources.keys():
			# Adjust available resources permanently based on the difference between gain and cost
			var resource_difference = resource_gain - resource_cost
			add_or_remove_available_resources(resource_name, resource_difference)
			add_resources(resource_name, resource_gain)
		else:
			add_resources(resource_name, resource_gain)


# Returns the texture associated with a given resource name
static func get_resource_texture(resource_name: String) -> Texture:
	if resource_name in resource_textures:
		return resource_textures[resource_name]
	print("Texture for resource not found:", resource_name)
	return null


# Queues a relationship change, storing it in the dictionary for later processing
func queue_relationship_change(task_instance : TaskInstance):
	relationships_to_update[task_instance.task_data.task_id] = task_instance.relationship_change


# Applies a relationship change to a sender based on task progress
func apply_relationship_change(task_instance : TaskInstance, _cancelled : bool):
	var task_id : String = task_instance.task_data.task_id
	var sender : Sender = task_instance.sender
	var task_progress = task_instance.get_completion_rate()

	if not relationships_to_update.has(task_id) or sender == null:
		return

	task_progress = clamp(task_progress, 0.0, 1.0)

	# Adjust relationship change based on task completion percentage
	# 0% completion → full loss, 50% completion → no change, 100% completion → full gain
	var change = (relationships_to_update[task_id] * task_progress * 2)
	var relationship_change = change - relationships_to_update[task_id]

	sender.relationship += relationship_change  # Apply the calculated relationship change
	relationships_to_update.erase(task_id)  # Remove the processed relationship change


# Resets resources and relationships to their default values
func reset_resources():
	resources = {
		"people": 60,
		"funds": 20000000,
		"vehicles": 50,
		"supplies": 10000
	}
	available_resources = {
		"people": 60,
		"vehicles": 50
	}
	relationships_to_update.clear()
