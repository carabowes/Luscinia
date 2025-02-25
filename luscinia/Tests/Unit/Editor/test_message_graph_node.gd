extends GutTest

var image = preload("res://Sprites/icon.svg")
var message_node_instance : MessageGraphNode
var message : Message


func before_each():
	message = Message.new("Test", [], 2, null, [], [], 5, true, Message.CancelBehaviour.PREREQ_RESEND)
	message_node_instance = MessageGraphNode.new(message)
	add_child_autofree(message_node_instance)

# Message Node Layout
# 0 - Delete Button
# 1 - Message Text Label
# 2 - Message TextEdit Input
# 3 - Spacer (Control)
# 4 - Sender Label				- Slot open on Left
# 5 - Spacer 
# 6 - Responses Label			- Slot open on right
# 7 - Default Response Index Label
# 8 - Default Response Index LineEdit
# 9 - Spacer
# 10- Prerequisite Label		- Slot open on Left
# 11- Spacer
# 12- Antirequisite Label		- Slot open on Left
# 13- Spacer
# 14- Turns to Answer Label
# 15- Turns to Answer LineEdit
# 16- Spacer
# 17- IsRepeatable HBox (Label and Checkbox)
# 18- Spacer
# 19- Cancel Behaviour ChoicePicker
func test_init():
	assert_eq(message_node_instance.message, message)
	
	assert_eq(message_node_instance.title, "Message Node")
	assert_is(message_node_instance.get_child(1), Label, "First child should be Label")
	assert_eq(message_node_instance.get_child(1).text, "Message Text")
	
	assert_is(message_node_instance.get_child(2), TextEdit, "Second child should be TextEdit")
	assert_eq(message_node_instance.get_child(2).text, "Test", "Message TextEdit not being set")
	assert_connected(message_node_instance.get_child(2), message_node_instance, "text_changed")
	
	assert_is(message_node_instance.get_child(3), Control, "Third child should be a Spacer")
	
	assert_is(message_node_instance.get_child(4), Label, "Fourth child should be Label")
	assert_eq(message_node_instance.get_child(4).text, "Sender")
	
	assert_is(message_node_instance.get_child(5), Control, "Fifth child should be a Spacer")
	
	assert_is(message_node_instance.get_child(6), Label, "Sixth child should be Label")
	assert_eq(message_node_instance.get_child(6).text, "Responses")
	
	assert_is(message_node_instance.get_child(7), Label, "Seventh child should be Label")
	assert_eq(message_node_instance.get_child(7).text, "Default Response Index")
	
	assert_is(message_node_instance.get_child(8), LineEdit, "Eighth child should be LineEdit")
	assert_eq(message_node_instance.get_child(8).text, "2", "Default response index LineEdit not being set")
	assert_connected(message_node_instance.get_child(8), message_node_instance, "text_changed")
	
	assert_is(message_node_instance.get_child(9), Control, "Nineth child should be a Spacer")
	
	assert_is(message_node_instance.get_child(10), Label, "Seventh child should be Label")
	assert_eq(message_node_instance.get_child(10).text, "Prerequisites")
	
	assert_is(message_node_instance.get_child(11), Control, "Eleventh child should be a Spacer")
	
	assert_is(message_node_instance.get_child(12), Label, "Twelvth child should be Label")
	assert_eq(message_node_instance.get_child(12).text, "Antirequisites")
	
	assert_is(message_node_instance.get_child(13), Control, "Thirteenth child should be a Spacer")
	
	assert_is(message_node_instance.get_child(14), Label, "Fourteenth child should be Label")
	assert_eq(message_node_instance.get_child(14).text, "Turns to Answer")
	
	assert_is(message_node_instance.get_child(15), LineEdit, "Fifteenth child should be LineEdit")
	assert_eq(message_node_instance.get_child(15).text, "5", "Turns to answer LineEdit not being set")
	assert_connected(message_node_instance.get_child(15), message_node_instance, "text_changed")
	
	assert_is(message_node_instance.get_child(16), Control, "Sixteenth child should be a Spacer")
	
	assert_is(message_node_instance.get_child(17), HBoxContainer, "Seventeenth child should be HBox")
	assert_eq(message_node_instance.get_child(17).get_child(0).text, "Is Repeatable?")
	assert_true(message_node_instance.get_child(17).get_child(1).button_pressed, "IsRepeatable Checkbox not being set")
	assert_connected(message_node_instance.get_child(17).get_child(1), message_node_instance, "pressed")
	
	assert_is(message_node_instance.get_child(18), Control, "Eighteenth child should be a Spacer")
	
	assert_is(message_node_instance.get_child(19), ChoicePicker, "Nineteenth Child should be ChoicePicker")
	assert_eq(message_node_instance.get_child(19).text, "Cancel Behaviour", "Choice picker heading incorrect")
	assert_eq(message_node_instance.get_child(19).get_node("%PickOptionButton").text, "PREREQ_RESEND", "Choice picker value incorrect")

func test_ports():
	assert_eq(message_node_instance.get_input_port_count(), 3)
	assert_true(message_node_instance.is_slot_enabled_left(4))
	assert_true(message_node_instance.is_slot_enabled_left(10))
	assert_true(message_node_instance.is_slot_enabled_left(12))
	assert_eq(message_node_instance.get_slot_type_left(4), TaskEditorGraphNode.SlotType.SENDER_TO_MESSAGE)
	assert_eq(message_node_instance.get_slot_type_left(10), TaskEditorGraphNode.SlotType.PREQ_TO_MESSAGE)
	assert_eq(message_node_instance.get_slot_type_left(12), TaskEditorGraphNode.SlotType.PREQ_TO_MESSAGE)
	
	assert_eq(message_node_instance.get_output_port_count(), 1)
	assert_true(message_node_instance.is_slot_enabled_right(6))
	assert_eq(message_node_instance.get_slot_type_right(6), TaskEditorGraphNode.SlotType.MESSAGE_TO_RESPONSE)


func test_on_message_contents_changed():
	message_node_instance._on_message_contents_changed("Hello")
	assert_eq(message_node_instance.message.message, "Hello")


func test_on_default_response_changed():
	var default_response : LineEdit = message_node_instance.get_child(8) 
	message_node_instance._on_default_response_changed("0", default_response)
	assert_eq(message_node_instance.message.default_response, 0)
	assert_eq(default_response.self_modulate, Color.WHITE) 
	message_node_instance._on_default_response_changed("text", default_response)
	assert_eq(message_node_instance.message.default_response, -1)
	assert_eq(default_response.self_modulate, Color.RED)


func test_on_turns_to_answer_changed():
	var turns_to_answer : LineEdit = message_node_instance.get_child(15) 
	message_node_instance._on_turns_to_answer_changed("5", turns_to_answer)
	assert_eq(message_node_instance.message.turns_to_answer, 5)
	assert_eq(turns_to_answer.self_modulate, Color.WHITE) 
	message_node_instance._on_turns_to_answer_changed("text", turns_to_answer)
	assert_eq(message_node_instance.message.turns_to_answer, -1)
	assert_eq(turns_to_answer.self_modulate, Color.RED)


func _on_is_repeatable_changed():
	var checkbox : CheckBox = message_node_instance.get_child(17).get_child(1)
	checkbox.set_pressed_no_signal(!checkbox.button_pressed)
	message_node_instance._on_is_repeatable_changed(checkbox)
	assert_eq(message_node_instance.message.is_repeatable, checkbox.button_pressed)


func test_create_node_to_connect_to_empty():
	var connected_node = message_node_instance.create_node_to_connect_to_empty(MessageGraphNode.OutPortNums.RESPONSES)
	assert_is(connected_node, ResponseGraphNode)
	connected_node.free()
	assert_eq(message_node_instance.create_node_to_connect_to_empty(100), null)


func test_create_node_to_connect_from_empty():
	var node_types = [SenderGraphNode, RequisiteGraphNode, RequisiteGraphNode]
	for port in MessageGraphNode.InPortNums.values():
		var connected_node = message_node_instance.create_node_to_connect_from_empty(port)
		assert_is(connected_node, node_types[port])
		connected_node.free()
	assert_eq(message_node_instance.create_node_to_connect_from_empty(100), null)


func test_assign_connection():
	var sender_node = SenderGraphNode.new(Sender.new())
	assert_true(message_node_instance.assign_connection(MessageGraphNode.InPortNums.SENDER, sender_node))
	assert_eq(message_node_instance.message.sender, sender_node.sender)
	sender_node.free()
	
	var prereq_node = RequisiteGraphNode.new(Prerequisite.new())
	assert_true(message_node_instance.assign_connection(MessageGraphNode.InPortNums.PREREQUISITES, prereq_node))
	assert_true(message_node_instance.message.prerequisites.has(prereq_node.prerequisite))
	prereq_node.free()
	
	var antireq_node = RequisiteGraphNode.new(Prerequisite.new())
	assert_true(message_node_instance.assign_connection(MessageGraphNode.InPortNums.ANTIREQUISITES, antireq_node))
	assert_true(message_node_instance.message.antirequisites.has(antireq_node.prerequisite))
	antireq_node.free()


func test_remove_connection():
	var sender_node = SenderGraphNode.new(Sender.new())
	message_node_instance.assign_connection(MessageGraphNode.InPortNums.SENDER, sender_node)
	assert_true(message_node_instance.remove_connection(MessageGraphNode.InPortNums.SENDER, sender_node))
	assert_ne(message_node_instance.message.sender, sender_node.sender)
	sender_node.free()
	
	var prereq_node = RequisiteGraphNode.new(Prerequisite.new())
	message_node_instance.assign_connection(MessageGraphNode.InPortNums.PREREQUISITES, prereq_node)
	assert_true(message_node_instance.remove_connection(MessageGraphNode.InPortNums.PREREQUISITES, prereq_node))
	assert_false(message_node_instance.message.prerequisites.has(prereq_node.prerequisite))
	prereq_node.free()
	
	var antireq_node = RequisiteGraphNode.new(Prerequisite.new())
	message_node_instance.assign_connection(MessageGraphNode.InPortNums.ANTIREQUISITES, antireq_node)
	assert_true(message_node_instance.remove_connection(MessageGraphNode.InPortNums.ANTIREQUISITES, antireq_node))
	assert_false(message_node_instance.message.antirequisites.has(antireq_node.prerequisite))
	antireq_node.free()
