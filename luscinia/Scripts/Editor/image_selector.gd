class_name ImageSelector
extends Control

signal image_selected(image: Texture)

@export var images : Array[ImageEntry]
var current_image : Texture:
	get():
		return %Icon.texture
	set(value):
		%Icon.texture = value
var text : String:
	get():
		return %IconText.text
	set(value):
		%IconText.text = value

func _ready() -> void:
	for image in images:
		%NewImageOptions.add_item(image.image_name)
	%NewImageOptions.item_selected.connect(func(index): image_selected.emit(images[index].image); current_image = images[index].image)
