extends GutTest

var image_selector_instance : ImageSelector
var heading_label : Label
var icon_button : Button

func before_each():
	image_selector_instance = load("res://Scenes/Editor/image_selector.tscn").instantiate()
	add_child_autofree(image_selector_instance)
	heading_label = image_selector_instance.get_node("%IconText")
	icon_button = image_selector_instance.get_node("%IconButton")


func test_getters_setters():
	assert_eq(image_selector_instance.current_image, null, "Default image should be null")
	var image = load("res://Sprites/icon.svg")
	image_selector_instance.current_image = image
	assert_eq(icon_button.icon, image, "Setter should set icon image")
	assert_eq(image_selector_instance.current_image, image)
	
	assert_eq(image_selector_instance.text, "Heading", "Default heading should be 'Heading'")
	var text = "Test"
	image_selector_instance.text = text
	assert_eq(heading_label.text, "Test", "Setter should set heading label")
	assert_eq(image_selector_instance.text, text)


func test_connections():
	assert_connected(icon_button, image_selector_instance, "pressed", "_picking_new_image")


func test_picking_new_image():
	image_selector_instance._picking_new_image()
	var file_dialog : FileDialog = image_selector_instance.get_child(-1)
	assert_is(file_dialog, FileDialog, "Most recent child should be a file dialog")
	assert_eq(file_dialog.current_path, "res://Sprites/")
	assert_eq(file_dialog.file_mode, FileDialog.FILE_MODE_OPEN_FILE)
	assert_eq(file_dialog.filters, PackedStringArray(["*.png,*.jpg,*.svg;ImageFiles"]))
	assert_connected(file_dialog, image_selector_instance, "file_selected")
	assert_true(file_dialog.visible)


func test_on_image_picked():
	var image = load("res://Sprites/icon.svg")
	watch_signals(image_selector_instance)
	image_selector_instance._on_image_picked("res://Sprites/icon.svg")
	assert_eq(icon_button.icon,image)
	assert_signal_emitted_with_parameters(image_selector_instance, "image_selected", [image])


func test_user_picking_image():
	var image = load("res://Sprites/icon.svg")
	watch_signals(image_selector_instance)
	image_selector_instance._picking_new_image()
	var file_dialog : FileDialog = image_selector_instance.get_child(-1)
	file_dialog.file_selected.emit("res://Sprites/icon.svg")
	assert_true(file_dialog.is_queued_for_deletion())
	assert_signal_emitted_with_parameters(image_selector_instance, "image_selected", [image])
