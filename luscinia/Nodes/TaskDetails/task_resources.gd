@tool
extends GridContainer
class_name TaskResources

@export_group("UI Options")
@export var ui_color : Color:
	set(value):
		ui_color = value
		modulate = ui_color
@export_group("Resources")
@export var resources : Dictionary:
	set(value):
		resources = value
		_add_elements()
		queue_redraw()

var resource_entry_path = "res://Nodes/TaskDetails/resource_entry.tscn"

func _add_elements():
	for child in get_children():
		child.queue_free()
		
	for resource_key in resources.keys():
		if(resources[resource_key] is not int or resource_key is not String):
			printerr("Empty key or value in resources dictionary!")
			continue
		var resource_entry_instance : ResourceEntry = load(resource_entry_path).instantiate()
		resource_entry_instance.amount = resources[resource_key]
		resource_entry_instance.resource_type = resource_key
		add_child(resource_entry_instance)
		resource_entry_instance.set_owner($".")
