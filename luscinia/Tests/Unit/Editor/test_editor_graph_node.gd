extends GutTest

var graph_node_instance : TaskEditorGraphNode

func before_each():
	graph_node_instance = TaskEditorGraphNode.new()
	add_child_autofree(graph_node_instance)


func test_number_colours_equal_number_slots():
	assert_eq(len(graph_node_instance.slot_colors), len(graph_node_instance.SlotType))


func test_spawn_with_delete_button():
	var delete_button = graph_node_instance.get_child(-1)
	assert_is(delete_button, Button)
	assert_eq(delete_button.text, "X")


func test_minimum_x_size():
	assert_eq(graph_node_instance.custom_minimum_size.x, 300.0, "Minimum size X should be 300")


func test_resizable():
	assert_true(graph_node_instance.resizable)


func test_delete_button_deletes_node():
	var delete_button : Button = graph_node_instance.get_child(-1)
	watch_signals(graph_node_instance)
	delete_button.pressed.emit()
	assert_signal_emitted(graph_node_instance, "deleted")


func test_overridable_functions():
	assert_false(graph_node_instance.assign_connection(0, null))
	assert_false(graph_node_instance.remove_connection(0, null))
	assert_null(graph_node_instance.create_node_to_connect_from_empty(0))
	assert_null(graph_node_instance.create_node_to_connect_to_empty(0))


func test_add_input():
	var input = graph_node_instance.add_input("Heading", "Value")
	assert_not_null(input)
	assert_is(graph_node_instance.get_child(-1), LineEdit, "Most recent child should be LineEdit")
	assert_is(graph_node_instance.get_child(-2), Label, "Second most recent child should be Label")
	assert_eq(graph_node_instance.get_child(-1).text, "Value")
	assert_eq(graph_node_instance.get_child(-2).text, "Heading")


func test_add_large_input():
	var large_input = graph_node_instance.add_large_input("Heading", "Value")
	assert_not_null(large_input)
	assert_is(graph_node_instance.get_child(-1), TextEdit, "Most recent child should be TextEdit")
	assert_is(graph_node_instance.get_child(-2), Label, "Second most recent child should be Label")
	assert_eq(large_input.text, "Value")
	assert_eq(large_input.custom_minimum_size.y, 200.0)
	assert_eq(large_input.wrap_mode, TextEdit.LINE_WRAPPING_BOUNDARY)
	assert_eq(large_input.autowrap_mode, TextServer.AUTOWRAP_WORD)


func test_add_image_selector():
	var image = load("res://Sprites/icon.svg")
	var image_selector = graph_node_instance.add_image_selector("Heading", image)
	assert_not_null(image_selector)
	assert_is(graph_node_instance.get_child(-1), ImageSelector, "Most recent child should be ImageSelector")
	assert_eq(image_selector.text, "Heading")
	assert_eq(image_selector.current_image, image)


func test_generate_fields_from_resources_empty():
	var fields : Array[Field] = TaskEditorGraphNode.generate_fields_from_resources({})
	assert_eq(len(fields), len(ResourceManager.resources))
	for field in fields:
		assert_eq(field.field_value, "0")
		assert_ne(field.field_name, "")
		field.free()


func test_generate_fields_from_resources_values():
	var fields : Array[Field] = TaskEditorGraphNode.generate_fields_from_resources({"funds": 100})
	assert_eq(len(fields), len(ResourceManager.resources))
	for field in fields:
		if field.field_name == "funds":
			assert_eq(field.field_value, "100")
		else:
			assert_eq(field.field_value, "0")
		assert_ne(field.field_name, "")
		field.free()


func test_add_collapsable_menu_with_fields():
	var fields : Array[Field] = TaskEditorGraphNode.generate_fields_from_resources({})
	var container = graph_node_instance.add_collapsible_container("Heading", fields)
	assert_is(graph_node_instance.get_child(-1), CollapsibleContainer, "Most recent child should be collapsable container")
	assert_eq(container.get_child_count(), 5)
	assert_eq(container.text, "Heading")
	assert_connected(container, graph_node_instance, "toggled")


func test_add_collapsable_menu_with_no_fields():
	var fields : Array[Field] = []
	var container = graph_node_instance.add_collapsible_container("Heading", fields)
	assert_is(graph_node_instance.get_child(-1), CollapsibleContainer, "Most recent child should be collapsable container")
	assert_eq(container.get_child_count(), 1)
	assert_eq(container.text, "Heading")
	assert_connected(container, graph_node_instance, "toggled")
	
	
func test_add_spacer():
	var spacer = graph_node_instance.add_spacer(30.0)
	assert_is(graph_node_instance.get_child(-1), Control, "Most recent child should be control")
	assert_eq(spacer.custom_minimum_size.y, 30.0)
	spacer = graph_node_instance.add_spacer()
	assert_is(graph_node_instance.get_child(-1), Control, "Most recent child should be control")
	assert_eq(spacer.custom_minimum_size.y, 20.0, "Default size should be 20")


func test_add_checkbox():
	var checkbox = graph_node_instance.add_checkbox("Heading", true)
	var hbox = graph_node_instance.get_child(-1)
	assert_is(hbox, HBoxContainer, "Most recent child should be HBoxContainer")
	assert_eq(hbox.get_child_count(), 2)
	assert_is(hbox.get_child(0), Label)
	assert_is(hbox.get_child(1), CheckBox)
	assert_eq(hbox.get_child(1), checkbox, "Checkbox returned by function should be same checkbox in hbox container")
	assert_eq(hbox.get_child(0).text, "Heading")
	assert_true(checkbox.button_pressed, "Checkbox should be pressed")
	checkbox = graph_node_instance.add_checkbox("Heading", false)
	assert_false(checkbox.button_pressed, "Checkbox should not be pressed")
	
	
func test_add_slider():
	var slider = graph_node_instance.add_slider("Heading", 10, -30, 50, 0.5)
	assert_is(graph_node_instance.get_child(-1), HSlider, "Most recent child should be slider")
	assert_is(graph_node_instance.get_child(-2), Label, "Second most recent child should be label")
	assert_eq(graph_node_instance.get_child(-2).text, "Heading: 10")
	assert_eq(slider.min_value, -30.0)
	assert_eq(slider.max_value, 50.0)
	assert_eq(slider.value, 10.0)
	slider.value_changed.emit(20.56)
	assert_eq(graph_node_instance.get_child(-2).text, "Heading: 20.56", "Label is not updating correctly on value changed")


func test_add_choice_picker():
	var values = {"ValueOne": 1, "ValueTwo": 2}
	var choice_picker : ChoicePicker = graph_node_instance.add_choice_picker("Heading", values, "ValueTwo")
	assert_is(graph_node_instance.get_child(-1), ChoicePicker, "Most recent child should be choice picker")
	assert_eq(choice_picker.text, "Heading")
	assert_eq(choice_picker.popup_values, values)
	assert_eq(choice_picker.get_node("%PickOptionButton").text, "ValueTwo")


func test_add_vector_input():
	var vector_value = Vector2(-1, 2)
	var vector_input : VectorInput = graph_node_instance.add_vector_input("Heading", vector_value)
	assert_is(graph_node_instance.get_child(-1), VectorInput, "Most recent child should be VectorInput")
	assert_eq(vector_input.heading, "Heading")
	assert_eq(vector_input.value, vector_value)


func test_set_left_port():
	var slot_type = TaskEditorGraphNode.SlotType.PREQ_TO_MESSAGE
	var slot_color = graph_node_instance.slot_colors[slot_type]
	graph_node_instance.set_port(true, 0, slot_type)
	assert_true(graph_node_instance.is_slot_enabled_left(0))
	assert_false(graph_node_instance.is_slot_enabled_right(0))
	assert_eq(graph_node_instance.get_slot_type_left(0), slot_type)
	assert_eq(graph_node_instance.get_slot_color_left(0), slot_color)


func test_set_right_port():
	var slot_type = TaskEditorGraphNode.SlotType.PREQ_TO_MESSAGE
	var slot_color = graph_node_instance.slot_colors[slot_type]
	graph_node_instance.set_port(false, 0, slot_type)
	assert_true(graph_node_instance.is_slot_enabled_right(0))
	assert_false(graph_node_instance.is_slot_enabled_left(0))
	assert_eq(graph_node_instance.get_slot_type_right(0), slot_type)
	assert_eq(graph_node_instance.get_slot_color_right(0), slot_color)


func test_set_both():
	var slot_type = TaskEditorGraphNode.SlotType.PREQ_TO_MESSAGE
	var slot_color = graph_node_instance.slot_colors[slot_type]
	graph_node_instance.set_port(false, 0, slot_type)
	graph_node_instance.set_port(true, 0, slot_type)
	assert_true(graph_node_instance.is_slot_enabled_left(0))
	assert_eq(graph_node_instance.get_slot_type_left(0), slot_type)
	assert_eq(graph_node_instance.get_slot_color_left(0), slot_color)
	assert_true(graph_node_instance.is_slot_enabled_right(0))
	assert_eq(graph_node_instance.get_slot_type_right(0), slot_type)
	assert_eq(graph_node_instance.get_slot_color_right(0), slot_color)
