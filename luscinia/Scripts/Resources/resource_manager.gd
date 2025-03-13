extends Node2D

signal resource_removed(resource: String, amt: int)

@export var resources = {"people": 60, "funds": 20000000, "vehicles": 50, "supplies": 10000}
@export var available_resources = {"people": 60, "vehicles": 50}
@export var relationships_to_update: Dictionary


var resource_textures = {
	"people": preload("res://Sprites/UI/User.png"),
	"funds": preload("res://Sprites/UI/Dollar sign.png"),
	"vehicles": preload("res://Sprites/UI/Truck.png"),
	"supplies": preload("res://Sprites/Package.png"),
}

func round_to_dp(value: float, dp: int) -> float:
	var factor = pow(10, dp)
	return round(value * factor) / factor


func format_resource_value(value: int, decimal_points: int) -> String:
	if value >= 1000000:
		return str(round_to_dp(value / 1000000.0, decimal_points)) + "M"
	if value >= 1000:
		return str(round_to_dp(value / 1000.0, decimal_points)) + "K"
	return str(value)


func add_resources(resource_name: String, amount: int):
	if resource_name in resources:
		resources[resource_name] += amount
		if resource_name in available_resources:
			var clamped = clamp(resources[resource_name], 0, available_resources[resource_name])
			resources[resource_name] = clamped
	else:
		print("Resource not found:", resource_name)


func remove_resources(resource_name: String, amount: int):
	if resource_name in resources:
		resources[resource_name] -= amount
		resource_removed.emit(resource_name, amount)
		if resources[resource_name] < 0:
			resources[resource_name] = 0
	else:
		print("Resource not found:", resource_name)


func add_available_resources(resource_name: String, amount: int):
	if resource_name in resources:
		available_resources[resource_name] += amount
	else:
		print("Resource not found:", resource_name)


func remove_available_resources(resource_name: String, amount: int):
	if resource_name in resources:
		available_resources[resource_name] -= amount
		resource_removed.emit(resource_name, amount)
		if available_resources[resource_name] < 0:
			available_resources[resource_name] = 0
	else:
		print("Resource not found:", resource_name)


func add_or_remove_available_resources(resource_name : String, amount : int):
	if amount < 0:
		amount = abs(amount)
		remove_available_resources(resource_name, amount)
	else:
		add_available_resources(resource_name, amount)


func has_sufficient_resource(resource_name : String, amount : int) -> bool:
		return amount <= resources[resource_name]


func apply_start_task_resources(resources_required : Dictionary):
	for resource_name in resources_required:
		var resource_cost = resources_required[resource_name]
		remove_resources(resource_name, resource_cost)


func apply_end_task_resources(resources_gained : Dictionary, resources_required : Dictionary):
	for resource_name in resources.keys():
		#Fill the dictionary with 0 value if key is missing to prevent accessing non existing value
		if not resources_gained.has(resource_name):
			resources_gained[resource_name] = 0
		if not resources_required.has(resource_name):
			resources_required[resource_name] = 0

		var resource_cost = resources_required[resource_name]
		var resource_gain = resources_gained[resource_name]
		#If the resoruce is a limited resource (available resource)
		if resource_name in available_resources.keys():
			#Permantly add or remove the difference between cost and gain
			var resource_difference = resource_gain - resource_cost
			add_or_remove_available_resources(resource_name, resource_difference)
			add_resources(resource_name, resource_gain)
		else:
			add_resources(resource_name, resource_gain)


func get_resource_texture(resource_name: String) -> Texture:
	if resource_name in resource_textures:
		return resource_textures[resource_name]
	print("Texture for resource not found:", resource_name)
	return null


func queue_relationship_change(task_id: String, relationship_change: int):
	relationships_to_update[task_id] = relationship_change


func apply_relationship_change(task_id: String, sender: Sender, task_progress: float):
	if not relationships_to_update.has(task_id) or sender == null:
		return
	#Limit task_progress to between 0 and 1
	task_progress = clamp(task_progress, 0.0, 1.0)
	# If a user ends a task early they should not get the full relationship benefits
	# 0% = relationship lost, 50% = 0 no relationship change, 100% = relationship gain
	var change = (relationships_to_update[task_id] * task_progress * 2)
	var relationship_change = change - relationships_to_update[task_id]
	sender.relationship += relationship_change
	relationships_to_update.erase(task_id)


func reset_resources():
	resources = {"people": 60, "funds": 20000000, "vehicles": 50, "supplies": 10000}
	available_resources = {"people": 60, "vehicles": 50}
	relationships_to_update.clear()
