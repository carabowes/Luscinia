extends Control

var resources = {}
var available_resources = {}

func _ready() -> void:
	resources = ResourceManager.resources
	available_resources = ResourceManager.available_resources
	update_all_labels()
	
	


func _on_return_button_pressed() -> void:
	print(ResourceManager.resources["funds"])
	
func update_label(label_name: String, resource_name: String):
	var label = get_node(label_name)
	if label and resource_name in resources:
		if resource_name != "funds":
			label.text = str(available_resources.get(resource_name, 0)) + " / " + str(resources[resource_name])
		else:
			label.text = str(resources[resource_name]) + " Million"
	else:
		print("Label or resource not found:", label_name, resource_name)


func update_all_labels() -> void:
	update_label("Personel Output", "people")
	update_label("Funding Output", "funds")
	update_label("Vehicles Output", "vehicles")
	update_label("Supplies Output", "supplies")
	
