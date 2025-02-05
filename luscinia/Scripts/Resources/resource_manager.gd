extends Node2D

@export var resources = {"people": 100, "funds": 1000, "vehicles": 80, "supplies": 100000}
@export var available_resources = {"people": 100, "vehicles": 80, "supplies": 100000}
@export var relationships_to_update: Dictionary

var resource_textures = {
	"people": preload("res://Sprites/UI/User.png"),
	"funds": preload("res://Sprites/UI/Dollar sign.png"),
	"vehicles": preload("res://Sprites/UI/Truck.png"),
	"supplies": preload("res://Sprites/Package.png"),
}


func add_resources(resource_name: String, amount: int):
	if resource_name in resources:
		resources[resource_name] += amount
	else:
		print("Resource not found:", resource_name)


func remove_resources(resource_name: String, amount: int):
	if resource_name in resources:
		resources[resource_name] -= amount
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
	else:
		print("Resource not found:", resource_name)


func get_resource_texture(resource_name: String) -> Texture:
	if resource_name in resource_textures:
		return resource_textures[resource_name]
	print("Texture for resource not found:", resource_name)
	return null


func queue_relationship_change(task_id: int, relationship_change: int):
	relationships_to_update[task_id] = relationship_change


func apply_relationship_change(task_id: int, sender: Sender, task_progress: float):
	if not relationships_to_update.has(task_id) or sender == null:
		return
	sender.relationship += (
		(relationships_to_update[task_id] * task_progress * 2) - relationships_to_update[task_id]
	)
	relationships_to_update.erase(task_id)

func reset_resources():
	resources = {"people": 100, "funds": 1000, "vehicles": 80, "supplies": 100000}
	available_resources = {"people": 100, "vehicles": 80, "supplies": 100000}
	relationships_to_update.clear()
