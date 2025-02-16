extends GutTest

var choice_picker_instance : ChoicePicker
var choices : PopupMenu
var label : Label
var pick_option_button : Button

func before_each():
	choice_picker_instance = load("res://Scenes/Editor/choice_picker.tscn").instantiate()
	add_child_autofree(choice_picker_instance)
	choices = choice_picker_instance.get_node("%Choices")
	label = choice_picker_instance.get_node("%Label")
	pick_option_button = choice_picker_instance.get_node("%PickOptionButton")


func test_label_setter_getter():
	assert_eq(choice_picker_instance.text, "Heading", "Label default text should be 'Heading'")
	choice_picker_instance.text = "Test"
	assert_eq(choice_picker_instance.get_node("%Label").text, "Setter should set label")
	assert_eq(choice_picker_instance.text, "Test", "Setter is not changing label text correctly.")


func test_set_values():
	var values = {5: 1, "ValueTwo": 2}
	choice_picker_instance.set_values(5, values)
	assert_eq(choice_picker_instance.popup_values, values)
	assert_eq(pick_option_button.text, "5")
	assert_eq(choices.item_count, 2)
	for i in range(choices.item_count):
		assert_eq(choices.get_item_text(i), str(values.keys()[i]))


func test_connections():
	assert_connected(choices, choice_picker_instance, "index_pressed", "_on_index_pressed")
	assert_connected(pick_option_button, choice_picker_instance, "pressed")


func test_on_index_pressed():
	watch_signals(choice_picker_instance)
	var values = {"Value": 1}
	choice_picker_instance.set_values("Value", values)
	choice_picker_instance._on_index_pressed(0)
	assert_signal_emitted_with_parameters(choice_picker_instance, "value_chosen", [1])
	assert_eq(pick_option_button.text, "Value")


func test_button_press():
	pick_option_button.pressed.emit()
	assert_true(choices.visible)
