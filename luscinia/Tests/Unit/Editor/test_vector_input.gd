extends GutTest

var vetor_input_instance : VectorInput
var x_input : LineEdit
var y_input : LineEdit
var heading_label : Label

func before_each():
	vetor_input_instance = load("res://Scenes/Editor/vector_input.tscn").instantiate()
	add_child_autofree(vetor_input_instance)
	x_input = vetor_input_instance.get_node("%XInput")
	y_input = vetor_input_instance.get_node("%YInput")
	heading_label = vetor_input_instance.get_node("%HeadingLabel")


func test_getters_and_setters():
	assert_eq(vetor_input_instance.heading, "Heading", "Default value should be 'Heading'")
	vetor_input_instance.heading = "Test"
	assert_eq(heading_label.text, "Test", "Setter should set heading label")
	assert_eq(vetor_input_instance.heading, "Test")
	
	assert_eq(vetor_input_instance.value, Vector2.ZERO, "Default value should be 0")
	vetor_input_instance.value = Vector2(-5, 5)
	assert_eq(x_input.text, "-5", "Setter should set inputs")
	assert_eq(y_input.text, "5", "Setter should set inputs")
	assert_eq(vetor_input_instance.value, Vector2(-5, 5))


func test_connections():
	assert_connected(x_input, vetor_input_instance, "text_changed")
	assert_connected(y_input, vetor_input_instance, "text_changed")


func test_valid_x_input():
	watch_signals(vetor_input_instance)
	x_input.text = "8"
	x_input.text_changed.emit("8")
	assert_eq(x_input.self_modulate, Color.WHITE)
	assert_eq(x_input.text, "8")
	assert_eq(vetor_input_instance.get_x_value(), 8)
	assert_signal_emitted_with_parameters(vetor_input_instance, "value_changed", [Vector2(8, 0)])


func test_invalid_x_input():
	watch_signals(vetor_input_instance)
	x_input.text = "test"
	x_input.text_changed.emit("test")
	assert_eq(x_input.self_modulate, Color.RED)
	assert_eq(x_input.text, "test")
	assert_eq(vetor_input_instance.get_x_value(), 0)
	assert_signal_not_emitted(vetor_input_instance, "value_changed")


func test_valid_y_input():
	watch_signals(vetor_input_instance)
	y_input.text = "8"
	y_input.text_changed.emit("8")
	assert_eq(y_input.self_modulate, Color.WHITE)
	assert_eq(y_input.text, "8")
	assert_eq(vetor_input_instance.get_y_value(), 8)
	assert_signal_emitted_with_parameters(vetor_input_instance, "value_changed", [Vector2(0, 8)])


func test_invalid_y_input():
	watch_signals(vetor_input_instance)
	y_input.text = "test"
	y_input.text_changed.emit("test")
	assert_eq(y_input.self_modulate, Color.RED)
	assert_eq(y_input.text, "test")
	assert_eq(vetor_input_instance.get_y_value(), 0)
	assert_signal_not_emitted(vetor_input_instance, "value_changed")


func test_get_x_value():
	x_input.text = "test"
	assert_eq(vetor_input_instance.get_x_value(), 0)
	x_input.text = "4.5"
	assert_eq(vetor_input_instance.get_x_value(), 0)
	x_input.text = "4"
	assert_eq(vetor_input_instance.get_x_value(), 4)
	x_input.text = "-5"
	assert_eq(vetor_input_instance.get_x_value(), -5)


func test_get_y_value():
	y_input.text = "test"
	assert_eq(vetor_input_instance.get_y_value(), 0)
	y_input.text = "4.5"
	assert_eq(vetor_input_instance.get_y_value(), 0)
	y_input.text = "4"
	assert_eq(vetor_input_instance.get_y_value(), 4)
	y_input.text = "-5"
	assert_eq(vetor_input_instance.get_y_value(), -5)
