extends Control

var resources = {}
var available_resources = {}

func _ready() -> void:
	resources = ResourceManager.resources
	available_resources = ResourceManager.available_resources
	update_all_labels()


func update_label(label_name: String, resource_name: String, texture_name: String):
	var label = get_node(label_name)
	if label and resource_name in resources:
		if resource_name != "funds":
			label.text = str(available_resources.get(resource_name, 0)) + " / " + \
			str(resources[resource_name])
		else:
			label.text = str(resources[resource_name]) + " Million"
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
	var labels = [
		{"output": "Personel Output", "icon": "Personel Icon", "key": "people"},
		{"output": "Funding Output", "icon": "Funding Icon", "key": "funds"},
		{"output": "Vehicles Output", "icon": "Vehicles Icon", "key": "vehicles"},
		{"output": "Supplies Output", "icon": "Supplies Icon", "key": "supplies"}
	]

	for label in labels:
		update_label("Background/GridContainer/" + label["output"], label["key"], \
		"Background/GridContainer/" + label["icon"])
