class_name MessageGraphNode
extends TaskEditorGraphNode

var message : Message

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

func _init(message : Message):
	super()
	self.message = message
	custom_minimum_size.x = 400
	title = "Message Node"
	
	var message_input = add_large_input("Message Text", message.message)
	message_input.text_changed.connect(func(): _on_message_contents_changed(message_input.text))
	
	add_spacer()
	var responses_label = Label.new()
	responses_label.text = "Responses"
	add_child(responses_label)
	set_port(false, responses_label.get_index(), SlotType.MESSAGE_TO_RESPONSE)
	
	add_spacer()
	var sender_label = Label.new()
	sender_label.text = "Sender"
	add_child(sender_label)
	set_port(true, sender_label.get_index(), SlotType.SENDER_TO_MESSAGE)
	
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
	var turns_to_answer_input = add_input("Turns to answer", str(message.turns_to_answer))
	turns_to_answer_input.text_changed.connect(func(text): _on_turns_to_answer_changed(text, turns_to_answer_input))
	
	add_spacer()
	var is_repeatable_check = add_checkbox("Is Repeatable?", message.is_repeatable)
	is_repeatable_check.pressed.connect(func(): _on_is_repeatable_changed(is_repeatable_check))


func _on_message_contents_changed(contents : String):
	message.message = contents


func _on_turns_to_answer_changed(contents : String, input : LineEdit):
	if not contents.is_valid_int():
		input.text = str(message.turns_to_answer)
		return
	message.turns_to_answer = contents.to_int()


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
