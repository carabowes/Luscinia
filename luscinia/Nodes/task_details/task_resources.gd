extends GridContainer
class_name TaskResources

@export_group("UI Options")
@export var ui_color : Color:
	set(value):
		ui_color = value
		for child in get_children(true):
			if child.self_modulate == Color.WHITE:
				child.self_modulate = ui_color
@export var horizontal_layout : bool
@export_group("Resources")
@export var resources : Dictionary:
	set(value):
		resources = value
		_add_elements()

var resource_entry_path = "res://Nodes/task_details/resource_entry.tscn"


func set_increments(increments : Dictionary):
	for child in get_children():
		if increments.has(child.name):
			child.increase = increments[child.name]


func _add_elements():
	for child in get_children():
		child.free()
		
	for resource_key in resources.keys():
		if(resources[resource_key] is not int or resource_key is not String):
			continue
		var resource_entry_instance : ResourceEntry = load(resource_entry_path).instantiate()
		resource_entry_instance.amount = resources[resource_key]
		resource_entry_instance.resource_type = resource_key
		resource_entry_instance.name = resource_key
		add_child(resource_entry_instance)
		resource_entry_instance.set_owner($".")
		resource_entry_instance.columns = 3 if horizontal_layout else 1
