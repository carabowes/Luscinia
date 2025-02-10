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
	
	add_large_input("Message Text", message.message)
	
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
	add_input("Turns to answer", str(message.turns_to_answer))
	
	add_spacer()
	add_checkbox("Is Repeatable?", message.is_repeatable)


func assign_connection(in_port : int, in_node : TaskEditorGraphNode):
	if in_port == InPortNums.SENDER:
		message.sender = in_node.sender
	elif in_port == InPortNums.PREREQUISITES:
		message.prerequisites.append(in_node.prerequisite)
	elif in_port == InPortNums.ANTIREQUISITES:
		message.antirequisites.append(in_node.prerequisite)
	ResourceSaver.save(message)


func remove_connection(in_port : int, in_node : TaskEditorGraphNode):
	if in_port == InPortNums.SENDER:
		message.sender = null
	elif in_port == InPortNums.PREREQUISITES:
		message.prerequisites.erase(in_node.prerequisite)
	elif in_port == InPortNums.ANTIREQUISITES:
		message.antirequisites.erase(in_node.prerequisite)
	ResourceSaver.save(message)
