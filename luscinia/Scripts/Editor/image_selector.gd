class_name ImageSelector
extends Control

signal image_selected(image: Texture)

var current_image : Texture:
	get():
		return %IconButton.icon
	set(value):
		%IconButton.icon = value
var text : String:
	get():
		return %IconText.text
	set(value):
		%IconText.text = value

func _ready() -> void:
	%IconButton.pressed.connect(picking_new_image)

func picking_new_image():
	var image_picker : FileDialog = FileDialog.new()
	add_child(image_picker)
	image_picker.current_path += "/Sprites/"
	image_picker.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	image_picker.filters = ["*.png,*.jpg,*.svg;ImageFiles"]
	image_picker.file_selected.connect(func(path): on_image_picked(path); image_picker.queue_free())
	image_picker.popup_centered_ratio()


func on_image_picked(path : String):
	var image : Texture = load(path)
	print(image.resource_name)
	%IconButton.icon = image
	image_selected.emit(image)
