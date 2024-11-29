extends Node2D


# Called when the node enters the scene tree for the first time.
var resources = {"people": 100, "funds": 1000, "vehicles": 80, "supplies": 100000}
var available_resources = {"people": 100, "vehicles": 80, "supplies": 100000}

var resource_textures = {
	"people": preload("res://Sprites/User.png"),
	"funds": preload("res://Sprites/Dollar sign.png"),
	"vehicles": preload("res://Sprites/Truck.png"),
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
	else:
		print("Texture for resource not found:", resource_name)
		return null
		






		
