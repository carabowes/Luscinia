extends Control

var resources = {}
var available_resources = {}

func _ready() -> void:
	resources = ResourceManager.resources
	available_resources = ResourceManager.available_resources
	update_all_labels()

func _process(delta: float) -> void:
	update_all_labels()
	
	
	


func _on_return_button_pressed() -> void:
	ResourceManager.remove_resources("funds", 10)
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
	update_label("Background/GridContainer/Personel Output", "people")
	update_label("Background/GridContainer/Funding Output", "funds")
	update_label("Background/GridContainer/Vehicles Output", "vehicles")
	update_label("Background/GridContainer/Supplies Output", "supplies")
	
