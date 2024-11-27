extends Node2D


# Called when the node enters the scene tree for the first time.
var resources = {"people": 100, "funds": 1000, "vehicles": 80, "supplies": 100000}
var available_resources = {"people": 100, "vehicles": 80, "supplies": 100000}

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




		
