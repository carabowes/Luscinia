extends Control

var resources = {}
var resource_entry_path = "res://path/to/ResourceEntry.tscn"  # 替换为正确的资源路径

func _ready() -> void:
	_add_elements()

func _add_elements():
	for child in get_children():
		child.free()
	
	for resource_key in resources.keys():
		if resources[resource_key] is not int or resource_key is not String:
			continue

		var resource_entry_scene = load(resource_entry_path)
		if resource_entry_scene and resource_entry_scene is PackedScene:
			var resource_entry_instance = resource_entry_scene.instantiate()
			resource_entry_instance.amount = resources[resource_key]
			resource_entry_instance.resource_type = resource_key
			resource_entry_instance.name = resource_key
			add_child(resource_entry_instance)
			resource_entry_instance.set_owner(self)
			resource_entry_instance.columns = 3
		else:
			print("Failed to load resource entry scene or invalid path:", resource_entry_path)
