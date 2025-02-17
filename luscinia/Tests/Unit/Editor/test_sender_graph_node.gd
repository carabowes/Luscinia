extends GutTest

var image = preload("res://Sprites/icon.svg")
var sender_node_instance : SenderGraphNode
var sender : Sender


func before_each():
	sender = Sender.new("Sender",image, 10)
	sender_node_instance = SenderGraphNode.new(sender)
	add_child_autofree(sender_node_instance)

# Sender Node Layout
# 0 - Delete Button
# 1 - Sender Name Heading
# 2 - Sender Name Input   - Slot open on Right
# 3 - Image Selector
# 4 - Relationship Heading
# 5 - Relationship Slider
func test_init():
	assert_eq(sender_node_instance.sender, sender)
	
	assert_eq(sender_node_instance.title, "Sender Node")
	assert_is(sender_node_instance.get_child(1), Label, "First child should be Label")
	assert_eq(sender_node_instance.get_child(1).text, "Sender Name")
	
	assert_is(sender_node_instance.get_child(2), LineEdit, "Second child should be LineEdit")
	assert_eq(sender_node_instance.get_child(2).text, "Sender")
	assert_connected(sender_node_instance.get_child(2), sender_node_instance, "text_changed", "_on_sender_name_changed")
	
	assert_is(sender_node_instance.get_child(3), ImageSelector, "Third child should be ImageSelector")
	assert_eq(sender_node_instance.get_child(3).current_image, image)
	assert_connected(sender_node_instance.get_child(3), sender_node_instance, "image_selected", "_on_sender_icon_changed")
	
	assert_is(sender_node_instance.get_child(4), Label, "Fourth child should be Label")
	assert_eq(sender_node_instance.get_child(4).text, "Relationship: 10")
	
	assert_is(sender_node_instance.get_child(5), HSlider, "Fifth child should be Slider")
	assert_eq(sender_node_instance.get_child(5).value, 10.0)
	assert_connected(sender_node_instance.get_child(5), sender_node_instance, "value_changed", "_on_relationship_changed")


func test_ports():
	assert_eq(sender_node_instance.get_input_port_count(), 0)
	assert_eq(sender_node_instance.get_output_port_count(), 1)
	assert_true(sender_node_instance.is_slot_enabled_right(2))
	assert_eq(sender_node_instance.get_slot_type_right(2), TaskEditorGraphNode.SlotType.SENDER_TO_MESSAGE)


func test_on_sender_name_changed():
	watch_signals(sender_node_instance)
	sender_node_instance._on_sender_name_changed("Test")
	assert_eq(sender_node_instance.sender.name, "Test")
	assert_signal_emitted_with_parameters(sender_node_instance, "information_updated", [sender_node_instance])


func test_on_sender_icon_changed():
	watch_signals(sender_node_instance)
	sender_node_instance._on_sender_icon_changed(null)
	assert_eq(sender_node_instance.sender.image, null)
	assert_signal_emitted_with_parameters(sender_node_instance, "information_updated", [sender_node_instance])


func test_on_relationship_changed():
	watch_signals(sender_node_instance)
	sender_node_instance._on_relationship_changed(5)
	assert_eq(sender_node_instance.sender.relationship, 5.0)
	assert_signal_emitted_with_parameters(sender_node_instance, "information_updated", [sender_node_instance])


func test_create_node_to_connect_to_empty():
	var connected_node = sender_node_instance.create_node_to_connect_to_empty(SenderGraphNode.OutPortNums.MESSAGE)
	assert_is(connected_node, MessageGraphNode)
	connected_node.free()
	assert_eq(sender_node_instance.create_node_to_connect_to_empty(1), null)


func test_create_node_to_connect_from_empty():
	assert_eq(sender_node_instance.create_node_to_connect_from_empty(0), null)


func test_assign_connection():
	assert_false(sender_node_instance.assign_connection(0, null))


func test_remove_connection():
	assert_false(sender_node_instance.remove_connection(0, null))
