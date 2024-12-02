@tool
extends Panel
class_name ResourceEntry

@export_group("UI elements")
@export var amount_text : Label
@export var image : TextureRect
@export_group("Resource info")
@export var resource_type : String
@export var amount : int

func _draw() -> void:
	amount_text.text = str(amount)
	image.texture = ResourceManager.get_resource_texture(resource_type)
