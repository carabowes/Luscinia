extends GutTest

var message_renderer_instance : MessageRenderer
var bubble_container : VBoxContainer

var split_params = ParameterFactory.named_parameters(
	['message', 'count'], 
	[
		["One.", 1],
		["One", 1],
		["Five. Four. Three. Two. One.", 5],
	]
)

func before_each():
	message_renderer_instance = load("res://Scenes/UI/message.tscn").instantiate()
	bubble_container = message_renderer_instance.get_node("%BubbleContainer")
	add_child_autofree(message_renderer_instance)


func test_signal_connections():
	assert_connected(bubble_container, message_renderer_instance, "resized")


func test_splitting_messages(params = use_parameters(split_params)):
	message_renderer_instance.render_message(params.message)
	assert_eq(bubble_container.get_child_count(), params.count)
