@tool
extends Panel
class_name ResourceEntry

@export_group("UI elements")
@export var amount_text : Label
@export var image : TextureRect
@export_group("Resource info")
## Doesn't do anything right now
@export var resource_type : int
@export var amount : int

func _draw() -> void:
	amount_text.text = str(amount)
	#will get the image for the resource from some resource manager and resource_type
