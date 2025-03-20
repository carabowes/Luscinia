extends Control

signal return_button_pressed

var resources = {}
var available_resources = {}
var resource_manager : ResourceManager:
	set(value):
		resource_manager = value
		resources = resource_manager.resources
		available_resources = resource_manager.available_resources
		update_all_labels()


func _ready() -> void:
	GameManager.resource_updated.connect(update_all_labels)
	%ReturnButton.pressed.connect(func(): return_button_pressed.emit())


# Updates a specific label with resource information
func update_label(label_name: String, resource_name: String, texture_name: String):
	var label = get_node(label_name)

	if label and resource_name in resources:
		# Special formatting for "funds" and "supplies" (only show total value)
		if resource_name != "funds" and resource_name != "supplies":
			label.text = (
				str(ResourceManager.format_resource_value(available_resources.get(resource_name, 0), 2))
				+ " / "
				+ ResourceManager.format_resource_value(resources[resource_name], 2)
			)
		else:
			label.text = ResourceManager.format_resource_value(resources[resource_name], 2)
	else:
		print("Label or resource not found:", label_name, resource_name)

	var texture_rect = get_node(texture_name)

	# If the texture node exists, update its texture
	if texture_rect:
		var texture = ResourceManager.get_resource_texture(resource_name)
		if texture:
			texture_rect.texture = texture
		else:
			print("Texture not found for resource:", resource_name)
	else:
		print("TextureRect not found:", texture_name)


# Updates all resource labels in the UI
func update_all_labels() -> void:
	update_label(
		"Background/GridContainer/Personel Output",
		"people",
		"Background/GridContainer/Personel Icon"
	)

	update_label(
		"Background/GridContainer/Funding Output",
		"funds",
		"Background/GridContainer/Funding Icon"
	)

	update_label(
		"Background/GridContainer/Vehicles Output",
		"vehicles",
		"Background/GridContainer/Vehicles Icon"
	)

	update_label(
		"Background/GridContainer/Supplies Output",
		"supplies",
		"Background/GridContainer/Supplies Icon"
	)
