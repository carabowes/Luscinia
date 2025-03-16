class_name TaskResources
extends GridContainer

@export_group("Resources")
@export var resources : Dictionary:
	set(value):
		resources = value
		_add_elements()

# Visual customisation options
@export_group("Visual")
@export var icon_color : Color = Color.BLACK
@export var text_color : Color = Color.BLACK
@export var circle_color : Color = Color.WHITE
@export var use_vertical : bool = false
@export var use_circle : bool = false

var resource_entry_path = "res://Scenes/UI/resource_entry.tscn"


# Sets the increase values for resources and controls arrow visibility
func set_increments(increments : Dictionary, show_arrows : bool = true):
	for child in get_children():
		if increments.has(child.name):
			child.increase = increments[child.name]
			child.show_arrow = show_arrows


# Clears and repopulates resource elements based on the resources dictionary
func _add_elements():
	for child in get_children():
		child.free()

	for resource_key in resources.keys():
		var value_is_int = resources[resource_key] is int  # Ensure value is an integer
		var key_is_string = resource_key is String  # Ensure key is a string
		var value_is_zero = resources[resource_key] == 0 if value_is_int else false

		# Skip invalid or zero-value resources
		if not value_is_int or not key_is_string or value_is_zero:
			continue

		# Create a new ResourceEntry instance
		var resource_entry_instance : ResourceEntry = load(resource_entry_path).instantiate()
		resource_entry_instance.amount = resources[resource_key]
		resource_entry_instance.resource_type = resource_key
		resource_entry_instance.name = resource_key
		resource_entry_instance.columns = 1 if use_vertical else 3
		resource_entry_instance.icon_color = icon_color
		resource_entry_instance.circle_color = circle_color
		resource_entry_instance.text_color = text_color
		resource_entry_instance.use_circle = use_circle

		# Add the new resource entry to the UI
		add_child(resource_entry_instance)
		resource_entry_instance.set_owner(self)  # Set ownership for proper scene hierarchy
