extends Control

@export var resources = {}
@export var available_resources = {}


func _ready() -> void:
	resources = ResourceManager.resources
	available_resources = ResourceManager.available_resources
	visibility_changed.connect(update_all_labels)
	update_all_labels()


func _on_return_button_pressed() -> void:
	visible = false


func update_label(label_name: String, resource_name: String, texture_name: String):
	var label = get_node(label_name)
	if label and resource_name in resources:
		if resource_name != "funds":
			label.text = (
				str(ResourceManager.format_resource_value(available_resources.get(resource_name, 0),2))
				+ " / "
				+ ResourceManager.format_resource_value(resources[resource_name],2)
			)
		else:
			label.text = ResourceManager.format_resource_value(resources[resource_name],2)
	else:
		print("Label or resource not found:", label_name, resource_name)

	var texture_rect_name = texture_name
	var texture_rect = get_node(texture_rect_name)
	if texture_rect:
		var texture = ResourceManager.get_resource_texture(resource_name)
		if texture:
			texture_rect.texture = texture
		else:
			print("Texture not found for resource:", resource_name)
	else:
		print("TextureRect not found:", texture_rect_name)


func update_all_labels() -> void:
	# Update labels and their corresponding textures dynamically
	update_label(
		"Background/GridContainer/Personel Output",
		"people",
		"Background/GridContainer/Personel Icon"
	)
	update_label(
		"Background/GridContainer/Funding Output", "funds", "Background/GridContainer/Funding Icon"
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
