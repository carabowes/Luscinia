extends GutTest

var field_instance : Field

func before_each():
	field_instance = load("res://Scenes/Editor/field.tscn").instantiate()
	add_child_autofree(field_instance)


func test_getters_setters():
	assert_eq(field_instance.field_name, "Heading", "Default field name should be 'Heading'")
	field_instance.field_name = "Test"
	assert_eq(field_instance.get_node("%FieldName").text, "Heading", "Setter should set field name label")
	assert_eq(field_instance.field_name, "Test")
	
	assert_eq(field_instance.field_value, "", "Default field value should be empty")
	field_instance.field_value = "Test"
	assert_eq(field_instance.get_node("%FieldValue").text, "Test", "Setter should set field value text")
	assert_eq(field_instance.field_value, "Test")


func test_connections():
	assert_connected(field_instance.get_node("%FieldValue"), field_instance, "text_submitted")
	assert_connected(field_instance.get_node("%FieldValue"), field_instance, "focus_exited")


func test_text_submitted():
	watch_signals(field_instance)
	field_instance.get_node("%FieldValue").text_submitted.emit("New Text")
	assert_signal_emitted_with_parameters(field_instance, "field_changed", ["Heading", "New Text"])


func test_focus_exited():
	watch_signals(field_instance)
	field_instance.get_node("%FieldValue").focus_exited.emit()
	assert_signal_emitted_with_parameters(field_instance, "field_changed", ["Heading", ""])
