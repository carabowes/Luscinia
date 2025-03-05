class_name MessageGraphNode
extends TaskEditorGraphNode


enum InPortNums
{
	SENDER = 0,
	PREREQUISITES = 1,
	ANTIREQUISITES = 2
}
enum OutPortNums
{
	RESPONSES = 0
}

var message : Message


func _init(message : Message):
	super()
	self.message = message
	custom_minimum_size.x = 400
	title = "Message Node"

	var message_input = add_large_input("Message Text", message.message)
	message_input.text_changed.connect(func(): _on_message_contents_changed(message_input.text))

	add_spacer()
	var sender_label = Label.new()
	sender_label.text = "Sender"
	add_child(sender_label)
	set_port(true, sender_label.get_index(), SlotType.SENDER_TO_MESSAGE)

	add_spacer()
	var responses_label = Label.new()
	responses_label.text = "Responses"
	add_child(responses_label)
	set_port(false, responses_label.get_index(), SlotType.MESSAGE_TO_RESPONSE)

	var default_response_input = add_input("Default Response Index", str(message.default_response))
	default_response_input.text_changed.connect(\
	func(text): _on_default_response_changed(text, default_response_input))

	add_spacer()
	var prerequisites_label = Label.new()
	prerequisites_label.text = "Prerequisites"
	add_child(prerequisites_label)
	set_port(true, prerequisites_label.get_index(), SlotType.PREQ_TO_MESSAGE)

	add_spacer(10)

	var antirequisites_label = Label.new()
	antirequisites_label.text = "Antirequisites"
	add_child(antirequisites_label)
	set_port(true, antirequisites_label.get_index(), SlotType.PREQ_TO_MESSAGE)

	add_spacer()
	var turns_to_answer_input = add_input("Turns to Answer", str(message.turns_to_answer))
	turns_to_answer_input.text_changed.connect(\
	func(text): _on_turns_to_answer_changed(text, turns_to_answer_input))

	add_spacer()
	var is_repeatable_check = add_checkbox("Is Repeatable?", message.is_repeatable)
	is_repeatable_check.pressed.connect(func(): _on_is_repeatable_changed(is_repeatable_check))

	add_spacer()
	var cancel_behaviour = add_choice_picker("Cancel Behaviour",\
	Message.CancelBehaviour, Message.CancelBehaviour.keys()[message.cancel_behaviour])
	cancel_behaviour.value_chosen.connect(\
	func(value): message.cancel_behaviour = value; print(message.cancel_behaviour))


func _on_message_contents_changed(contents : String):
	message.message = contents


func _on_default_response_changed(value : String, input : LineEdit):
	if value == "" or not value.is_valid_int() or value .to_int() > len(message.responses):
		value = "-1"
		input.self_modulate = Color.RED
	else:
		input.self_modulate = Color.WHITE
	message.default_response = value.to_int()


func _on_turns_to_answer_changed(value : String, input : LineEdit):
	if value == "" or not value.is_valid_int():
		value = "-1"
		input.self_modulate = Color.RED
	else:
		input.self_modulate = Color.WHITE
	message.turns_to_answer = value.to_int()


func _on_is_repeatable_changed(checkbox : CheckBox):
	message.is_repeatable = checkbox.button_pressed


func assign_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.SENDER and in_node is SenderGraphNode:
		message.sender = in_node.sender
	elif in_port == InPortNums.PREREQUISITES and in_node is RequisiteGraphNode:
		message.prerequisites.append(in_node.prerequisite)
	elif in_port == InPortNums.ANTIREQUISITES and in_node is RequisiteGraphNode:
		message.antirequisites.append(in_node.prerequisite)
	else:
		return false
	return true


func remove_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.SENDER and in_node is SenderGraphNode:
		message.sender = null
	elif in_port == InPortNums.PREREQUISITES and in_node is RequisiteGraphNode:
		message.prerequisites.erase(in_node.prerequisite)
	elif in_port == InPortNums.ANTIREQUISITES and in_node is RequisiteGraphNode:
		message.antirequisites.erase(in_node.prerequisite)
	else:
		return false
	return true


func create_node_to_connect_from_empty(in_port: int):
	if in_port == InPortNums.SENDER:
		return SenderGraphNode.new(Sender.new())
	if in_port == InPortNums.PREREQUISITES:
		return RequisiteGraphNode.new(Prerequisite.new())
	if in_port == InPortNums.ANTIREQUISITES:
		return RequisiteGraphNode.new(Prerequisite.new())
	return null


func create_node_to_connect_to_empty(out_port: int):
	if out_port == OutPortNums.RESPONSES:
		return ResponseGraphNode.new(Response.new())
	return null
