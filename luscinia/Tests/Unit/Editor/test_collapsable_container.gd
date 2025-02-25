extends GutTest

var container_instance : CollapsibleContainer
var heading_label : Label
var expand_label : Label
var background : ColorRect
var label_box : Panel

func before_each():
	container_instance = load("res://Scenes/Editor/collapsable_container.tscn").instantiate()
	for i in range(5):
		container_instance.add_child(Control.new())
	add_child_autofree(container_instance)
	heading_label = container_instance.get_node("%DropdownTitle")
	expand_label = container_instance.get_node("%Expand")
	background = container_instance.get_node("%Background")
	label_box = container_instance.get_node("%LabelBox")


func test_setters_and_getters():
	assert_eq(container_instance.text, "Heading", "Default value should be 'Heading'")
	container_instance.text = "Test"
	assert_eq(heading_label.text, "Test", "Setter should set heading label")
	assert_eq(container_instance.text, "Test")


func test_connections():
	assert_connected(label_box, container_instance, "gui_input", "_on_click")


func test_hidden_on_start():
	for i in range(1, 6):
		assert_false(container_instance.get_children()[i].visible)


func test_set_item_visibility():
	container_instance.set_item_visibility(true)
	for child in container_instance.get_children():
		assert_true(child.visible)
	
	container_instance.set_item_visibility(false)
	assert_true(container_instance.get_child(0).visible)
	for i in range(1, 6):
		assert_false(container_instance.get_child(i).visible)


func test_on_click():
	watch_signals(container_instance)
	var input : GutInputSender = InputSender.new(label_box)
	input.action_down("interact")
	assert_true(container_instance.is_expanded)
	assert_eq(expand_label.text, "-")
	assert_signal_emitted(container_instance, "toggled")
	for child in container_instance.get_children():
		assert_true(child.visible)
	
	input.action_up("interact")
	input.action_down("interact")
	input.mouse_left_click_at(label_box.position)
	assert_false(container_instance.is_expanded)
	assert_eq(expand_label.text, "+")
	assert_signal_emitted(container_instance, "toggled")
	for i in range(1, 6):
		assert_false(container_instance.get_children()[i].visible)
