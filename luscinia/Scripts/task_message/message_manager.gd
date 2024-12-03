extends Control

@onready var alert = $Button
@onready var resource_manager = $"../resource_page"
@onready var game_manager = $".."

@export_group("Messages")
@export var message_amount: int = 0
@export var show_alert: bool = false
@export var is_reward: bool = false
@export var messages: Array[String] = []

func _process(delta: float) -> void:
	if(!show_alert || messages.size() == message_amount):
		alert.visible = false
	else:
		alert.visible = true

func print_msg_amt():
	print(str(message_amount))
	
func decrease_resources(resource: String, amt: int):
	if(resource == "funds"):
		ResourceManager.remove_resources(resource,amt)
	else:
		ResourceManager.remove_available_resources(resource,amt)
	resource_manager.resources = ResourceManager.resources
	resource_manager.available_resources = ResourceManager.available_resources
	
func increase_resources(resource: String, amt: int):
	if(resource == "funds"):
		ResourceManager.add_resources(resource,amt)
	else:
		ResourceManager.add_available_resources(resource,amt)
	resource_manager.resources = ResourceManager.resources
	resource_manager.available_resources = ResourceManager.available_resources
